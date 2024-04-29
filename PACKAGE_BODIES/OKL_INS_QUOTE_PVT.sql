--------------------------------------------------------
--  DDL for Package Body OKL_INS_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INS_QUOTE_PVT" AS
/* $Header: OKLRINQB.pls 120.55.12010000.2 2008/09/10 17:46:40 rkuttiya ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.INSURANCE';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

---------------------------------------------------------------------------
-- Start of comments
--
-- Function Name	: create_third_prt_ins
-- Description		:To Create Third Party Insurance.
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
PROCEDURE create_third_prt_ins(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                  IN ipyv_rec_type,
     x_ipyv_rec                  OUT NOCOPY  ipyv_rec_type
         ) IS
   l_api_version			CONSTANT NUMBER := 1;
   l_api_name			CONSTANT VARCHAR2(30) := 'create_third_prt_ins';
   l_return_status			VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
   l_cplv_rec_type                okl_okc_migration_pvt.cplv_rec_type;
   x_cplv_rec_type                okl_okc_migration_pvt.cplv_rec_type;

   --gboomina 26-Oct-05 Bug#4558486 - Added - Start
   l_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;
   lx_kplv_rec     okl_k_party_roles_pvt.kplv_rec_type;
   --gboomina 26-Oct-05 Bug#4558486 - Added - End

   CURSOR c_vendor_exist (p_khr_id NUMBER , p_isu_id  NUMBER) IS
          select 'x'
             from
                   OKC_K_PARTY_ROLES_B CPLB
             where CPLB.CHR_ID = p_khr_id
             and CPLB.DNZ_CHR_ID = p_khr_id
             and CPLB.OBJECT1_ID1 = p_isu_id
             and CPLB.JTOT_OBJECT1_CODE = 'OKX_PARTY'
             and CPLB.RLE_CODE = 'EXTERNAL_PARTY';
     l_dummy   VARCHAR2(1) := '?';
     BEGIN
              x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                            G_PKG_NAME,
                                                           p_init_msg_list,
                                                           l_api_version,
                                                           p_api_version,
                                                           '_PROCESS',
                                                           x_return_status);
                 IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_ERROR;
                 END IF;

       -- CREATE  Role only if vendor is not there
            OPEN c_vendor_exist(p_ipyv_rec.KHR_ID ,p_ipyv_rec.ISU_ID );
            FETCH c_vendor_exist INTO l_dummy ;
            CLOSE c_vendor_exist ;

       IF ( l_dummy = '?' ) THEN

		l_cplv_rec_type.sfwt_flag := 'N';
                l_cplv_rec_type.CHR_ID := p_ipyv_rec.KHR_ID ;
                l_cplv_rec_type.DNZ_CHR_ID := p_ipyv_rec.KHR_ID ;
		l_cplv_rec_type.RLE_CODE := 'EXTERNAL_PARTY' ;
		l_cplv_rec_type.OBJECT1_ID1 := p_ipyv_rec.ISU_ID ;
		l_cplv_rec_type.OBJECT1_ID2 := '#' ;
		l_cplv_rec_type.JTOT_OBJECT1_CODE :=  'OKX_PARTY' ;
    -- Start of wraper code generated automatically by Debug code generator for okl_k_party_roles_pvt.create_k_party_role
      IF(L_DEBUG_ENABLED='Y') THEN
        L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
        IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
      END IF;
      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call okl_k_party_roles_pvt.create_k_party_role ');
        END;
      END IF;
      -- gboomina 26-Oct-05 Bug#4558486 Start - Changed okl_okc_migration_pvt.create_k_party_role to okl_k_party_roles_pvt.create_k_party_role
            okl_k_party_roles_pvt.create_k_party_role(
            		p_api_version                  =>l_api_version,
            		p_init_msg_list             => OKC_API.G_FALSE,
            		x_return_status             =>   l_return_status,
            		 x_msg_count                =>    x_msg_count,
            		x_msg_data                  =>  x_msg_data ,
            		p_cplv_rec                     =>  l_cplv_rec_type,
            		x_cplv_rec                  =>    x_cplv_rec_type,
			p_kplv_rec                  => l_kplv_rec,
                        x_kplv_rec                  => lx_kplv_rec);

      -- gboomina 26-Oct-05 Bug#4558486 End - Changed okl_okc_migration_pvt.create_k_party_role to okl_k_party_roles_pvt.create_k_party_role

      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call okl_k_party_roles_pvt.create_k_party_role ');
        END;
      END IF;
    -- End of wraper code generated automatically by Debug code generator for okl_k_party_roles_pvt.create_k_party_role
            	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

                 	  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            	  RAISE OKC_API.G_EXCEPTION_ERROR;
            	END IF;


       END IF ;

    -- Start of wraper code generated automatically by Debug code generator for okl_k_party_roles_pvt.create_k_party_role
          IF(L_DEBUG_ENABLED='Y') THEN
            L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
            IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
          END IF;
          IF(IS_DEBUG_PROCEDURE_ON) THEN
            BEGIN
                OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.insert_ins_policies ');
            END;
         END IF;
            	-- Payment Call Temp

		Okl_Ins_Policies_Pub.insert_ins_policies(
           p_api_version                  => l_api_version,
           p_init_msg_list                => OKC_API.G_FALSE,
           x_return_status                => l_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_ipyv_rec                     => p_ipyv_rec,
           x_ipyv_rec                     => x_ipyv_rec
          );


    	   IF(IS_DEBUG_PROCEDURE_ON) THEN
	    BEGIN
	          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.insert_ins_policies ');
	    END;
           END IF;


                    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    		  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	  	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    	  	       RAISE OKC_API.G_EXCEPTION_ERROR;
    	        END IF;



      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
     END create_third_prt_ins ;
---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name  : crt_lseapp_thrdprt_ins
  -- Description    : To Create Third Party Insurance for Lease Application.
  -- Business Rules :
  -- Parameters     :
  -- Version        : 1.0
  -- History        : 19-Sep-2005:Bug 4567777 PAGARG new procedures for Lease
  --                  Application Functionality.
  -- End of Comments
  ---------------------------------------------------------------------------
  PROCEDURE crt_lseapp_thrdprt_ins(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN ipyv_rec_type,
     x_ipyv_rec                     OUT NOCOPY  ipyv_rec_type)
  IS
    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'crt_lseapp_thrdprt_ins';
    l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR third_prty_exist(p_lapp_id IN NUMBER)IS
      SELECT 'x'
      FROM OKL_INS_POLICIES_B
      WHERE lease_application_id = p_lapp_id
        AND IPY_TYPE = 'THIRD_PARTY_POLICY'
        AND KHR_ID IS NULL -- not a contract yet
        AND TRUNC(nvl(DATE_TO,SYSDATE)) > TRUNC(SYSDATE);

    l_dummy   VARCHAR2(1) := '?';
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                           G_PKG_NAME
						  ,p_init_msg_list
						  ,l_api_version
						  ,p_api_version
						  ,'_PROCESS'
						  ,l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
	THEN
	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
	THEN
	  RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- check if lease application already has active third party policy
    OPEN third_prty_exist(p_ipyv_rec.lease_application_id);
    FETCH third_prty_exist INTO l_dummy;
    CLOSE third_prty_exist;
    IF ( l_dummy <> '?' )
	THEN
      OKL_API.set_message(g_app_name,'OKL_THIRD_PARTY_EXIST');
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Code for Debug Messages
    IF(L_DEBUG_ENABLED='Y')
	THEN
	  L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
      IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
    END IF;
    IF(IS_DEBUG_PROCEDURE_ON)
	THEN
      BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(
		    L_LEVEL_PROCEDURE
		   ,L_MODULE
		   ,'Begin Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.insert_ins_policies');
      END;
    END IF;
	Okl_Ins_Policies_Pub.insert_ins_policies(
        p_api_version                  => l_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => l_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ipyv_rec                     => p_ipyv_rec,
        x_ipyv_rec                     => x_ipyv_rec);
    IF(IS_DEBUG_PROCEDURE_ON)
	THEN
	  BEGIN
	    OKL_DEBUG_PUB.LOG_DEBUG(
		    L_LEVEL_PROCEDURE
		   ,L_MODULE
		   ,'End Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.insert_ins_policies');
	  END;
    END IF;
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
	THEN
	  RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
	THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             l_api_name
							,G_PKG_NAME
							,'OKL_API.G_RET_STS_ERROR'
							,x_msg_count
							,x_msg_data
							,'_PROCESS');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             l_api_name
                            ,G_PKG_NAME
                            ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                            ,x_msg_count
                            ,x_msg_data
                            ,'_PROCESS');
    WHEN OTHERS
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             l_api_name
                            ,G_PKG_NAME
                            ,'OTHERS'
                            ,x_msg_count
                            ,x_msg_data
                            ,'_PROCESS');
  END crt_lseapp_thrdprt_ins;
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name  : lseapp_thrdprty_to_ctrct
  -- Description    : To attach Third Party Insurance to contract created from
  --                  Lease Application.
  -- Business Rules :
  -- Parameters     :
  -- Version        : 1.0
  -- History        : 19-Sep-2005:Bug 4567777 PAGARG new procedures for Lease
  --                  Application Functionality.
  -- End of Comments
  ---------------------------------------------------------------------------
  PROCEDURE lseapp_thrdprty_to_ctrct(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_lakhr_id                     IN  NUMBER,
     x_ipyv_rec                     OUT NOCOPY  ipyv_rec_type)
  IS
    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'lsp_tp_con';
    l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_lease_application_id       NUMBER;
    l_third_party_ins_id         NUMBER;
    l_isu_id                     NUMBER;
    l_ipyv_rec                   ipyv_rec_type;
    l_cplv_rec_type              okl_okc_migration_pvt.cplv_rec_type;
    x_cplv_rec_type              okl_okc_migration_pvt.cplv_rec_type;
    l_ovn                        NUMBER;

   --gboomina 26-Oct-05 Bug#4558486 - Added - Start
   l_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;
   lx_kplv_rec     okl_k_party_roles_pvt.kplv_rec_type;
   --gboomina 26-Oct-05 Bug#4558486 - Added - End

    CURSOR fetch_lease_app(c_lakhr_id IN NUMBER)
	IS
      SELECT ORIG_SYSTEM_ID1
      FROM OKC_K_HEADERS_B
      WHERE id = p_lakhr_id;

    CURSOR fetch_policy(c_lease_app_id IN NUMBER)
	IS
      SELECT ID
	       , ISU_ID
         , OBJECT_VERSION_NUMBER
      FROM OKL_INS_POLICIES_B
      WHERE lease_application_id = c_lease_app_id
        AND IPY_TYPE = 'THIRD_PARTY_POLICY'
        AND TRUNC(nvl(DATE_TO,SYSDATE)) > TRUNC(SYSDATE);

    CURSOR c_vendor_exist (p_khr_id NUMBER , p_isu_id  NUMBER)
	IS
     select 'x'
             from OKC_K_PARTY_ROLES_B CPLB
             where CPLB.CHR_ID = p_khr_id
               and CPLB.DNZ_CHR_ID = p_khr_id
               and CPLB.OBJECT1_ID1 = p_isu_id
             and CPLB.JTOT_OBJECT1_CODE = 'OKX_PARTY'
             and CPLB.RLE_CODE = 'EXTERNAL_PARTY';
    l_dummy VARCHAR2(1) := '?';
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(
	                       l_api_name
						  ,G_PKG_NAME
						  ,p_init_msg_list
						  ,l_api_version
						  ,p_api_version
						  ,'_PROCESS'
						  ,l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
	THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
	THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Check to see if there is existing active third party policy should be done
    -- prior to call for this API in Authoring teams API.
    -- Get Lease Application ID from which current contract is created
    OPEN fetch_lease_app(p_lakhr_id);
    FETCH fetch_lease_app INTO l_lease_application_id;
    CLOSE fetch_lease_app;
    -- Get active Third party insurance policy for the lease application
    OPEN fetch_policy(l_lease_application_id);
    FETCH fetch_policy INTO l_third_party_ins_id,l_isu_id,l_ovn;
    CLOSE fetch_policy;
    --bug 4875084. do further processing only if l_third_party_ins_id is not null
    IF l_third_party_ins_id IS NOT NULL THEN
      -- CREATE Role only if vendor is not there
      OPEN c_vendor_exist(p_lakhr_id ,l_isu_id );
      FETCH c_vendor_exist INTO l_dummy;
      CLOSE c_vendor_exist;
      IF ( l_dummy = '?' )
      THEN
        l_cplv_rec_type.sfwt_flag := 'N';
        l_cplv_rec_type.CHR_ID := p_lakhr_id;
        l_cplv_rec_type.DNZ_CHR_ID := p_lakhr_id;
        l_cplv_rec_type.RLE_CODE := 'EXTERNAL_PARTY';
        l_cplv_rec_type.OBJECT1_ID1 := l_isu_id;
        l_cplv_rec_type.OBJECT1_ID2 := '#';
        l_cplv_rec_type.JTOT_OBJECT1_CODE :=  'OKX_PARTY';
        --Code for Debug Messages
        IF(L_DEBUG_ENABLED='Y')
      THEN
          L_LEVEL_PROCEDURE := FND_LOG.LEVEL_PROCEDURE;
          IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
        END IF;
        IF(IS_DEBUG_PROCEDURE_ON)
      THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(
            L_LEVEL_PROCEDURE
         ,L_MODULE
         ,'Begin Debug OKLRINQB.pls call okl_k_party_roles_pvt.create_k_party_role');
          END;
        END IF;
        -- gboomina 26-Oct-05 Bug#4558486 Start - Changed okl_okc_migration_pvt.create_k_party_role to okl_k_party_roles_pvt.create_k_party_role
        okl_k_party_roles_pvt.create_k_party_role(
            p_api_version               => l_api_version,
            p_init_msg_list             => OKL_API.G_FALSE,
            x_return_status             => l_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data ,
            p_cplv_rec                  => l_cplv_rec_type,
            x_cplv_rec                  => x_cplv_rec_type,
            p_kplv_rec                  => l_kplv_rec,
            x_kplv_rec                  => lx_kplv_rec);

        -- gboomina 26-Oct-05 Bug#4558486 End - Changed okl_okc_migration_pvt.create_k_party_role to okl_k_party_roles_pvt.create_k_party_role
        IF(IS_DEBUG_PROCEDURE_ON)
      THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(
            L_LEVEL_PROCEDURE
         ,L_MODULE
         ,'End Debug OKLRINQB.pls call okl_k_party_roles_pvt.create_k_party_role');
          END;
        END IF;
        -- End of call to okl_k_party_roles_pvt.create_k_party_role
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
      THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
      THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF ;
      --populate insurance policy record for updating with contract number
      l_ipyv_rec.id := l_third_party_ins_id;
      l_ipyv_rec.khr_id := p_lakhr_id; -- Update existing record with contract id
      l_ipyv_rec.object_version_number := l_ovn; --skgautam  Bug# 4721141
      -- Start of code for debug messages
      IF(L_DEBUG_ENABLED='Y')
    THEN
        L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
        IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
      END IF;
      IF(IS_DEBUG_PROCEDURE_ON)
    THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(
          L_LEVEL_PROCEDURE
         ,L_MODULE
         ,'Begin Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.update_ins_policies');
        END;
      END IF;
      IF l_ipyv_rec.id IS NOT NULL THEN
        Okl_Ins_Policies_Pub.update_ins_policies(
            p_api_version                  => l_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_ipyv_rec                     => l_ipyv_rec,
            x_ipyv_rec                     => x_ipyv_rec);
        IF(IS_DEBUG_PROCEDURE_ON)
        THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(
                L_LEVEL_PROCEDURE
               ,L_MODULE
               ,'End Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.update_ins_policies');
          END;
        END IF;
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
      THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
      THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
     END IF;
  END IF;
	x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
	THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             l_api_name
							,G_PKG_NAME
							,'OKL_API.G_RET_STS_ERROR'
							,x_msg_count
							,x_msg_data
							,'_PROCESS');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
	THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             l_api_name
                            ,G_PKG_NAME
							,'OKL_API.G_RET_STS_UNEXP_ERROR'
							,x_msg_count
							,x_msg_data
							,'_PROCESS');
    WHEN OTHERS
	THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             l_api_name
							,G_PKG_NAME
							,'OTHERS'
							,x_msg_count
							,x_msg_data
							,'_PROCESS');
  END lseapp_thrdprty_to_ctrct;
  ---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Start of comments
--
-- Function Name	: get_contract_status
-- Description		:It get Contract status based on contract id.
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
 FUNCTION get_contract_status (
          p_khr_id IN  NUMBER,
          x_contract_status OUT NOCOPY VARCHAR2
        ) RETURN VARCHAR2 IS
          l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
          CURSOR okc_k_status_csr(p_khr_id  IN NUMBER) IS
              SELECT STE_CODE
	          FROM  OKC_K_HEADERS_V KHR , OKC_STATUSES_B OST
              WHERE  KHR.ID =  p_khr_id
              AND KHR.STS_CODE = OST.CODE ;

        BEGIN
          OPEN  okc_k_status_csr(p_khr_id);
         FETCH okc_k_status_csr INTO x_contract_status ;
         IF(okc_k_status_csr%NOTFOUND) THEN
            -- store SQL error message on message stack for caller
               OKL_API.set_message(G_APP_NAME,
               			   G_INVALID_CONTRACT
               			   );
               CLOSE okc_k_status_csr ;
               l_return_status := OKC_API.G_RET_STS_ERROR;
               -- Change it to
               RETURN(l_return_status);
         END IF;
         CLOSE okc_k_status_csr ;
         RETURN(l_return_status);
         EXCEPTION
           WHEN OTHERS THEN
               -- store SQL error message on message stack for caller
               OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      		-- notify caller of an UNEXPECTED error
      		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      		-- verify that cursor was closed
    		IF okc_k_status_csr%ISOPEN THEN
	    	   CLOSE okc_k_status_csr;
		    END IF;
          	RETURN(l_return_status);
      END get_contract_status;
   --------------------------------------------------------

PROCEDURE payment_stream(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                 IN ipyv_rec_type,
     p_payment_tbl_type   IN  payment_tbl_type ) IS

   	l_stmv_rec			Okl_Streams_Pub.stmv_rec_type;
	l_api_version			CONSTANT NUMBER := 1;
    l_api_name			CONSTANT VARCHAR2(30) := 'payment_stream';
    l_return_status			VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    p_stmv_rec			Okl_Streams_Pub.stmv_rec_type;
	x_stmv_rec		        Okl_Streams_Pub.stmv_rec_type;
	p_selv_tbl			Okl_Streams_Pub.selv_tbl_type;
	x_selv_tbl			Okl_Streams_Pub.selv_tbl_type;

    l_date  DATE;

     BEGIN

         l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                       G_PKG_NAME,
                                                      p_init_msg_list,
                                                      l_api_version,
                                                      p_api_version,
                                                      '_PROCESS',
                                                      x_return_status);
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

    BEGIN
     select OKL_SIF_SEQ.nextval INTO p_stmv_rec.transaction_number from dual;


EXCEPTION
          WHEN NO_DATA_FOUND THEN
                -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME,  'OKL_NO_SEQUENCE'  );
                 RAISE OKC_API.G_EXCEPTION_ERROR;
          WHEN OTHERS THEN
                 -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        		 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END ;

 -- Cursor replaced with the call to get the stream type id, change made for insurance user defined streams, bug 3924300

     OKL_STREAMS_UTIL.get_primary_stream_type(p_ipyv_rec.khr_id,
                                                   'INSURANCE_PAYABLE',
                                                   l_return_status,
                                                   p_stmv_rec.sty_id);

     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN ,'INSURANCE_PAYABLE'); --bug 4024785
                   x_return_status := OKC_API.G_RET_STS_ERROR ;
                   RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;


p_stmv_rec.sgn_code := 'MANL';
p_stmv_rec.say_code := 'CURR';
p_stmv_rec.active_yn := 'Y';
p_stmv_rec.date_current := SYSDATE;
p_stmv_rec.khr_id := p_ipyv_rec.khr_id ;
p_stmv_rec.kle_id := p_ipyv_rec.kle_id ;


        IF(p_payment_tbl_type.count > 0)THEN
              FOR i IN 1..p_payment_tbl_type.count  LOOP
                 p_selv_tbl(i).stream_element_date := p_payment_tbl_type(i).DUE_DATE;
                 l_date := p_payment_tbl_type(i).DUE_DATE ;
                 p_selv_tbl(i).amount := p_payment_tbl_type(i).AMOUNT;
                 p_selv_tbl(i).se_line_number := i;
                 p_selv_tbl(i).accrued_yn := 'N';
              END LOOP;
                  -- Create Stream and Stream Elements
-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.create_streams
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;

  -- Bug 5408689 : Start
  IF(IS_DEBUG_PROCEDURE_ON)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(
       L_LEVEL_PROCEDURE
      ,L_MODULE
      ,'Begin Debug OKLRSULB.pls  call Okl_Streams_Util.round_streams_amount ' );
  END IF;
  l_return_status := Okl_Streams_Util.round_streams_amount(
                        p_api_version   => p_api_version
                       ,p_init_msg_list => p_init_msg_list
                       ,x_msg_count     => x_msg_count
                       ,x_msg_data      => x_msg_data
                       ,p_chr_id        => p_stmv_rec.khr_id
                       ,p_selv_tbl      => p_selv_tbl
                       ,x_selv_tbl      => x_selv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(
       L_LEVEL_PROCEDURE
      ,L_MODULE
      ,'End Debug OKLRSULB.pls  call Okl_Streams_Util.round_streams_amount');
  END IF;

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
  THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
  THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- Store Rounded Streams back into the p_selv_tbl
  p_selv_tbl:= x_selv_tbl;
  -- Bug 5408689 : End


  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call OKL_STREAMS_PUB.create_streams ');
    END;
  END IF;
            OKL_STREAMS_PUB.create_streams(
                p_api_version
               ,p_init_msg_list
               ,x_return_status
               ,x_msg_count
               ,x_msg_data
               ,p_stmv_rec
               ,p_selv_tbl
               ,x_stmv_rec
               ,x_selv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call OKL_STREAMS_PUB.create_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.create_streams

      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
      	END IF;
     END IF;

      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
     END payment_stream ;



  FUNCTION genrt_monthly_inc(p_ipyv_rec IN ipyv_rec_type,x_selv_tbl OUT NOCOPY Okl_Streams_Pub.selv_tbl_type)
  			RETURN VARCHAR2 IS
     l_date_from			DATE;
     l_date_to			DATE;
     l_ins_term                   NUMBER;
     l_premium			NUMBER;
     l_bill_periods		NUMBER;
     l_monthly_pmnt		NUMBER;
     l_due_date			DATE;
     l_amount_due			NUMBER;
     l_num_days_in_month          NUMBER;
     l_prorated          NUMBER;
     i				    PLS_INTEGER;
     j				    PLS_INTEGER;
     l_return_status		VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_flag               VARCHAR2(1);
   BEGIN
     l_date_from := TRUNC(p_ipyv_rec.date_from);
     l_date_to := TRUNC(p_ipyv_rec.date_to);

      --Check if date_from and date_to difference is greater than a month
     IF (l_date_to  - l_date_from >= TO_NUMBER(TO_CHAR(LAST_DAY(l_date_from),'DD'))) THEN -- bug 4056603

       l_premium := p_ipyv_rec.premium;
       l_ins_term := MONTHS_BETWEEN(l_date_to,l_date_from);
       l_due_date := TRUNC(LAST_DAY(l_date_from));
       IF ((l_date_from -1) = LAST_DAY(ADD_MONTHS(l_date_from,-1)))THEN

       	 l_bill_periods := round(l_ins_term);

       ELSE
       		l_bill_periods := l_ins_term +1 ;
       		l_flag :='Y';
       END IF;



       IF(l_flag = 'Y') THEN
        --dbms_output.put_line('IN INCOME 3');
        l_num_days_in_month := 30 - TO_NUMBER(TO_CHAR(l_date_from,'DD')) +1;
        l_amount_due := (l_premium * l_num_days_in_month)/30;
        l_prorated := l_amount_due;

        -- First Month
        x_selv_tbl(1).stream_element_date := l_due_date;
	x_selv_tbl(1).amount := l_prorated;
	x_selv_tbl(1).se_line_number := 1;
        --- Last Month
        x_selv_tbl(l_bill_periods).stream_element_date := LAST_DAY(l_date_to);
	x_selv_tbl(l_bill_periods).amount := l_premium - l_prorated;
	x_selv_tbl(l_bill_periods).se_line_number := round(l_bill_periods);

        i := 1;
        j := l_bill_periods -2 ;
         IF(j > 0)THEN
                LOOP
                        x_selv_tbl(i + 1).stream_element_date := LAST_DAY(ADD_MONTHS(l_due_date, i));
                        x_selv_tbl(i + 1 ).amount := l_premium;
                        x_selv_tbl(i + 1).se_line_number := i+ 1;
                   EXIT WHEN i >= j;
                      	 i := i + 1;

                END LOOP;

         END IF;
       ELSE
        l_amount_due := l_premium ;
        i := 1;
           IF(l_bill_periods > 0)THEN
                LOOP
                   x_selv_tbl(i).stream_element_date := ADD_MONTHS(l_due_date,i-1);
                   x_selv_tbl(i).amount := l_amount_due;
                   x_selv_tbl(i).se_line_number := i;

                   EXIT WHEN i >= l_bill_periods;
                      	 i := i + 1;
                END LOOP;

             END IF;
        END IF;
   ELSE --bug 4056603 ***start
 --If less than one month charge for 1 month
        l_premium := p_ipyv_rec.premium;
        l_bill_periods := 1 ;
        l_due_date := TRUNC(LAST_DAY(l_date_from));
        l_num_days_in_month := l_due_date - l_date_from;
        l_amount_due :=(l_premium * l_num_days_in_month)/30;
          i := 1;
        x_selv_tbl(i).stream_element_date := l_due_date;
        x_selv_tbl(i).amount := l_amount_due;
        x_selv_tbl(i).se_line_number := i;

   END IF; -- bug 4056603 *** End

    RETURN(l_return_status);
  END genrt_monthly_inc;


FUNCTION genrt_monthly(p_insexp_tbl IN insexp_tbl_type,
    p_date_from IN DATE,
    x_selv_tbl OUT NOCOPY Okl_Streams_Pub.selv_tbl_type)
			RETURN VARCHAR2 IS
   l_ins_term                   NUMBER;
   l_premium			NUMBER;
   l_bill_periods		NUMBER;
   l_monthly_pmnt		NUMBER;
   l_due_date			DATE;
   period	                NUMBER;
   period_amount                NUMBER;
   l_amount_due			NUMBER;
   l_prorated                  NUMBER ;
   l_num_days_in_month     NUMBER;
   i				PLS_INTEGER;
   j                            PLS_INTEGER;
   k				PLS_INTEGER;
   l_return_status		VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
   l_flag  VARCHAR2(1) := 'N';
   l_date_from   DATE ;
 BEGIN

      IF p_insexp_tbl IS NOT NULL THEN
        IF p_insexp_tbl.COUNT > 0 THEN


         	l_date_from := TRUNC(p_date_from);


         --Check if date_from and date_to difference is greater than a month
	   --     IF (l_date_to  - l_date_from >= TO_NUMBER(TO_CHAR(LAST_DAY(l_date_from),'DD'))) THEN

          l_premium := p_insexp_tbl(1).amount  ;
          l_ins_term := p_insexp_tbl(1).period;
          l_due_date := TRUNC(LAST_DAY(l_date_from));
          IF ((l_date_from -1) = LAST_DAY(ADD_MONTHS(l_date_from,-1)))THEN

          	    l_bill_periods := round(l_ins_term);

          ELSE
          		l_bill_periods := l_ins_term +1 ;
          		l_flag :='Y';
          END IF;




         IF(l_flag = 'Y') THEN
           --dbms_output.put_line('IN INCOME 3');
               l_num_days_in_month := 30 - TO_NUMBER(TO_CHAR(l_date_from,'DD')) +1;
               l_amount_due := (l_premium * l_num_days_in_month)/30;
               l_prorated := l_amount_due;

           -- First Month
               x_selv_tbl(1).stream_element_date := l_due_date;
           	x_selv_tbl(1).amount := l_prorated;
           	x_selv_tbl(1).se_line_number := 1;
               --- Last Month
               x_selv_tbl(l_bill_periods).stream_element_date
                 := LAST_DAY(ADD_MONTHS(l_date_from,l_ins_term));
           	x_selv_tbl(l_bill_periods).amount
               := l_premium - l_prorated;
               x_selv_tbl(l_bill_periods).se_line_number := round(l_bill_periods);

           i := 1;
           j := l_bill_periods -2 ;
            IF(j > 0)THEN
                   LOOP
                           x_selv_tbl(i + 1).stream_element_date := LAST_DAY(ADD_MONTHS(l_due_date, i));
                           x_selv_tbl(i + 1 ).amount := l_premium;
                           x_selv_tbl(i + 1).se_line_number := i+ 1;
                      EXIT WHEN i >= j;
                         	 i := i + 1;

                   END LOOP;

            END IF;
          ELSE
           l_amount_due := l_premium ;
           i := 1;
              IF(l_bill_periods > 0)THEN
                   LOOP
                      x_selv_tbl(i).stream_element_date := ADD_MONTHS(l_due_date,i-1);
                      x_selv_tbl(i).amount := l_amount_due;
                      x_selv_tbl(i).se_line_number := i;

                      EXIT WHEN i >= l_bill_periods;
                         	 i := i + 1;
                   END LOOP;

                END IF;
           END IF;
        END IF;
        END IF;

    RETURN(l_return_status);

END genrt_monthly;


PROCEDURE  create_insinc_streams(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN ipyv_rec_type
         )IS
   	l_stmv_rec			Okl_Streams_Pub.stmv_rec_type;
	l_row_notfound			BOOLEAN := TRUE;
	l_msg_count			NUMBER ;
	l_msg_data                      VARCHAR2(2000);
	l_api_version			CONSTANT NUMBER := 1;
    l_api_name			CONSTANT VARCHAR2(30) := 'create_insinc_streams';
    l_return_status			VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    p_stmv_rec			Okl_Streams_Pub.stmv_rec_type;
	x_stmv_rec		        Okl_Streams_Pub.stmv_rec_type;
	p_selv_tbl			Okl_Streams_Pub.selv_tbl_type;
	x_selv_tbl			Okl_Streams_Pub.selv_tbl_type;
	x_khr_status			VARCHAR2 (30) ;
	l_khr_date_from			DATE ;
	l_khr_date_to			DATE ;
	l_ipyv_rec			Okl_Ipy_Pvt.ipyv_rec_type;
	l_khr_id			NUMBER;
    p_premium           NUMBER;
    i                   PLS_INTEGER;

    l_pdtv_rec_type  OKL_SETUPPRODUCTS_PVT.pdtv_rec_type ;
    l_pdt_parameters_rec OKL_SETUPPRODUCTS_PVT.pdt_parameters_rec_type ;
    l_khr_status   VARCHAR2(30) ;
    l_multigaap_flag VARCHAR2(30);
   x_no_data_found                BOOLEAN;


    -- Changes for multi gaap
    cursor multi_gaap_flag_cur  IS
    select  MULTI_GAAP_YN
    from okl_k_headers
    WHERE ID  = l_ipyv_rec.khr_id ;


    cursor khr_product_cur  IS
    select  PDT_ID
    from okl_k_headers
    WHERE ID  = l_ipyv_rec.khr_id ;
BEGIN

 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
             		G_PKG_NAME,
             		p_init_msg_list,
                        l_api_version,
                        p_api_version,
                        '_PROCESS',
                        x_return_status);
   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;

 l_ipyv_rec := p_ipyv_rec;
 l_khr_id	:= l_ipyv_rec.khr_id;

---------------------------------------------------------------------
----------- generate stream
-------------------------------------------------------------------
-- SET values to retrieve record

p_stmv_rec.khr_id :=  p_ipyv_rec.khr_id ;
p_stmv_rec.kle_id :=  p_ipyv_rec.kle_id ;
BEGIN
select OKL_SIF_SEQ.nextval INTO p_stmv_rec.transaction_number from dual;

      -- call to get the stream type id, change made for insurance user defined streams, bug 3924300
     OKL_STREAMS_UTIL.get_primary_stream_type(p_ipyv_rec.khr_id,
                                                   'INSURANCE_INCOME_ACCRUAL',
                                                   l_return_status,
                                                   p_stmv_rec.sty_id);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN ,'INSURANCE_INCOME_ACCRUAL'); --bug 4024785
                   x_return_status := OKC_API.G_RET_STS_ERROR ;
                   RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

EXCEPTION
          WHEN NO_DATA_FOUND THEN
                -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME,  G_K_NOT_ACTIVE
                 			   );
          WHEN OTHERS THEN
                 -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        		-- notify caller of an UNEXPECTED error
        		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        		-- verify that cursor was closed
  		END ;

p_stmv_rec.sgn_code := 'MANL';
p_stmv_rec.say_code := 'WORK';
p_stmv_rec.active_yn := 'N';
p_stmv_rec.date_working := SYSDATE;
p_premium := p_ipyv_rec.premium;
l_ipyv_rec := p_ipyv_rec;

IF p_ipyv_rec.ipf_code = 'MONTHLY'THEN
  l_return_status :=  genrt_monthly_inc(p_ipyv_rec,x_selv_tbl);
ELSIF (p_ipyv_rec.ipf_code = 'BI_MONTHLY') THEN
  l_ipyv_rec.premium := p_premium/2;
  l_return_status :=  genrt_monthly_inc(l_ipyv_rec,x_selv_tbl);
 ELSIF (p_ipyv_rec.ipf_code = 'HALF_YEARLY') THEN
  l_ipyv_rec.premium := p_premium/6;
  l_return_status :=  genrt_monthly_inc(l_ipyv_rec,x_selv_tbl);
 ELSIF (p_ipyv_rec.ipf_code = 'QUARTERLY') THEN
  l_ipyv_rec.premium := p_premium/3;
  l_return_status :=  genrt_monthly_inc(l_ipyv_rec,x_selv_tbl);
 ELSIF (p_ipyv_rec.ipf_code = 'YEARLY') THEN
  l_ipyv_rec.premium := p_premium/12;
  l_return_status :=  genrt_monthly_inc(l_ipyv_rec,x_selv_tbl);
 END IF;

  --l_return_status :=  OKC_API.G_RET_STS_ERROR;
 --ELSIF (p_ipyv_rec.ipf_code = 'LEASE_FREQUENCY') THEN
  --l_return_status :=  genrt_lease_frequency(p_ipyv_rec,x_selv_tbl);
 --END IF;

 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
 END IF;

   p_selv_tbl:=x_selv_tbl;

 IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN


   -- Create Stream and Stream Elements
-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.create_streams
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;

    -- Bug 5408689 : Start
  IF(IS_DEBUG_PROCEDURE_ON)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(
       L_LEVEL_PROCEDURE
      ,L_MODULE
      ,'Begin Debug OKLRSULB.pls  call Okl_Streams_Util.round_streams_amount ' );
  END IF;
  l_return_status := Okl_Streams_Util.round_streams_amount(
                        p_api_version   => p_api_version
                       ,p_init_msg_list => p_init_msg_list
                       ,x_msg_count     => x_msg_count
                       ,x_msg_data      => x_msg_data
                       ,p_chr_id        => p_stmv_rec.khr_id
                       ,p_selv_tbl      => p_selv_tbl
                       ,x_selv_tbl      => x_selv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(
       L_LEVEL_PROCEDURE
      ,L_MODULE
      ,'End Debug OKLRSULB.pls  call Okl_Streams_Util.round_streams_amount');
  END IF;

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
  THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
  THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- Store Rounded Streams back into the p_selv_tbl
  p_selv_tbl:= x_selv_tbl;
  -- Bug 5408689 : End


  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call OKL_STREAMS_PUB.create_streams ');
    END;
  END IF;
   OKL_STREAMS_PUB.create_streams(
        p_api_version
       ,p_init_msg_list
       ,x_return_status
       ,x_msg_count
       ,x_msg_data
       ,p_stmv_rec
       ,p_selv_tbl
       ,x_stmv_rec
       ,x_selv_tbl  );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call OKL_STREAMS_PUB.create_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.create_streams


      l_return_status := x_return_status ;
     	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
  	END IF;
    -----

    ---Create another set of stream, if Multi Gaap is enabled
--   1. Get status of contract
 l_return_status :=  get_contract_status ( l_ipyv_rec.khr_id ,l_khr_status );
 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
 END IF;
   IF (l_khr_status = 'ACTIVE' ) THEN
 --- if active , get multi gaap enabled from contract header table

   BEGIN

      OPEN  multi_gaap_flag_cur;
      FETCH multi_gaap_flag_cur INTO l_multigaap_flag ;
      IF (multi_gaap_flag_cur%NOTFOUND) THEN
        l_multigaap_flag := 'N' ;
      END IF ;
      CLOSE multi_gaap_flag_cur ;
    EXCEPTION
       WHEN OTHERS THEN
                      -- store SQL error message on message stack for caller
             OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
             		-- notify caller of an UNEXPECTED error
             x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             		-- verify that cursor was closed
       		IF multi_gaap_flag_cur%ISOPEN THEN
       		        CLOSE multi_gaap_flag_cur;
             END IF;
     END;
 ELSE
-- if not active call appropriate method to determine
  --- get product id associated with the contract
     BEGIN

      OPEN  khr_product_cur;
      FETCH khr_product_cur INTO l_pdtv_rec_type.id ;
      IF (khr_product_cur%NOTFOUND) THEN
        l_multigaap_flag := 'N' ;
      END IF ;
      CLOSE khr_product_cur ;
    EXCEPTION
       WHEN OTHERS THEN
                      -- store SQL error message on message stack for caller
             OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
             		-- notify caller of an UNEXPECTED error
             x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             		-- verify that cursor was closed
       		IF khr_product_cur%ISOPEN THEN
       		        CLOSE khr_product_cur;
            END IF;
   END;

-- Start of wraper code generated automatically by Debug code generator for OKL_SETUPPRODUCTS_PVT.Getpdt_parameters
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call OKL_SETUPPRODUCTS_PVT.Getpdt_parameters ');
    END;
  END IF;
 OKL_SETUPPRODUCTS_PVT.Getpdt_parameters(
        l_api_version
       ,OKL_API.G_FALSE,
      x_return_status,
      x_no_data_found
      ,x_msg_count,
       x_msg_data
       ,  l_pdtv_rec_type
     ,  SYSDATE
       ,l_pdt_parameters_rec
        );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call OKL_SETUPPRODUCTS_PVT.Getpdt_parameters ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_SETUPPRODUCTS_PVT.Getpdt_parameters


     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

   IF (l_pdt_parameters_rec.reporting_pdt_id is NULL) THEN
              l_multigaap_flag := 'N' ;
   ELSE
              l_multigaap_flag := 'Y' ;
   END IF;

 END IF;
--- if multi gaap enabled , create another set of streams
IF(l_multigaap_flag = 'Y') THEN

     BEGIN
     select OKL_SIF_SEQ.nextval INTO p_stmv_rec.transaction_number from dual;


      -- call to get the stream type id, change made for insurance user defined streams,  bug 3924300

          OKL_STREAMS_UTIL.get_primary_stream_type(p_ipyv_rec.khr_id,
                                                   'INSURANCE_INCOME_ACCRUAL',
                                                   l_return_status,
                                                   p_stmv_rec.sty_id);
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                       Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN,' INSURANCE_INCOME_ACCRUAL'); --bug 4024785
                       RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

     EXCEPTION
               WHEN NO_DATA_FOUND THEN
                     -- store SQL error message on message stack for caller
                      OKC_API.set_message(G_APP_NAME,  G_K_NOT_ACTIVE
                      			   );
               WHEN OTHERS THEN
                      -- store SQL error message on message stack for caller
                      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
             		-- notify caller of an UNEXPECTED error
             		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             		-- verify that cursor was closed
   END ;

    p_stmv_rec.say_code := 'WORK';
	  p_stmv_rec.active_yn := 'N';
    p_stmv_rec.purpose_code := 'REPORT' ;
    p_stmv_rec.date_working := SYSDATE;


  -- Bug 5408689 : Start
  IF(IS_DEBUG_PROCEDURE_ON)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(
       L_LEVEL_PROCEDURE
      ,L_MODULE
      ,'Begin Debug OKLRSULB.pls  call Okl_Streams_Util.round_streams_amount ' );
  END IF;
  l_return_status := Okl_Streams_Util.round_streams_amount(
                        p_api_version   => p_api_version
                       ,p_init_msg_list => p_init_msg_list
                       ,x_msg_count     => x_msg_count
                       ,x_msg_data      => x_msg_data
                       ,p_chr_id        => p_stmv_rec.khr_id
                       ,p_selv_tbl      => p_selv_tbl
                       ,x_selv_tbl      => x_selv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(
       L_LEVEL_PROCEDURE
      ,L_MODULE
      ,'End Debug OKLRSULB.pls  call Okl_Streams_Util.round_streams_amount');
  END IF;

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
  THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
  THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- Store Rounded Streams back into the p_selv_tbl
  p_selv_tbl:= x_selv_tbl;
  -- Bug 5408689 : End


-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.create_streams
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call OKL_STREAMS_PUB.create_streams ');
    END;
  END IF;
       OKL_STREAMS_PUB.create_streams(
        p_api_version
       ,p_init_msg_list
       ,x_return_status
       ,x_msg_count
       ,x_msg_data
       ,p_stmv_rec
       ,p_selv_tbl
       ,x_stmv_rec
       ,x_selv_tbl
     );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call OKL_STREAMS_PUB.create_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.create_streams



     	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
  	 END IF;

  END IF;
  END IF;

  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
END create_insinc_streams;

---------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name	: create_ins_streams
 -- Description		:It generates Insurance Streams based on passed Insurance record.
 -- Business Rules	:
 -- Parameters		:
 -- Version		: 1.0
 -- End of Comments
---------------------------------------------------------------------------
PROCEDURE   create_insexp_streams(
            p_api_version                   IN NUMBER,
            p_init_msg_list                IN VARCHAR2 ,
            x_return_status                OUT NOCOPY VARCHAR2,
            x_msg_count                    OUT NOCOPY NUMBER,
            x_msg_data                     OUT NOCOPY VARCHAR2,
            p_insexp_tbl                   IN insexp_tbl_type,
            p_khr_id			   IN NUMBER,
            p_kle_id                       IN NUMBER,
            p_date_from                    IN DATE
            )IS
        l_stmv_rec			Okl_Streams_Pub.stmv_rec_type;
	l_row_notfound			BOOLEAN := TRUE;
	l_msg_count			NUMBER ;
	l_msg_data                      VARCHAR2(2000);
	l_api_version			CONSTANT NUMBER := 1;
        l_api_name			CONSTANT VARCHAR2(30) := 'create_insexp_streams';
    	l_return_status			VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    	p_stmv_rec			Okl_Streams_Pub.stmv_rec_type;
	x_stmv_rec		        Okl_Streams_Pub.stmv_rec_type;
	p_selv_tbl			Okl_Streams_Pub.selv_tbl_type;
	x_selv_tbl			Okl_Streams_Pub.selv_tbl_type;
	x_khr_status			VARCHAR2 (30) ;
	l_khr_date_from			DATE ;
	l_khr_date_to			DATE ;
	l_insexp_tbl			insexp_tbl_type;
	l_khr_id			NUMBER;
	l_period                        NUMBER;
	l_amount                        NUMBER;
    i                   PLS_INTEGER;

    l_pdtv_rec_type  OKL_SETUPPRODUCTS_PVT.pdtv_rec_type ;
    l_pdt_parameter_rec OKL_SETUPPRODUCTS_PVT.pdt_parameters_rec_type ;
    l_khr_status  VARCHAR2(30);
    l_multigaap_flag VARCHAR2(1) ;
    x_no_data_found BOOLEAN;

    -- Changes for multi gaap
    cursor multi_gaap_flag_cur  IS
    select  MULTI_GAAP_YN
    from okl_k_headers
    WHERE ID  = p_khr_id ;


    cursor khr_product_cur  IS
    select  PDT_ID
    from okl_k_headers
    WHERE ID  = p_khr_id ;


   BEGIN
               l_insexp_tbl := p_insexp_tbl;
               l_khr_id	  := p_khr_id;
---------------------------------------------------------------------
----------- generate stream
-------------------------------------------------------------------
-- SET values to retrieve record
p_stmv_rec.khr_id :=  p_khr_id ;
p_stmv_rec.kle_id :=  p_kle_id ;
-- nEW
BEGIN

    select OKL_SIF_SEQ.nextval INTO p_stmv_rec.transaction_number from dual;

-- NEW
   -- Begin : changes for Insurance user defined streams,  bug 3924300

          OKL_STREAMS_UTIL.get_primary_stream_type(p_khr_id,
                                                   'INSURANCE_EXPENSE_ACCRUAL',
                                                   l_return_status,
                                                   p_stmv_rec.sty_id);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                       Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN,'INSURANCE_EXPENSE_ACCRUAL'); --bug 4024785
                       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;


  -- End : changes for Insurance user defined streams

EXCEPTION
          WHEN NO_DATA_FOUND THEN
                -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME,  'OKL_NO_STREAM_TYPE');
          WHEN OTHERS THEN
                 -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        		-- notify caller of an UNEXPECTED error
                 l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
          END ;

	p_stmv_rec.sgn_code := 'MANL';
	 p_stmv_rec.say_code := 'WORK';
	--p_stmv_rec.say_code := 'CURR';
	p_stmv_rec.active_yn := 'N';
	p_stmv_rec.date_working := SYSDATE;


  l_return_status :=  genrt_monthly(p_insexp_tbl,p_date_from,x_selv_tbl);

 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
 END IF;
   p_selv_tbl:= x_selv_tbl;


 IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
   -- Create Stream and Stream Elements
-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.create_streams
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;

  -- Bug 5408689 : Start
  IF(IS_DEBUG_PROCEDURE_ON)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(
       L_LEVEL_PROCEDURE
      ,L_MODULE
      ,'Begin Debug OKLRSULB.pls  call Okl_Streams_Util.round_streams_amount ' );
  END IF;
  l_return_status := Okl_Streams_Util.round_streams_amount(
                        p_api_version   => p_api_version
                       ,p_init_msg_list => p_init_msg_list
                       ,x_msg_count     => x_msg_count
                       ,x_msg_data      => x_msg_data
                       ,p_chr_id        => p_stmv_rec.khr_id
                       ,p_selv_tbl      => p_selv_tbl
                       ,x_selv_tbl      => x_selv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(
       L_LEVEL_PROCEDURE
      ,L_MODULE
      ,'End Debug OKLRSULB.pls  call Okl_Streams_Util.round_streams_amount');
  END IF;

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
  THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
  THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- Store Rounded Streams back into the p_selv_tbl
  p_selv_tbl:= x_selv_tbl;
  -- Bug 5408689 : End


  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call OKL_STREAMS_PUB.create_streams ');
    END;
  END IF;
   OKL_STREAMS_PUB.create_streams(
        p_api_version
       ,p_init_msg_list
       ,x_return_status
       ,x_msg_count
       ,x_msg_data
       ,p_stmv_rec
       ,p_selv_tbl
       ,x_stmv_rec
       ,x_selv_tbl
     );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call OKL_STREAMS_PUB.create_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.create_streams
      l_return_status := x_return_status ;

     	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
  	    END IF;
---Create another set of stream, if Multi Gaap is enabled
--   1. Get status of contract
 l_return_status :=  get_contract_status ( p_khr_id ,l_khr_status );
 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
 END IF;
 IF (l_khr_status = 'ACTIVE' ) THEN
 --- if active , get multi gaap enabled from contract header table

   BEGIN

      OPEN  multi_gaap_flag_cur;
      FETCH multi_gaap_flag_cur INTO l_multigaap_flag ;

      IF (multi_gaap_flag_cur%NOTFOUND) THEN
        l_multigaap_flag := 'N' ;
      END IF ;
      CLOSE multi_gaap_flag_cur ;
    EXCEPTION
       WHEN OTHERS THEN
                      -- store SQL error message on message stack for caller
             OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
             		-- notify caller of an UNEXPECTED error
             x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             		-- verify that cursor was closed
       		IF multi_gaap_flag_cur%ISOPEN THEN
       		        CLOSE multi_gaap_flag_cur;
             END IF;
     END;

 ELSE

-- if not active call appropriate method to determine
  --- get product id associated with the contract
     BEGIN

      OPEN  khr_product_cur;
      FETCH khr_product_cur INTO l_pdtv_rec_type.id ;
      IF (khr_product_cur%NOTFOUND) THEN
        l_multigaap_flag := 'N' ;
      END IF ;
      CLOSE khr_product_cur ;
    EXCEPTION
       WHEN OTHERS THEN
                      -- store SQL error message on message stack for caller
             OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
             		-- notify caller of an UNEXPECTED error
             x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             		-- verify that cursor was closed
       		IF khr_product_cur%ISOPEN THEN
       		        CLOSE khr_product_cur;
             END IF;
      END;
-- Start of wraper code generated automatically by Debug code generator for OKL_SETUPPRODUCTS_PVT.Getpdt_parameters
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call OKL_SETUPPRODUCTS_PVT.Getpdt_parameters ');
    END;
  END IF;
     OKL_SETUPPRODUCTS_PVT.Getpdt_parameters(
        p_api_version
       ,p_init_msg_list
       ,x_return_status
       , x_no_data_found
       ,x_msg_count
       ,x_msg_data
       ,  l_pdtv_rec_type
       ,  SYSDATE
       ,l_pdt_parameter_rec  );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call OKL_SETUPPRODUCTS_PVT.Getpdt_parameters ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_SETUPPRODUCTS_PVT.Getpdt_parameters


     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     IF (l_pdt_parameter_rec.reporting_pdt_id is NULL) THEN
              l_multigaap_flag := 'N' ;
      ELSE
              l_multigaap_flag := 'Y' ;
      END IF;

 END IF;

--- if multi gaap enabled , create another set of streams
IF(l_multigaap_flag = 'Y') THEN

   BEGIN

       select OKL_SIF_SEQ.nextval INTO p_stmv_rec.transaction_number from dual;

           -- Begin : changes for Insurance user defined streams,  bug 3924300
                -- call to get the stream type id, change made for insurance user defined streams

                  OKL_STREAMS_UTIL.get_primary_stream_type(p_khr_id,
                                                   'INSURANCE_EXPENSE_ACCRUAL',
                                                   l_return_status,
                                                   p_stmv_rec.sty_id);

                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                       OKC_API.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN,'INSURANCE_EXPENSE_ACCRUAL'); --bug 4024785
                       RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;

      -- End : changes for Insurance user defined streams
   -- nEW
   EXCEPTION
             WHEN NO_DATA_FOUND THEN
                   -- store SQL error message on message stack for caller
                    OKC_API.set_message(G_APP_NAME,  'OKL_NO_STREAM_TYPE');
             WHEN OTHERS THEN
                    -- store SQL error message on message stack for caller
                    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
           		-- notify caller of an UNEXPECTED error
                    l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
          END ;

    p_stmv_rec.say_code := 'WORK';
	  p_stmv_rec.active_yn := 'N';
    p_stmv_rec.purpose_code := 'REPORT' ;
    p_stmv_rec.date_working := SYSDATE;

  -- Bug 5408689 : Start
  IF(IS_DEBUG_PROCEDURE_ON)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(
       L_LEVEL_PROCEDURE
      ,L_MODULE
      ,'Begin Debug OKLRSULB.pls  call Okl_Streams_Util.round_streams_amount ' );
  END IF;
  l_return_status := Okl_Streams_Util.round_streams_amount(
                        p_api_version   => p_api_version
                       ,p_init_msg_list => p_init_msg_list
                       ,x_msg_count     => x_msg_count
                       ,x_msg_data      => x_msg_data
                       ,p_chr_id        => p_stmv_rec.khr_id
                       ,p_selv_tbl      => p_selv_tbl
                       ,x_selv_tbl      => x_selv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(
       L_LEVEL_PROCEDURE
      ,L_MODULE
      ,'End Debug OKLRSULB.pls  call Okl_Streams_Util.round_streams_amount');
  END IF;

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
  THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
  THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- Store Rounded Streams back into the p_selv_tbl
  p_selv_tbl:= x_selv_tbl;
  -- Bug 5408689 : End


-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.create_streams
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call OKL_STREAMS_PUB.create_streams ');
    END;
  END IF;
       OKL_STREAMS_PUB.create_streams(
        p_api_version
       ,p_init_msg_list
       ,x_return_status
       ,x_msg_count
       ,x_msg_data
       ,p_stmv_rec
       ,p_selv_tbl
       ,x_stmv_rec
       ,x_selv_tbl
     );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call OKL_STREAMS_PUB.create_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.create_streams


     	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
  	    END IF;

END IF;
---need to modify activation process
-- need to modify inactivation process
--- need to check credit and other process

  END IF;
EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
         END create_insexp_streams ;



 ---------------------------------------------------------------------------
 -- FUNCTION validate_contract_line
 ---------------------------------------------------------------------------
 --FUNCTION validate_contract_line (
 FUNCTION validate_contract_line (
            p_ipyv_rec IN ipyv_rec_type
          ) RETURN VARCHAR2 IS
            l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
            l_kle_id 			 NUMBER	     :=  p_ipyv_rec.kle_id;
            l_dummy_var VARCHAR2(1) := '?';
            CURSOR okc_kle_csr IS
  	        SELECT 'x'
  	        FROM  OKL_K_LINES
       		WHERE  OKL_K_LINES.ID = l_kle_id;
          BEGIN
            OPEN  okc_kle_csr;
           	FETCH okc_kle_csr INTO l_dummy_var ;
            CLOSE okc_kle_csr ;
           	   	-- still set to default means data was not found
    	    IF ( l_dummy_var = '?' ) THEN
  	        OKC_API.set_message(g_app_name,
  	     			    'OKL_INVALID_CONTRACT_LINE');
  	     	l_return_status := OKC_API.G_RET_STS_ERROR;
  	     END IF;
           RETURN(l_return_status);
           EXCEPTION
             WHEN OTHERS THEN
                 -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        		-- notify caller of an UNEXPECTED error
        		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        		-- verify that cursor was closed
      		IF okc_kle_csr%ISOPEN THEN
  		     CLOSE okc_kle_csr;
      		END IF;
        	RETURN(l_return_status);
        END validate_contract_line;
  --------------------------------------------------------------------------
   ------validate_amount_due
  ---------------------------------------------------------------------
   PROCEDURE validate_amount_due(x_return_status OUT NOCOPY VARCHAR2,
                 p_ipyv_rec IN ipyv_rec_type) IS
        l_amount_due                NUMBER;
        BEGIN
        x_return_status	            := Okc_Api.G_RET_STS_SUCCESS;
        l_amount_due := p_ipyv_rec.premium ;
        --data is required
        IF (l_amount_due) IS NULL  OR (l_amount_due = OKC_API.G_MISS_NUM) THEN
        Okc_Api.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => 'OKL_REQUIRED_VALUE',
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'Premium');
         -- Notify caller of  an error
          x_return_status := Okc_Api.G_RET_STS_ERROR;
        ELSE
	      x_return_status  := Okl_Util.check_domain_amount(l_amount_due);
		  IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
	   	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
		   	                        p_msg_name           => 'OKL_POSITIVE_NUMBER',
		   	                        p_token1             => G_COL_NAME_TOKEN,
		   	                        p_token1_value       => 'Premium'
		   	                                  );
          ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
	        		RAISE G_EXCEPTION_HALT_VALIDATION;
     	  END IF;
       END IF;
       EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
   	       Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
   END validate_amount_due;
 -------------------------------------------------------------------------------
  -- Procedure Generate Lump_Sum
  -------------------------------------------------------------------------------
FUNCTION genrt_lump_sum(p_ipyv_rec IN ipyv_rec_type,
         x_selv_tbl OUT NOCOPY Okl_Streams_Pub.selv_tbl_type) RETURN VARCHAR2 IS
   l_date_from			DATE;
   l_date_to			DATE;
   l_due_date			DATE;
   l_ins_term                   NUMBER;
   l_return_status		VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
   l_amount_due                 NUMBER;
  BEGIN
   l_date_from := p_ipyv_rec.date_from;
   l_date_to := p_ipyv_rec.date_to;
   l_ins_term := MONTHS_BETWEEN(l_date_to,l_date_from);
   l_due_date := l_date_from;
   l_amount_due := p_ipyv_rec.premium ;

    -- Populate the stream element table type
                    x_selv_tbl(1).stream_element_date := l_due_date;
                    x_selv_tbl(1).amount := l_amount_due;
                    x_selv_tbl(1).se_line_number := 1;
                  l_return_status := Okc_Api.G_RET_STS_SUCCESS;
            RETURN (l_return_status);
END genrt_lump_sum;
-------------------------------------------------------------------------------
-- Procedure Generate Monthly
-------------------------------------------------------------------------------
FUNCTION genrt_monthly(p_ipyv_rec IN ipyv_rec_type,x_selv_tbl OUT NOCOPY Okl_Streams_Pub.selv_tbl_type)
			RETURN VARCHAR2 IS
   l_date_from			DATE;
   l_date_to			DATE;
   l_ins_term                   NUMBER;
   l_premium			NUMBER;
   l_bill_periods		NUMBER;
   l_monthly_pmnt		NUMBER;
   l_due_date			DATE;
   l_amount_due			NUMBER;
   i				    PLS_INTEGER;
   l_return_status		VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
 BEGIN
   l_date_from := p_ipyv_rec.date_from;
   l_date_to := p_ipyv_rec.date_to;
    --Check if date_from and date_to difference is greater than a month
   IF (l_date_to  - l_date_from>= 30) THEN

     l_ins_term := MONTHS_BETWEEN(l_date_to,l_date_from);

      l_premium := p_ipyv_rec.premium;
      l_bill_periods := l_ins_term ;
      l_due_date := l_date_from;
       l_amount_due :=l_premium;
	    i := 1;
       -- Populate the stream element table type
              IF(i > 0)THEN
              LOOP
                 x_selv_tbl(i).stream_element_date := l_due_date;
                 x_selv_tbl(i).amount := l_amount_due;
                 x_selv_tbl(i).se_line_number := i;
 		 l_due_date := ADD_MONTHS(l_due_date,1);
                 --EXIT WHEN l_due_date >= l_date_to;
                 EXIT WHEN i >= l_bill_periods;
				 i := i + 1;
              END LOOP;

           END IF;
  ELSE

      --If less than one month charge for 1 month
      l_premium := p_ipyv_rec.premium;
      l_bill_periods := 1 ;
      l_due_date := l_date_from;
      l_amount_due :=l_premium;

      x_selv_tbl(1).stream_element_date := l_due_date;
      x_selv_tbl(1).amount := l_amount_due;
      x_selv_tbl(1).se_line_number := 1;

                 --EXIT WHEN l_due_date >= l_date_to;

        --- Set message for period less than one month
       --l_return_status := Okc_Api.G_RET_STS_ERROR;
 END IF;
  RETURN(l_return_status);
END genrt_monthly;
-------------------------------------------------------------------------------
-- Procedure Generate Bi-Monthly
-------------------------------------------------------------------------------
FUNCTION genrt_bi_monthly(p_ipyv_rec IN ipyv_rec_type,x_selv_tbl OUT NOCOPY Okl_Streams_Pub.selv_tbl_type)RETURN VARCHAR2 IS
   l_date_from			DATE;
   l_date_to			DATE;
   l_due_date			DATE;
   l_ins_term                   NUMBER;
   l_premium                    NUMBER;
   l_bimthl_pmnt		NUMBER;
   l_bill_periods               NUMBER;
   l_amount_due                 NUMBER;
   i		                NUMBER;
   l_return_status		VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
   BEGIN
   l_date_from := p_ipyv_rec.date_from;
   l_date_to := p_ipyv_rec.date_to;
    --Check if date_from and date_to difference is greater than a month
   IF (l_date_to  - l_date_from>= 30)  THEN
     l_ins_term := MONTHS_BETWEEN(l_date_to,l_date_from);
   	IF (l_ins_term IS NULL) OR (l_ins_term = okc_api.G_MISS_NUM) THEN
   	  l_return_status := Okc_Api.G_RET_STS_ERROR;
       Okc_Api.set_message(p_app_name => G_APP_NAME,
  				    p_msg_name => 'OKL_INVALID_VALUE',
  				    p_token1 => 'COL_NAME1',
                    p_token1_Value => 'Payment Frequency'
  			);
     	ELSE
     	  l_return_status := Okc_Api.G_RET_STS_ERROR;
   	  l_premium := p_ipyv_rec.premium;
   	  l_bill_periods := l_ins_term / 2;
   	   l_due_date := l_date_from;
       l_amount_due :=l_premium;
       i := 1;
          -- Populate the stream element table type
                     IF (i > 0) THEN
                        LOOP
                           x_selv_tbl(i).stream_element_date := l_due_date;
                           x_selv_tbl(i).amount := l_amount_due;
                           x_selv_tbl(i).se_line_number := i;
                           --l_due_date := LAST_DAY(ADD_MONTHS(ADD_MONTHS(l_date_from,2),-1));
                           l_due_date := ADD_MONTHS(l_due_date,2);
                           --EXIT WHEN l_due_date >= l_date_to;
                        EXIT WHEN i >= l_bill_periods;
                           i := i + 1;
                 	    END LOOP;
                     END IF;
           --END IF;
         END IF;
      ELSE
        --- Set message for period less than one month
        l_return_status := Okc_Api.G_RET_STS_ERROR;
 END IF;
   RETURN(l_return_status);
END genrt_bi_monthly;
-------------------------------------------------------------------------------
-- Procedure Generate Half-Yearly
-------------------------------------------------------------------------------
FUNCTION genrt_half_yearly(p_ipyv_rec IN ipyv_rec_type,
        x_selv_tbl OUT NOCOPY Okl_Streams_Pub.selv_tbl_type) RETURN VARCHAR2 IS
   l_date_from			DATE;
   l_date_to			DATE;
   l_due_date			DATE;
   l_amount_due                   NUMBER;
   l_ins_term                   NUMBER;
   l_premium			NUMBER;
   l_bill_periods 		NUMBER;
   l_hlfyrly_pmnt		NUMBER;
   i				NUMBER;
   l_return_status		VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
   BEGIN
   l_date_from := p_ipyv_rec.date_from;
   l_date_to := p_ipyv_rec.date_to;
   -- Check if the date_to and date _from are greater than six months
   -- gboomina Bug 4746881 - Changed - Round of the months_between to calculate amount per month.
   -- gboomina Bug 4746881 Start
   l_ins_term := ROUND(MONTHS_BETWEEN(l_date_to,l_date_from));
   -- gboomina Bug 4746881 End

 --bug:3945995
   /*
   IF (round(l_ins_term) < 6) THEN
       l_return_status := Okc_Api.G_RET_STS_ERROR;
        Okc_Api.set_message(p_app_name => G_APP_NAME,
  				    p_msg_name => 'OKL_INVALID_VALUE',
  				    p_token1 => 'COL_NAME',
                    p_token1_Value => 'Payment Frequency');
   ELSE
   */
      l_premium := p_ipyv_rec.premium;
      l_bill_periods := l_ins_term/6; -- TBD check for whole numbers and no fractions
       l_due_date := l_date_from;
       l_amount_due :=l_premium;
       i :=1;
              -- Populate the stream element table type
       IF (i > 0) THEN
          LOOP
           x_selv_tbl(i).stream_element_date := l_due_date;
           ---Bug fix 3871319 start --
           IF (l_ins_term >= 6) THEN
            x_selv_tbl(i).amount := l_amount_due;
            l_due_date := ADD_MONTHS(l_due_date,6);
            l_ins_term := l_ins_term - 6;
           ELSE
             l_amount_due := (l_amount_due/6)* l_ins_term;
             x_selv_tbl(i).amount := l_amount_due;
             x_selv_tbl(i).stream_element_date := l_due_date;
           END IF;
           ---Bug fix 3871319 End --
           x_selv_tbl(i).se_line_number := i;
           EXIT WHEN i >= l_bill_periods;
           i := i + 1;
          END LOOP;
         END IF;
   /* END IF; */ --bug:3945995

   RETURN(l_return_status);
END genrt_half_yearly;
-------------------------------------------------------------------------------
-- Procedure Generate Quarterly
-------------------------------------------------------------------------------
FUNCTION genrt_quarterly(p_ipyv_rec IN ipyv_rec_type,x_selv_tbl OUT NOCOPY Okl_Streams_Pub.selv_tbl_type) RETURN VARCHAR2 IS
   l_date_from			DATE;
   l_date_to			DATE;
   l_due_date			DATE;
   l_amount_due                 NUMBER;
   l_ins_term                   NUMBER;
   l_premium			NUMBER;
   l_bill_periods 		NUMBER;
   l_qrtrly_pmnt		NUMBER;
   i				NUMBER;
   l_return_status		VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
   l_date_from := p_ipyv_rec.date_from;
   l_date_to := p_ipyv_rec.date_to;
   -- Check if the date_to and date_from are greater than six months
   -- gboomina Bug 4746881 - Changed - Round of the months_between to calculate amount per month.
   -- gboomina Bug 4746881 Start
   l_ins_term := ROUND(MONTHS_BETWEEN(l_date_to,l_date_from));
   -- gboomina Bug 4746881 End

 --bug:3945995
   /*
   IF(round(l_ins_term) < 3) THEN

      l_return_status := Okc_Api.G_RET_STS_ERROR;
       Okc_Api.set_message(p_app_name => G_APP_NAME,
  				    p_msg_name => 'OKL_INVALID_VALUE',
  				    p_token1 => 'COL_NAME',
                    p_token1_Value => 'Payment Frequency'
  			);
   ELSE
   */

      l_premium := p_ipyv_rec.premium;
      l_bill_periods := l_ins_term/3 ;
      l_due_date := l_date_from;
      l_amount_due :=l_premium;
      i := 1;

       -- Populate the stream element table type
       IF (i > 0) THEN
           LOOP
              x_selv_tbl(i).stream_element_date := l_due_date;
              --Bug Fix 3871319 Start --
              IF (l_ins_term >= 3) THEN
               x_selv_tbl(i).amount := l_amount_due;
               l_due_date := ADD_MONTHS(l_due_date,3);
               l_ins_term := l_ins_term - 3 ;
              ELSE
               l_amount_due := (l_amount_due/3)* l_ins_term ;
               x_selv_tbl(i).amount := l_amount_due;
               x_selv_tbl(i).stream_element_date := l_due_date;
              END IF;
              --Bug Fix 3871319 END  --
              x_selv_tbl(i).se_line_number := i;
              EXIT WHEN i >= l_bill_periods;
              i := i + 1;
            END LOOP;

        END IF;

   /* END IF;*/  --bug:3945995
   RETURN(l_return_status);
END genrt_quarterly;
-------------------------------------------------------------------------------
-- Procedure Generate Yearly
-------------------------------------------------------------------------------
FUNCTION genrt_yearly(p_ipyv_rec IN ipyv_rec_type,x_selv_tbl OUT NOCOPY Okl_Streams_Pub.selv_tbl_type)RETURN VARCHAR2 IS
   l_date_from			DATE;
   l_date_to			DATE;
   l_due_date			DATE;
   l_amount_due                 NUMBER;
   l_ins_term                   NUMBER;
   l_premium			NUMBER;
   l_bill_periods 		NUMBER;
   l_yearly_pmnt		NUMBER;
   i				NUMBER;
   l_return_status		VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
 BEGIN
   l_date_from := p_ipyv_rec.date_from;
   l_date_to := p_ipyv_rec.date_to;
   -- Check if the date_to and date_from are greater than six months
   -- gboomina Bug 4746881 - Changed - Round of the months_between to calculate amount per month.
   -- gboomina Bug 4746881 Start
   l_ins_term := ROUND(MONTHS_BETWEEN(l_date_to,l_date_from));
   -- gboomina Bug 4746881 End

 --bug:3945995
   /*
   IF(round(l_ins_term) < 12) THEN
      l_return_status := Okc_Api.G_RET_STS_ERROR;
      Okc_Api.set_message(p_app_name => G_APP_NAME,
  				    p_msg_name => 'OKL_INVALID_VALUE',
  				    p_token1 => 'COL_NAME',
                    p_token1_Value => 'Payment Frequency'
  			);
   ELSE
   */
      l_premium := p_ipyv_rec.premium;
      l_bill_periods := l_ins_term/12 ;-- TBD check for whole numbers and no fractions
       l_due_date := l_date_from;
       l_amount_due :=l_premium;
       i := 1;
       -- Populate the stream element table type
                  IF (i > 0) THEN
                     LOOP
                        x_selv_tbl(i).stream_element_date := l_due_date;
                        -- smoduga Bug Fix 3871319 Start--
                        IF (l_ins_term >= 12)THEN
                         x_selv_tbl(i).amount := l_amount_due;
                         l_ins_term := ABS(l_ins_term - 12);
                         l_due_date :=ADD_MONTHS(l_due_date,12);
                        ELSE
                         l_amount_due := (l_amount_due/12)* l_ins_term;
                         x_selv_tbl(i).amount := l_amount_due;
                         x_selv_tbl(i).stream_element_date := l_due_date;
                        END IF;
                        -- smoduga Bug Fix 3871319 End --
                        x_selv_tbl(i).se_line_number := i;
                     EXIT WHEN i >= l_bill_periods;
                        i := i+ 1 ;
              	    END LOOP;
            	 END IF;
       --END IF;
  /* END IF;*/  --bug:3945995
   RETURN(l_return_status);
END genrt_yearly;
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- FunctionName	: validate_date_from
  -- Description	:
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
     FUNCTION validate_date_from(p_date_from IN DATE )RETURN VARCHAR2 IS
     --l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     --initialize the  return status
     x_return_status	            VARCHAR2(1)	:= Okc_Api.G_RET_STS_SUCCESS;
       BEGIN
         --data is required
         IF p_date_from = Okc_Api.G_MISS_DATE OR
            p_date_from IS NULL
         THEN
           Okc_Api.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_REQUIRED_VALUE,
                               p_token1       => G_COL_NAME_TOKEN,
                               p_token1_value => 'Policy Effective From');
           --Notify caller of  an error
           x_return_status := Okc_Api.G_RET_STS_ERROR;
          END IF;
          RETURN(x_return_status);
        EXCEPTION
            WHEN OTHERS THEN
              -- store SQL error  message on message stack for caller
  	    Okc_Api.set_message(p_app_name => G_APP_NAME,
  				    p_msg_name => G_UNEXPECTED_ERROR,
  				    p_token1 => G_SQLCODE_TOKEN,
  				    p_token1_value => SQLCODE,
  				    p_token2 => G_SQLERRM_TOKEN,
  				    p_token2_value => SQLERRM
  			);
              -- Notify the caller of an unexpected error
              x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
          RETURN(x_return_status);
    END validate_date_from;
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- FUNCTIONName	: validate_date_to
  -- Description		:
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
     FUNCTION  validate_date_to(p_date_to IN DATE) RETURN VARCHAR2 IS
       --l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
       --initialize the  return status
       x_return_status	            VARCHAR2(1)	:= Okc_Api.G_RET_STS_SUCCESS;
       BEGIN
         --data is required
         IF p_date_to = Okc_Api.G_MISS_DATE OR
            p_date_to IS NULL
         THEN
           Okc_Api.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_REQUIRED_VALUE,
                               p_token1       => G_COL_NAME_TOKEN,
                               p_token1_value => 'Policy Effective To');
           --Notify caller of  an error
           x_return_status := Okc_Api.G_RET_STS_ERROR;
          END IF;
           RETURN(x_return_status);
        EXCEPTION
            WHEN OTHERS THEN
              -- store SQL error  message on message stack for caller
  	    Okc_Api.set_message(p_app_name => G_APP_NAME,
  				    p_msg_name => G_UNEXPECTED_ERROR,
  				    p_token1 => G_SQLCODE_TOKEN,
  				    p_token1_value => SQLCODE,
  				    p_token2 => G_SQLERRM_TOKEN,
  				    p_token2_value => SQLERRM
  			);
              -- Notify the caller of an unexpected error
              x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
              RETURN(x_return_status);
    END validate_date_to;
---------------------------------------------------------------------------
--Procedure validate_insurance_term
----------------------------------------------------------------------------
FUNCTION validate_insurance_term (
          p_date_from	IN DATE,
          p_date_to 	IN DATE ,
          p_khr_date_from IN DATE,
          p_khr_date_to IN DATE ) RETURN VARCHAR2 IS
          x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
          l_policy_term			 NUMBER;
          l_khr_term			 NUMBER;
          l_ins_term			 NUMBER;
        BEGIN
           --first check the validity of dates from Policy
           --Validate whether start date is less than the end date
	          x_return_status:= OKL_UTIL.check_from_to_date_range( p_date_from  ,p_date_to );
	             IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
	                 Okc_Api.set_message(
	                                     p_app_name     => g_app_name,
	 			             p_msg_name     => 'OKL_GREATER_THAN',
	 			             p_token1       => 'COL_NAME1',
	 			             p_token1_value => 'Policy Effective To',
	 			             p_token2       => 'COL_NAME2',
	 			             p_token2_value => 'Policy Effective From'
	 			            );
                      RETURN(x_return_status);
	                IF(x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                       -- store SQL error message on message stack for caller
                    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,
                                        G_SQLERRM_TOKEN, SQLERRM);
	                  RETURN(x_return_status);
	                END IF;
	             END IF;
         -- calculate the time period between start date and end date
              l_policy_term := MONTHS_BETWEEN(p_date_to,p_date_from);
                 -- Check the contarct term is greater than policy term
              l_khr_term := MONTHS_BETWEEN(p_khr_date_to,p_khr_date_from);
	 	      x_return_status:= OKL_UTIL.check_from_to_number_range( l_policy_term
	 	                                        , l_khr_term);
	 	            IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
	 	                 Okc_Api.set_message(
	 	                         p_app_name     => g_app_name,
	 	 			             p_msg_name     => 'OKL_GREATER_THAN',
	 	 			             p_token1       => 'COL_NAME1',
	 	 			             p_token1_value => 'Policy Term',
	 	 			             p_token2       => 'COL_NAME2',
	 	 			             p_token2_value => 'Contract Term'
	 	 			             );
                         RETURN(x_return_status);
	 	             IF(x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                    -- store SQL error message on message stack for caller
                        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,
                                    G_SQLERRM_TOKEN, SQLERRM);
	 	                  RETURN(x_return_status);
	 	             END IF;
	 	           END IF;
         -- check for effective date_to is in between the effective date_from and date-to
         -- of the contract
           IF (p_date_from < p_khr_date_from) OR (p_date_from >= p_khr_date_to) THEN
               -- store SQL error message on message stack for caller
              Okc_Api.set_message( p_app_name     => g_app_name,
	 			                   p_msg_name     => G_INVALID_INSURANCE_TERM );
               x_return_status := Okc_Api.G_RET_STS_ERROR;
               RETURN(x_return_status);
           ELSIF (p_date_to <= p_khr_date_from) OR (p_date_to > p_khr_date_to)THEN
                             Okc_Api.set_message( p_app_name     => g_app_name,
	 			                                  p_msg_name     => G_INVALID_INSURANCE_TERM );
               x_return_status := Okc_Api.G_RET_STS_ERROR;
               RETURN(x_return_status);
           END IF;
      RETURN(x_return_status);
      END validate_insurance_term;
-------------------------------------------------------
------- get_contract_term
------------------------------------------------------
       PROCEDURE get_contract_term(p_khr_id IN NUMBER,
                                     x_date_from OUT NOCOPY DATE,
                                     x_date_to   OUT NOCOPY DATE,
                                     x_return_status OUT NOCOPY VARCHAR2)
                                      IS
              l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
              CURSOR okc_k_term_csr(p_khr_id  IN NUMBER) IS
       	        SELECT START_DATE,END_DATE
       	        FROM  OKC_K_HEADERS_V
              WHERE  OKC_K_HEADERS_V.ID = p_khr_id;
               BEGIN
                  x_return_status := l_return_status;
                 OPEN  okc_k_term_csr(p_khr_id);
                   FETCH okc_k_term_csr INTO x_date_from, x_date_to ;
                   IF (okc_k_term_csr%NOTFOUND) THEN
                     OKC_API.set_message(G_APP_NAME, G_INVALID_INSURANCE_TERM );
                     x_return_status := Okc_Api.G_RET_STS_ERROR;
                   END IF ;
                 CLOSE okc_k_term_csr ;
                EXCEPTION
                  WHEN OTHERS THEN
                      -- store SQL error message on message stack for caller
                      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
             		-- notify caller of an UNEXPECTED error
             		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             		-- verify that cursor was closed
       		      IF okc_k_term_csr%ISOPEN THEN
       		        CLOSE okc_k_term_csr;
       		      END IF;
             END get_contract_term;
---------------------------------------------------------------------------
-- FUNCTION chk_contract_status
---------------------------------------------------------------------------
  PROCEDURE chk_contract_status (
           p_khr_id IN  NUMBER,
           x_contract_status OUT NOCOPY VARCHAR2,
           x_return_status OUT NOCOPY VARCHAR2
         )  IS
           l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
           l_contract_number              VARCHAR2(120);
           l_status                       VARCHAR2(80);
           --p_contract_status VARCHAR2(1):= '?';
           CURSOR okc_k_status_csr IS
 	           SELECT STE_CODE
	        FROM  OKC_K_HEADERS_V KHR , OKC_STATUSES_B OST
           WHERE  KHR.ID =  p_khr_id
              AND KHR.STS_CODE = OST.CODE ;


         BEGIN
           x_return_status := l_return_status;
           OPEN  okc_k_status_csr;
          	FETCH okc_k_status_csr INTO x_contract_status ;
            -- NEW
            IF ( okc_k_status_csr%NOTFOUND) THEN
                    -- Fix for 3745151
                   OKC_API.set_message('OKL',
	        	g_no_parent_record,
			g_col_name_token,
			'ste_code',
		 	g_child_table_token ,
			'OKC_K_HEADERS_V',
			g_parent_table_token ,
			'OKC_STATUSES_B');
            END IF;
           CLOSE okc_k_status_csr ;
          EXCEPTION
            WHEN OTHERS THEN
                -- store SQL error message on message stack for caller
                OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,
                       G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
       		-- notify caller of an UNEXPECTED error
       		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       		-- verify that cursor was closed
 		IF okc_k_status_csr%ISOPEN THEN
 		   CLOSE okc_k_status_csr;
 		END IF;
       END chk_contract_status;
-------------------------------------------------------------------------------
---------------------------------------------------------------------------
-- FUNCTION validate_khr_id
---------------------------------------------------------------------------
   FUNCTION validate_khr_id (
            p_ipyv_rec IN ipyv_rec_type
          ) RETURN VARCHAR2 IS
            l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
            l_khr_id 			 NUMBER	     :=  p_ipyv_rec.khr_id;
            l_dummy_var VARCHAR2(1) := '?';
            CURSOR okc_khr_csr IS
  	        SELECT 'x'
  	        FROM  OKL_K_HEADERS_V
         		WHERE  OKL_K_HEADERS_V.ID = l_khr_id;
          BEGIN
            OPEN  okc_khr_csr;
           	FETCH okc_khr_csr INTO l_dummy_var ;
            CLOSE okc_khr_csr ;
           	 		     	-- still set to default means data was not found
  	    IF ( l_dummy_var = '?' ) THEN
  	        OKC_API.set_message(g_app_name,
  	     			    p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'Contract Number');
  	     	l_return_status := OKC_API.G_RET_STS_ERROR;
  	     END IF;
           RETURN(l_return_status);
           EXCEPTION
             WHEN OTHERS THEN
                 -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        		-- notify caller of an UNEXPECTED error
        		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        		-- verify that cursor was closed
  		      IF okc_khr_csr%ISOPEN THEN
  		         CLOSE okc_khr_csr;
  		      END IF;
            	RETURN(l_return_status);
        END validate_khr_id;
--------------------------------------------
---------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name	: create_ins_streams
 -- Description		:It generates Insurance Streams based on passed Insurance record.
 -- Business Rules	:
 -- Parameters		:
 -- Version		: 1.0
 -- End of Comments
---------------------------------------------------------------------------
PROCEDURE   create_ins_streams(
            p_api_version                   IN NUMBER,
            p_init_msg_list                IN VARCHAR2 ,
            x_return_status                OUT NOCOPY VARCHAR2,
            x_msg_count                    OUT NOCOPY NUMBER,
            x_msg_data                     OUT NOCOPY VARCHAR2,
            p_ipyv_rec                     IN ipyv_rec_type
            )IS
         	l_stmv_rec			Okl_Streams_Pub.stmv_rec_type;
	l_row_notfound			BOOLEAN := TRUE;
	l_msg_count			NUMBER ;
	l_msg_data                      VARCHAR2(2000);
	l_api_version			CONSTANT NUMBER := 1;
        l_api_name			CONSTANT VARCHAR2(30) := 'create_ins_streams';
    	l_return_status			VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    	p_stmv_rec			Okl_Streams_Pub.stmv_rec_type;
	x_stmv_rec		        Okl_Streams_Pub.stmv_rec_type;
	p_selv_tbl			Okl_Streams_Pub.selv_tbl_type;
	x_selv_tbl			Okl_Streams_Pub.selv_tbl_type;
	x_khr_status			VARCHAR2 (30) ;
	l_khr_date_from			DATE ;
	l_khr_date_to			DATE ;
	l_ipyv_rec			Okl_Ipy_Pvt.ipyv_rec_type;
	l_khr_id			NUMBER;
   BEGIN
               l_ipyv_rec := p_ipyv_rec;
               l_khr_id	  := l_ipyv_rec.khr_id;
		l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
                                                          l_api_version,
                                                          p_api_version,
                                                          '_PROCESS',
                                                          l_return_status);
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
---------------------------------------------------------------------------
-- VALIDATE CONTRACT HEADER
---------------------------------------------------------------------------
   l_return_status := validate_khr_id(p_ipyv_rec);
  		----------------------

		---------------------------------
   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
-------------------------------------------------------------------------
---- Check for Status of Contract
---------------------------------------------------------------------------
  --l_return_status :=chk_contract_status(l_ipyv_rec.khr_id, x_khr_status);
    chk_contract_status(l_ipyv_rec.khr_id, x_khr_status,x_return_status);
    l_return_status := x_return_status;
   		----------------------

		---------------------------------
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
   IF (x_khr_status = 'CANCELED' ) OR (x_khr_status = 'DELETED' ) OR (x_khr_status = 'EXPIRED' ) THEN
      OKC_API.set_message(G_APP_NAME,'OKL_INS_K_NOT_ACTIVE' );
	  RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF ;
   -- get the contract term duration
    l_khr_id := l_ipyv_rec.khr_id;
   --l_return_status := get_insurance_term(l_khr_id,l_khr_date_from,l_khr_date_to,x_return_status);
     get_contract_term(l_khr_id,l_khr_date_from,l_khr_date_to,x_return_status);
     l_return_status := x_return_status;
      		----------------------

		---------------------------------
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
-------------------------------------------------------------------------
---- Check for date_to
---------------------------------------------------------------------------
l_return_status :=	validate_date_to(l_ipyv_rec.date_to);
      		----------------------

		---------------------------------
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
-------------------------------------------------------------------------
---- Check for date_from
---------------------------------------------------------------------------
l_return_status :=	validate_date_from(l_ipyv_rec.date_from);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
-------------------------------------------------------------------------
---- Check for term duration gretaer than or equal to Insurance duration
---------------------------------------------------------------------------
l_return_status:= validate_insurance_term(l_ipyv_rec.date_from,l_ipyv_rec.date_to,l_khr_date_from,l_khr_date_to);

     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
-------------------------------------------------------------------------
---- Check for Contract Line
---------------------------------------------------------------------------
l_return_status :=	validate_contract_line(p_ipyv_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
-----------------------------------------------------------------------
-- Check for valide Premium
----------------------------------------------------------------------
validate_amount_due(x_return_status => l_return_status,
                    p_ipyv_rec      => p_ipyv_rec);
                  -- NEW
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
---------------------------------------------------------------------
----------- generate stream
-------------------------------------------------------------------
-- SET values to retrieve record
p_stmv_rec.khr_id :=  p_ipyv_rec.khr_id ;
p_stmv_rec.kle_id :=  p_ipyv_rec.kle_id ;
-- nEW
BEGIN
    select OKL_SIF_SEQ.nextval INTO p_stmv_rec.transaction_number from dual;
--p_stmv_rec.transaction_number := OKL_SIF_SEQ.nextval();
--p_stmv_rec.sty_id := 236689050485873337900191164493000819371;
-- Removed after calling genarate _ins stream from genrate _insrecv_stream,generate_inspayb_stream
-- and so on where sty_id is retrieved depending on stream type


-- Begin : changes for Insurance user defined streams,  bug 3924300
                -- call to get the stream type id, change made for insurance user defined streams

                  OKL_STREAMS_UTIL.get_primary_stream_type(p_ipyv_rec.khr_id,
                                                   'INSURANCE_RECEIVABLE',
                                                   l_return_status,
                                                   p_stmv_rec.sty_id);

   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 OKC_API.set_message(G_APP_NAME,'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN,'INSURANCE_RECEIVABLE'); --bug 4024785
                 RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;


-- End : changes for Insurance user defined streams

-- nEW
EXCEPTION
          WHEN NO_DATA_FOUND THEN
                -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME,  'OKL_NO_STREAM_TYPE');
             WHEN OTHERS THEN
                 -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        		-- notify caller of an UNEXPECTED error
        		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        		-- verify that cursor was closed
  		END ;

p_stmv_rec.sgn_code := 'MANL';
p_stmv_rec.say_code := 'WORK';
p_stmv_rec.active_yn := 'N';
p_stmv_rec.date_working := SYSDATE;
 --  CHECK for PAYMENT Frequency  and call respective methods
 IF (p_ipyv_rec.ipf_code = 'LUMP_SUM') THEN
  l_return_status :=  genrt_lump_sum(p_ipyv_rec,x_selv_tbl);
 ELSIF (p_ipyv_rec.ipf_code = 'MONTHLY') THEN
  l_return_status :=  genrt_monthly(p_ipyv_rec,x_selv_tbl);
 ELSIF (p_ipyv_rec.ipf_code = 'BI_MONTHLY') THEN
  l_return_status :=  genrt_bi_monthly(p_ipyv_rec,x_selv_tbl);
 ELSIF (p_ipyv_rec.ipf_code = 'HALF_YEARLY') THEN
  l_return_status := genrt_half_yearly(p_ipyv_rec,x_selv_tbl);
 ELSIF (p_ipyv_rec.ipf_code = 'QUARTERLY') THEN
  l_return_status :=  genrt_quarterly(p_ipyv_rec,x_selv_tbl);
 ELSIF (p_ipyv_rec.ipf_code = 'YEARLY') THEN
  l_return_status := genrt_yearly(p_ipyv_rec,x_selv_tbl);
 --ELSIF (p_ipyv_rec.ipf_code = 'LEASE_FREQUENCY') THEN
  --l_return_status :=  genrt_lease_frequency(p_ipyv_rec,x_selv_tbl);
 END IF;

 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
 END IF;
   p_selv_tbl:=x_selv_tbl;
 IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
   -- Create Stream and Stream Elements
-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.create_streams
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;

  -- Bug 5408689 : Start
  IF(IS_DEBUG_PROCEDURE_ON)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(
       L_LEVEL_PROCEDURE
      ,L_MODULE
      ,'Begin Debug OKLRSULB.pls  call Okl_Streams_Util.round_streams_amount ' );
  END IF;
  l_return_status := Okl_Streams_Util.round_streams_amount(
                        p_api_version   => p_api_version
                       ,p_init_msg_list => p_init_msg_list
                       ,x_msg_count     => x_msg_count
                       ,x_msg_data      => x_msg_data
                       ,p_chr_id        => p_stmv_rec.khr_id
                       ,p_selv_tbl      => p_selv_tbl
                       ,x_selv_tbl      => x_selv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(
       L_LEVEL_PROCEDURE
      ,L_MODULE
      ,'End Debug OKLRSULB.pls  call Okl_Streams_Util.round_streams_amount');
  END IF;

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
  THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
  THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- Store Rounded Streams back into the p_selv_tbl
  p_selv_tbl:= x_selv_tbl;
  -- Bug 5408689 : End


  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call OKL_STREAMS_PUB.create_streams ');
    END;
  END IF;
   OKL_STREAMS_PUB.create_streams(
        p_api_version
       ,p_init_msg_list
       ,x_return_status
       ,x_msg_count
       ,x_msg_data
       ,p_stmv_rec
       ,p_selv_tbl
       ,x_stmv_rec
       ,x_selv_tbl
     );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call OKL_STREAMS_PUB.create_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.create_streams
      l_return_status := x_return_status ;

     	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
  	END IF;
  END IF;
EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
         END create_ins_streams ;

  ---------------------------------------------------------------------------
-- Start of comments
--
-- PROCEDURE Name	: create_contract_line
-- Description		:It creates contract line  contract item.
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
PROCEDURE create_contract_line(
         p_api_version                  IN NUMBER,
         p_init_msg_list                IN VARCHAR2 ,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_ipyv_rec                     IN ipyv_rec_type,
         x_kle_id 	 OUT NOCOPY NUMBER) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_contract_line';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_clev_rec			   okl_okc_migration_pvt.clev_rec_type;
    lx_clev_rec		       okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec			   Okl_Kle_Pvt.klev_rec_type ;
    lx_klev_rec		       Okl_Kle_Pvt.klev_rec_type ;
    l_cimv_rec		       OKC_CONTRACT_ITEM_PVT.cimv_rec_type ;
    lx_cimv_rec			   OKC_CONTRACT_ITEM_PVT.cimv_rec_type ;
    l_cvmv_rec             okl_version_pub.cvmv_rec_type;
	lx_cvmv_rec            okl_version_pub.cvmv_rec_type;
	l_khr_status           VARCHAR2(30) ;
    CURSOR l_okl_lse_id IS
    SELECT id
    FROM OKC_LINE_STYLES_b
    WHERE LTY_CODE = 'INSURANCE' ;

   -- Added for currency code
    CURSOR l_currency_code(p_khr_id NUMBER) IS
    SELECT CURRENCY_CODE
    FROM  OKC_K_HEADERS_B
    WHERE ID = p_khr_id ;


	BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                       G_PKG_NAME,
                                                      p_init_msg_list,
                                                      l_api_version,
                                                      p_api_version,
                                                      '_PROCESS',
                                                      x_return_status);
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

--------------------------------------------------
-- Get Currency Code
-----------------------------------------------------

            OPEN l_currency_code(p_ipyv_rec.KHR_ID) ;
            FETCH l_currency_code INTO l_clev_rec.CURRENCY_CODE ;
            CLOSE l_currency_code ;
            -- Removed message for 3745151

            /*
            IF( l_currency_code%NOTFOUND) THEN
                 	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> 'OKL_INVALID_CONTRACT');
            END IF;
           */


---------------------------------------------------------------------------
			-- Set Values in OKC_CONTRACT_LINE
---------------------------------------------------------------------------
            l_clev_rec.sfwt_flag  := 'N';
			l_clev_rec.object_version_number := 1 ;
			l_clev_rec.chr_id   :=  p_ipyv_rec.KHR_ID ;
            OPEN l_okl_lse_id ;
            FETCH l_okl_lse_id INTO l_clev_rec.lse_id ;
            IF( l_okl_lse_id%NOTFOUND) THEN
                 	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> 'OKL_LLA_LSE_ID'); -- Fix for 3745151
            END IF;
            CLOSE l_okl_lse_id ;

            -------------------------------------------------------------------------
	       ---- Check for Status of Contract
	        ---------------------------------------------------------------------------
	    	l_return_status :=	get_contract_status(p_ipyv_rec.khr_id, l_khr_status);

	        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	           RAISE OKC_API.G_EXCEPTION_ERROR;
	        END IF;
	       IF (l_khr_status = 'ACTIVE' ) THEN
	            l_cvmv_rec.chr_id := p_ipyv_rec.khr_id;
	            --Procedures pertaining to versioning a contract
-- Start of wraper code generated automatically by Debug code generator for OKL_VERSION_PUB.version_contract
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call OKL_VERSION_PUB.version_contract ');
    END;
  END IF;
	            OKL_VERSION_PUB.version_contract(  p_api_version	=> l_api_version ,
	    			 		p_init_msg_list           => OKC_API.G_FALSE,
	    					x_return_status      => l_return_status    ,
	    					x_msg_count           => x_msg_count,
	    					x_msg_data            => x_msg_data ,
	    					p_cvmv_rec        =>  l_cvmv_rec,
	                            		p_commit	=>	OKC_API.G_FALSE,
	                            		x_cvmv_rec	=> lx_cvmv_rec
	    					);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call OKL_VERSION_PUB.version_contract ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_VERSION_PUB.version_contract

	       END IF ;



  		l_clev_rec.line_number := 1;
  		l_clev_rec.sts_code :=  'NEW';
		l_clev_rec.dnz_chr_id   := p_ipyv_rec.khr_id;
  		l_clev_rec.display_sequence := 1;
  		l_clev_rec.exception_yn := 'Y';
        l_clev_rec.START_DATE := p_ipyv_rec.DATE_FROM  ;
        l_clev_rec.END_DATE :=  p_ipyv_rec.DATE_TO;

---------------------------------------------------------------------------
			-- Set Values in OKL_CONTRACT_LINE
---------------------------------------------------------------------------
			l_klev_rec.OBJECT_VERSION_NUMBER := 1 ;
			l_klev_rec.DATE_ACCEPTED := SYSDATE  ;

		  Okl_Contract_Pub.create_contract_line
		   (
    	   	   p_api_version      => l_api_version ,
		   p_init_msg_list           => OKC_API.G_FALSE,
		   x_return_status      => l_return_status    ,
		   x_msg_count           => x_msg_count,
		   x_msg_data            => x_msg_data ,
		   p_clev_rec            => l_clev_rec  ,
		   p_klev_rec            => l_klev_rec,
		   x_clev_rec            => lx_clev_rec,
		   x_klev_rec            => lx_klev_rec
		   );

		   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
		   l_cimv_rec.object_version_number := 1;
  		   l_cimv_rec.cle_id := lx_clev_rec.ID ;
		   l_cimv_rec.dnz_chr_id  := p_ipyv_rec.KHR_ID ;
  		   l_cimv_rec.chr_id  := p_ipyv_rec.KHR_ID ;
		   l_cimv_rec.object1_id1 := p_ipyv_rec.ID ;
		   l_cimv_rec.object1_id2 := '#' ;
  		   l_cimv_rec.jtot_object1_code := 'OKL_INPOLICY';
		   l_cimv_rec.exception_yn  := 'N';

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

          okl_la_validation_util_pvt.VALIDATE_STYLE_JTOT (p_api_version    => l_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => l_return_status,
                                                          x_msg_count	   => x_msg_count,
                                                          x_msg_data	   => x_msg_data,
                                                          p_object_name    => l_cimv_rec.jtot_object1_code,
                                                          p_id1            => l_cimv_rec.object1_id1,
                                                          p_id2            => l_cimv_rec.object1_id2);
	    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

----  Changes End


           	 OKC_CONTRACT_ITEM_PUB.create_contract_item(p_api_version	=> l_api_version ,
			 								p_init_msg_list           => OKC_API.G_FALSE,
											x_return_status      => l_return_status    ,
											x_msg_count           => x_msg_count,
											x_msg_data            => x_msg_data ,
                              				p_cimv_rec	=>	l_cimv_rec,
                              				x_cimv_rec	=> lx_cimv_rec
							  				);
	    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
   		 x_kle_id := lx_klev_rec.ID ;
      	 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
END create_contract_line;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INS_POLICIES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ipyv_rec                     IN ipyv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ipyv_rec_type IS
    CURSOR okl_ipyv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ADJUSTMENT,
            CALCULATED_PREMIUM,
            OBJECT_VERSION_NUMBER,
            AGENCY_NUMBER,
            SFWT_FLAG,
            IPF_CODE,
            INT_ID,
            KHR_ID,
            ISU_ID,
            IPT_ID,
            IPY_ID,
            IPE_CODE,
            CRX_CODE,
            AGENCY_SITE_ID,
            ISS_CODE,
            KLE_ID,
            AGENT_SITE_ID,
            IPY_TYPE,
            POLICY_NUMBER,
            QUOTE_YN,
            ENDORSEMENT,
            INSURANCE_FACTOR,
            FACTOR_CODE,
            COVERED_AMOUNT,
            ADJUSTED_BY_ID,
            FACTOR_VALUE,
            DATE_QUOTED,
            SALES_REP_ID,
            DATE_PROOF_REQUIRED,
            DATE_QUOTE_EXPIRY,
            DEDUCTIBLE,
            PAYMENT_FREQUENCY,
            DATE_PROOF_PROVIDED,
            DATE_FROM,
            NAME_OF_INSURED,
            DATE_TO,
            DESCRIPTION,
            ON_FILE_YN,
            PREMIUM,
            COMMENTS,
            ACTIVATION_DATE,
            PRIVATE_LABEL_YN,
            LESSOR_INSURED_YN,
            LESSOR_PAYEE_YN,
            CANCELLATION_DATE,
            CANCELLATION_COMMENT,
            AGENT_YN,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            TERRITORY_CODE
      FROM Okl_Ins_Policies_V
     WHERE okl_ins_policies_v.id = p_id;
    l_okl_ipyv_pk                  okl_ipyv_pk_csr%ROWTYPE;
    l_ipyv_rec                     ipyv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ipyv_pk_csr (p_ipyv_rec.id);
    FETCH okl_ipyv_pk_csr INTO
              l_ipyv_rec.ID,
              l_ipyv_rec.ADJUSTMENT,
              l_ipyv_rec.CALCULATED_PREMIUM,
              l_ipyv_rec.OBJECT_VERSION_NUMBER,
              l_ipyv_rec.AGENCY_NUMBER,
              l_ipyv_rec.SFWT_FLAG,
              l_ipyv_rec.IPF_CODE,
              l_ipyv_rec.INT_ID,
              l_ipyv_rec.KHR_ID,
              l_ipyv_rec.ISU_ID,
              l_ipyv_rec.IPT_ID,
              l_ipyv_rec.IPY_ID,
              l_ipyv_rec.IPE_CODE,
              l_ipyv_rec.CRX_CODE,
              l_ipyv_rec.AGENCY_SITE_ID,
              l_ipyv_rec.ISS_CODE,
              l_ipyv_rec.KLE_ID,
              l_ipyv_rec.AGENT_SITE_ID,
              l_ipyv_rec.IPY_TYPE,
              l_ipyv_rec.POLICY_NUMBER,
              l_ipyv_rec.QUOTE_YN,
              l_ipyv_rec.ENDORSEMENT,
              l_ipyv_rec.INSURANCE_FACTOR,
              l_ipyv_rec.FACTOR_CODE,
              l_ipyv_rec.COVERED_AMOUNT,
              l_ipyv_rec.ADJUSTED_BY_ID,
              l_ipyv_rec.FACTOR_VALUE,
              l_ipyv_rec.DATE_QUOTED,
              l_ipyv_rec.SALES_REP_ID,
              l_ipyv_rec.DATE_PROOF_REQUIRED,
              l_ipyv_rec.DATE_QUOTE_EXPIRY,
              l_ipyv_rec.DEDUCTIBLE,
              l_ipyv_rec.PAYMENT_FREQUENCY,
              l_ipyv_rec.DATE_PROOF_PROVIDED,
              l_ipyv_rec.DATE_FROM,
              l_ipyv_rec.NAME_OF_INSURED,
              l_ipyv_rec.DATE_TO,
              l_ipyv_rec.DESCRIPTION,
              l_ipyv_rec.ON_FILE_YN,
              l_ipyv_rec.PREMIUM,
              l_ipyv_rec.COMMENTS,
              l_ipyv_rec.ACTIVATION_DATE,
              l_ipyv_rec.PRIVATE_LABEL_YN,
              l_ipyv_rec.LESSOR_INSURED_YN,
              l_ipyv_rec.LESSOR_PAYEE_YN,
              l_ipyv_rec.CANCELLATION_DATE,
              l_ipyv_rec.CANCELLATION_COMMENT,
              l_ipyv_rec.AGENT_YN,
              l_ipyv_rec.ATTRIBUTE_CATEGORY,
              l_ipyv_rec.ATTRIBUTE1,
              l_ipyv_rec.ATTRIBUTE2,
              l_ipyv_rec.ATTRIBUTE3,
              l_ipyv_rec.ATTRIBUTE4,
              l_ipyv_rec.ATTRIBUTE5,
              l_ipyv_rec.ATTRIBUTE6,
              l_ipyv_rec.ATTRIBUTE7,
              l_ipyv_rec.ATTRIBUTE8,
              l_ipyv_rec.ATTRIBUTE9,
              l_ipyv_rec.ATTRIBUTE10,
              l_ipyv_rec.ATTRIBUTE11,
              l_ipyv_rec.ATTRIBUTE12,
              l_ipyv_rec.ATTRIBUTE13,
              l_ipyv_rec.ATTRIBUTE14,
              l_ipyv_rec.ATTRIBUTE15,
              l_ipyv_rec.ORG_ID,
              l_ipyv_rec.REQUEST_ID,
              l_ipyv_rec.PROGRAM_APPLICATION_ID,
              l_ipyv_rec.PROGRAM_ID,
              l_ipyv_rec.PROGRAM_UPDATE_DATE,
              l_ipyv_rec.CREATED_BY,
              l_ipyv_rec.CREATION_DATE,
              l_ipyv_rec.LAST_UPDATED_BY,
              l_ipyv_rec.LAST_UPDATE_DATE,
              l_ipyv_rec.LAST_UPDATE_LOGIN,
              l_ipyv_rec.TERRITORY_CODE;
    x_no_data_found := okl_ipyv_pk_csr%NOTFOUND;
    CLOSE okl_ipyv_pk_csr;
    RETURN(l_ipyv_rec);
  END get_rec;
  FUNCTION get_rec (
    p_ipyv_rec       IN ipyv_rec_type
  ) RETURN ipyv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ipyv_rec, l_row_notfound));
  END get_rec;
-----------------------------------------------------------------------------------
  PROCEDURE accept_lease_quote(
         p_api_version                  IN NUMBER,
         p_init_msg_list                IN VARCHAR2 ,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_quote_id                     IN NUMBER,
         x_policy_number 	 OUT NOCOPY VARCHAR2) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'accept_lease_quote';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_quote_type                   VARCHAR2(30);
    l_ipyv_rec 			           ipyv_rec_type ;
    l_inqv_rec                     ipyv_rec_type ;
	lx_inqv_rec                    ipyv_rec_type ;
    lx_ipyv_rec                   ipyv_rec_type ;
    l_row_notfound    BOOLEAN := TRUE ;
	l_kle_id          NUMBER ;


  --3379317 Modified by smoduga added new parameter p_to_date
   CURSOR C_accepted_policy_exist ( p_khr_id NUMBER ,  p_date DATE,p_to_date DATE) IS
          select 'x'
          FROM OKL_INS_POLICIES_B IPYB
          WHERE IPYB.IPY_TYPE = 'LEASE_POLICY'
          AND IPYB.ISS_CODE IN ('ACCEPTED', 'PENDING')
          AND IPYB.KHR_ID  = p_khr_id
          AND (p_date BETWEEN  IPYB.DATE_FROM  AND IPYB.DATE_TO
               OR IPYB.DATE_FROM between p_date and p_to_date);

	l_dummy           VARCHAR2(1);
  --3379317 Modified by smoduga added new parameter p_to_date
      CURSOR C_policy_exist ( p_khr_id NUMBER ,  p_date DATE,p_to_date DATE) IS
          SELECT 'x'
         FROM   OKL_INS_POLICIES_B OIPB
         WHERE  OIPB.KHR_ID = p_khr_id AND
            OIPB.IPY_TYPE = 'LEASE_POLICY' AND
            OIPB.QUOTE_YN = 'N' AND
            OIPB.ISS_CODE = 'ACTIVE' AND
            (p_date BETWEEN  OIPB.DATE_FROM  AND OIPB.DATE_TO
             OR OIPB.DATE_FROM BETWEEN p_date and p_to_date);




	FUNCTION insert_policy_assets (
              l_inqv_rec               IN   ipyv_rec_type,
              policyid                 IN   NUMBER
            ) RETURN VARCHAR2 IS
		CURSOR okl_inav_pk_csr (p_id       NUMBER) IS
	     SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            IPY_ID,
            KLE_ID,
            ASSET_PREMIUM,
            LESSOR_PREMIUM,
			CALCULATED_PREMIUM,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
			ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_INS_ASSETS
     WHERE OKL_INS_ASSETS.IPY_ID  = p_id;
	 l_okl_inav_pk_csr    okl_inav_pk_csr%ROWTYPE;
    l_inav_rec                     inav_rec_type;
	lx_inav_rec                     inav_rec_type;
  BEGIN
--    x_no_data_found := TRUE;
    -- Get current database values

      OPEN okl_inav_pk_csr (l_inqv_rec.ID)	;
	  LOOP
       FETCH okl_inav_pk_csr INTO l_okl_inav_pk_csr;
	      EXIT WHEN okl_inav_pk_csr%NOTFOUND;
              l_inav_rec.ID := l_okl_inav_pk_csr.ID ;
              l_inav_rec.OBJECT_VERSION_NUMBER := l_okl_inav_pk_csr.OBJECT_VERSION_NUMBER ;
              l_inav_rec.IPY_ID  := policyid ;
              l_inav_rec.KLE_ID  := l_okl_inav_pk_csr.KLE_ID ;
              l_inav_rec.ASSET_PREMIUM  := l_okl_inav_pk_csr.ASSET_PREMIUM ;
			  l_inav_rec.CALCULATED_PREMIUM  := l_okl_inav_pk_csr.CALCULATED_PREMIUM ;
              l_inav_rec.LESSOR_PREMIUM  := l_okl_inav_pk_csr.LESSOR_PREMIUM ;
              l_inav_rec.ATTRIBUTE_CATEGORY  := l_okl_inav_pk_csr.ATTRIBUTE_CATEGORY ;
              l_inav_rec.ATTRIBUTE1  := l_okl_inav_pk_csr.ATTRIBUTE1 ;
              l_inav_rec.ATTRIBUTE2  := l_okl_inav_pk_csr.ATTRIBUTE2 ;
              l_inav_rec.ATTRIBUTE3  := l_okl_inav_pk_csr.ATTRIBUTE3 ;
              l_inav_rec.ATTRIBUTE4  := l_okl_inav_pk_csr.ATTRIBUTE4 ;
              l_inav_rec.ATTRIBUTE5  := l_okl_inav_pk_csr.ATTRIBUTE5 ;
              l_inav_rec.ATTRIBUTE6  := l_okl_inav_pk_csr.ATTRIBUTE6 ;
              l_inav_rec.ATTRIBUTE7  := l_okl_inav_pk_csr.ATTRIBUTE7 ;
              l_inav_rec.ATTRIBUTE8  := l_okl_inav_pk_csr.ATTRIBUTE8 ;
              l_inav_rec.ATTRIBUTE9  := l_okl_inav_pk_csr.ATTRIBUTE9 ;
              l_inav_rec.ATTRIBUTE10  := l_okl_inav_pk_csr.ATTRIBUTE10 ;
              l_inav_rec.ATTRIBUTE11  := l_okl_inav_pk_csr.ATTRIBUTE11 ;
              l_inav_rec.ATTRIBUTE12  := l_okl_inav_pk_csr.ATTRIBUTE12 ;
              l_inav_rec.ATTRIBUTE13  := l_okl_inav_pk_csr.ATTRIBUTE13 ;
              l_inav_rec.ATTRIBUTE14  := l_okl_inav_pk_csr.ATTRIBUTE14 ;
              l_inav_rec.ATTRIBUTE15  := l_okl_inav_pk_csr.ATTRIBUTE15 ;

	SELECT DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
             DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
             DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
             DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
             MO_GLOBAL.GET_CURRENT_ORG_ID()
             INTO l_inav_rec.REQUEST_ID,
                                                                 l_inav_rec.PROGRAM_APPLICATION_ID,
                                                                 l_inav_rec.PROGRAM_ID,
                                                                 l_inav_rec.PROGRAM_UPDATE_DATE,
                                                           	 	 l_inav_rec.org_id FROM dual;
              l_inav_rec.CREATED_BY := l_okl_inav_pk_csr.CREATED_BY ;
              l_inav_rec.CREATION_DATE := l_okl_inav_pk_csr.CREATION_DATE ;
              l_inav_rec.LAST_UPDATED_BY := l_okl_inav_pk_csr.LAST_UPDATED_BY ;
              l_inav_rec.LAST_UPDATE_DATE := l_okl_inav_pk_csr.LAST_UPDATE_DATE ;
              l_inav_rec.LAST_UPDATE_LOGIN := l_okl_inav_pk_csr.LAST_UPDATE_LOGIN ;
-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Assets_Pub.insert_ins_assets
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call Okl_Ins_Assets_Pub.insert_ins_assets ');
    END;
  END IF;
		Okl_Ins_Assets_Pub.insert_ins_assets(
	          p_api_version                  => p_api_version,
          	  p_init_msg_list                => OKC_API.G_FALSE,
          	  x_return_status                => l_return_status,
              x_msg_count                    => x_msg_count,
              x_msg_data                     => x_msg_data,
              p_inav_rec                     => l_inav_rec,
              x_inav_rec                     => lx_inav_rec
          		);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call Okl_Ins_Assets_Pub.insert_ins_assets ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Assets_Pub.insert_ins_assets
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	  	    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	  	    RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
	END LOOP ;
  --     x_no_data_found := okl_inav_pk_csr%NOTFOUND;
      CLOSE okl_inav_pk_csr;
	    RETURN(l_return_status);
    END insert_policy_assets;
    FUNCTION get_lease_policy (
              l_inqv_rec               IN   ipyv_rec_type
            ) RETURN ipyv_rec_type IS
              l_ipyv_rec 			   ipyv_rec_type ;
              l_seq                    NUMBER ;
              l_policy_symbol          VARCHAR2(10) ;
              CURSOR c_policy_symbol IS
              SELECT POLICY_SYMBOL
               FROM OKL_INS_PRODUCTS_B
               WHERE id = l_ipyv_rec.ipt_id;
            BEGIN
            l_ipyv_rec := l_inqv_rec ;
                    BEGIN
                      SELECT OKL_IPY_SEQ.NEXTVAL INTO l_seq FROM dual;
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        -- store SQL error message on message stack for caller
                       OKC_API.set_message(G_APP_NAME,  'OKL_NO_SEQUENCE'  );
                    WHEN OTHERS THEN
                    -- store SQL error message on message stack for caller
                    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        		      -- notify caller of an UNEXPECTED error
        		      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        		      -- verify that cursor was closed
  		            END ;
               OPEN c_policy_symbol;
               FETCH c_policy_symbol INTO l_policy_symbol ;
                  IF( c_policy_symbol%NOTFOUND) THEN
                 	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> G_INVALID_VALUE,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'Policy Symbol');
                   END IF;
               close c_policy_symbol ;
			l_ipyv_rec.POLICY_NUMBER := l_policy_symbol || TO_CHAR(l_seq) ;
	        l_ipyv_rec.object_version_number := 1 ;
	        l_ipyv_rec.ISS_CODE := 'ACCEPTED';
	        l_ipyv_rec.QUOTE_YN  := 'N' ;
	        l_ipyv_rec.DATE_QUOTED := OKC_API.G_MISS_DATE ;
	        l_ipyv_rec.DATE_QUOTE_EXPIRY := OKC_API.G_MISS_DATE ;
			  SELECT DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
             DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
             DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
             DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
             MO_GLOBAL.GET_CURRENT_ORG_ID()
             INTO l_ipyv_rec.REQUEST_ID,
                                                                 l_ipyv_rec.PROGRAM_APPLICATION_ID,
                                                                 l_ipyv_rec.PROGRAM_ID,
                                                                 l_ipyv_rec.PROGRAM_UPDATE_DATE,
                                                           	 l_ipyv_rec.org_id FROM dual;
	        l_ipyv_rec.created_by          :=   OKC_API.G_MISS_NUM;
	        l_ipyv_rec.creation_date       := OKC_API.G_MISS_DATE ;
	        l_ipyv_rec.last_updated_by     :=   OKC_API.G_MISS_NUM;
	        l_ipyv_rec.last_update_date    := OKC_API.G_MISS_DATE ;
            l_ipyv_rec.last_update_login   :=   OKC_API.G_MISS_NUM;
              	RETURN(l_ipyv_rec);
          END get_lease_policy;
     BEGIN
          l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                     G_PKG_NAME,
                                                    p_init_msg_list,
                                                    l_api_version,
                                                    p_api_version,
                                                    '_PROCESS',
                                                    x_return_status);
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

          -- Assigning ID to record
          l_inqv_rec.id := p_quote_id ;

          -- Get the current quote from database
      	  l_inqv_rec := get_rec(l_inqv_rec);

          -- KHR id check to get validate record



          -- New Validation for one accepted Policy only

        BEGIN
         l_dummy := '?' ;
  --3379317 Modified by smoduga added new parameter p_to_date
         OPEN    C_accepted_policy_exist (l_inqv_rec.KHR_ID ,l_inqv_rec.DATE_FROM,l_inqv_rec.DATE_TO) ;
         FETCH  C_accepted_policy_exist INTO l_dummy ;
         CLOSE  C_accepted_policy_exist ;
              EXCEPTION
                    WHEN OTHERS THEN
                    -- store SQL error message on message stack for caller
                     OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        		      -- notify caller of an UNEXPECTED error
        		      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                      RAISE G_EXCEPTION_HALT_VALIDATION ;
        		      -- verify that cursor was closed
      	 END ;
            IF   ( l_dummy = 'x') THEN
               OKC_API.set_message(G_APP_NAME, 'OKL_ACCEPTED_POLICY_EXIST' );
        		      -- notify caller of an UNEXPECTED error
        		      l_return_status := OKC_API.G_RET_STS_ERROR;
                     RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
		  -- Validate whether it is accetable quote or not
		/*
		      1. Quote should not be expired
		      2. Status of Quote should be quote
          	      3. It should not be Third party policy
	        */
		   -- Check for Status
		   IF (l_inqv_rec.ISS_CODE <> 'QUOTE' AND l_inqv_rec.QUOTE_YN <> 'Y'  ) THEN
		      OKC_API.set_message(G_APP_NAME,
	               	G_INVALID_QUOTE );
                RAISE OKC_API.G_EXCEPTION_ERROR;
           	END IF;

			-- Quote should not be expired
		   IF (l_inqv_rec.DATE_QUOTE_EXPIRY < SYSDATE ) THEN
		      OKC_API.set_message(G_APP_NAME,
	               	G_EXPIRED_QUOTE );
               RAISE OKC_API.G_EXCEPTION_ERROR;
			END IF;
       ------------------------------------------------------------------------
      -- Check for Lease Policy
      ------------------------------------------------------------------------
      BEGIN
         l_dummy := '?' ;
  --3379317 Modified by smoduga added new parameter p_to_date
         OPEN    C_policy_exist (l_inqv_rec.KHR_ID ,l_inqv_rec.DATE_FROM,l_inqv_rec.DATE_TO) ;
         FETCH  C_policy_exist INTO l_dummy ;
         CLOSE  C_policy_exist ;
              EXCEPTION
                    WHEN OTHERS THEN
                    -- store SQL error message on message stack for caller
                     OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        		      -- notify caller of an UNEXPECTED error
        		      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                      RAISE G_EXCEPTION_HALT_VALIDATION ;
        		      -- verify that cursor was closed
  		            END ;
            IF   ( l_dummy = 'x') THEN
               OKC_API.set_message(G_APP_NAME, 'OKL_POLICY_EXIST' );
        		      -- notify caller of an UNEXPECTED error
        		      l_return_status := OKC_API.G_RET_STS_ERROR;
                     RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

			-- Check for Third Party is taken care in deciding policy type
         -- Make Policy related changes
         l_ipyv_rec := get_lease_policy(l_inqv_rec);

          -- Insert Policy
-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.insert_ins_policies
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.insert_ins_policies ');
    END;
  END IF;
          Okl_Ins_Policies_Pub.insert_ins_policies(
         p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ipyv_rec                     => l_ipyv_rec,
          x_ipyv_rec                     => lx_ipyv_rec
          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.insert_ins_policies ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.insert_ins_policies

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	  	RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_ipyv_rec.id := lx_ipyv_rec.id ;
	-- Insert Assets
	 l_return_status :=  insert_policy_assets(l_inqv_rec,lx_ipyv_rec.ID );

	  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	  	RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
	  -- Create Line
	create_contract_line(
         p_api_version                  => l_api_version,
         p_init_msg_list                => Okc_Api.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_ipyv_rec                     => l_ipyv_rec,
         x_kle_id 		                => l_kle_id );

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	  	RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
	  l_ipyv_rec.KLE_ID := l_kle_id ;
    -- Create Stream
              create_ins_streams(
         p_api_version                    => l_api_version,
         p_init_msg_list                => Okc_Api.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_ipyv_rec                     => l_ipyv_rec
         );

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN

	  	RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      create_insinc_streams(
         p_api_version                    => l_api_version,
         p_init_msg_list                => Okc_Api.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_ipyv_rec                     => l_ipyv_rec
        );

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	  	RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
      Okl_Ins_Policies_Pub.update_ins_policies(
	         p_api_version                  => p_api_version,
	          p_init_msg_list                => OKC_API.G_FALSE,
	          x_return_status                => l_return_status,
	          x_msg_count                    => x_msg_count,
	          x_msg_data                     => x_msg_data,
	          p_ipyv_rec                     => l_ipyv_rec,
	          x_ipyv_rec                     => lx_ipyv_rec
	          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies
   	          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

		  	  	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		  	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN

		  	     RAISE OKC_API.G_EXCEPTION_ERROR;
	          END IF;
              l_ipyv_rec := lx_ipyv_rec ;
     -- activate stream
	 	 	activate_ins_stream(
	          p_api_version                    => l_api_version,
	          p_init_msg_list                => Okc_Api.G_FALSE,
	          x_return_status                => l_return_status,
	          x_msg_count                    => x_msg_count,
	          x_msg_data                     => x_msg_data,
	          p_ipyv_rec                     => l_ipyv_rec
	          );

	       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

	 	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	 	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN

	 	  	RAISE OKC_API.G_EXCEPTION_ERROR;
		  ELSIF	(l_return_status = G_NOT_ACTIVE) THEN
            -- Need to take care
			  NULL;
          --ELSE

          END IF;

			  -- update quote
          -- Put Policy Number in Quote record
          l_inqv_rec.IPY_ID := lx_ipyv_rec.ID;
-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
          Okl_Ins_Policies_Pub.update_ins_policies(
	      p_api_version                  => p_api_version,
	      p_init_msg_list                => OKC_API.G_FALSE,
	      x_return_status                => l_return_status,
	      x_msg_count                    => x_msg_count,
	      x_msg_data                     => x_msg_data,
	      p_ipyv_rec                     => l_inqv_rec,
	      x_ipyv_rec                     => lx_inqv_rec   	);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies

          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

		  	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN

	  	       RAISE OKC_API.G_EXCEPTION_ERROR;
	      END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
      EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
          x_return_status := OKC_API.HANDLE_EXCEPTIONS
          (
            l_api_name,
            G_PKG_NAME,
            'OKC_API.G_RET_STS_ERROR',
            x_msg_count,
            x_msg_data,
            '_PROCESS'
          );
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          x_return_status :=OKC_API.HANDLE_EXCEPTIONS
          (
            l_api_name,
            G_PKG_NAME,
            'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count,
            x_msg_data,
            '_PROCESS'
          );
        WHEN OTHERS THEN
          x_return_status :=OKC_API.HANDLE_EXCEPTIONS
          (
            l_api_name,
            G_PKG_NAME,
            'OTHERS',
            x_msg_count,
            x_msg_data,
            '_PROCESS'
          );
  END accept_lease_quote;
-------------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE save_quote
  ---------------------------------------------------------------------------
    PROCEDURE save_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     px_ipyv_rec                     IN OUT NOCOPY  ipyv_rec_type,
     x_message                      OUT NOCOPY  VARCHAR2  )IS
     l_msg_count                   NUMBER ;
     l_msg_data                      VARCHAR2(2000);
     l_api_version                 CONSTANT NUMBER := 1;
     l_api_name                     CONSTANT VARCHAR2(30) := 'save_quote';
     l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     p_contract_id                 NUMBER ;
     l_ipyv_rec            Okl_Ins_Policies_Pub.ipyv_rec_type ;
     lx_ipyv_rec           Okl_Ins_Policies_Pub.ipyv_rec_type ;
     l_iasset_tbl  	   iasset_tbl_type ;
     l_message      	   VARCHAR2(200);
     l_inav_tbl            Okl_Ina_Pvt.inav_tbl_type;
     lx_inav_tbl           Okl_Ina_Pvt.inav_tbl_type;
     l_seq                    NUMBER ;
     l_policy_symbol          VARCHAR2(10) ;
      CURSOR c_policy_symbol(product_id NUMBER) IS
       SELECT POLICY_SYMBOL , FACTOR_NAME ,FACTOR_CODE
          FROM OKL_INS_PRODUCTS_V
          WHERE id = product_id;
	 BEGIN
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       l_return_status := OKC_API.START_ACTIVITY(l_api_name, G_PKG_NAME,
                                            p_init_msg_list,l_api_version,
                                            p_api_version,'_PROCESS',
                                                      l_return_status);
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status := l_return_status ;
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              x_return_status := l_return_status ;
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
            x_message := '1';
		   l_ipyv_rec := px_ipyv_rec ;

		   l_ipyv_rec.date_proof_provided := OKC_API.G_MISS_DATE ;
		   l_ipyv_rec.date_proof_required := OKC_API.G_MISS_DATE ;
		   l_ipyv_rec.cancellation_date := OKC_API.G_MISS_DATE ;
                   l_ipyv_rec.activation_date := OKC_API.G_MISS_DATE ;


   -- For Optional Insurance
	IF (l_ipyv_rec.ipy_type = 'OPTIONAL_POLICY' ) THEN

			l_ipyv_rec.SFWT_FLAG := 'T' ;
			         -- Policy Number // Quote Number generation
            BEGIN
              SELECT OKL_IPY_SEQ.NEXTVAL INTO l_seq FROM dual;
             EXCEPTION
          WHEN NO_DATA_FOUND THEN
                -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME,  'OKL_NO_SEQUENCE'  );
             WHEN OTHERS THEN
                 -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        		-- notify caller of an UNEXPECTED error
        		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        		-- verify that cursor was closed
  		   END ;
             OPEN c_policy_symbol (l_ipyv_rec.IPT_ID) ;
             FETCH  c_policy_symbol INTO l_policy_symbol, l_ipyv_rec.INSURANCE_FACTOR,l_ipyv_rec.FACTOR_CODE ;
             --
              -- Take Care of Policy Symbol
             ---
             close  c_policy_symbol ;
	    l_ipyv_rec.POLICY_NUMBER := l_policy_symbol || TO_CHAR(l_seq) ;
	    l_ipyv_rec.QUOTE_YN := 'Y' ;
	    l_ipyv_rec.ISS_CODE := 'QUOTE' ;
            IF (l_ipyv_rec.ADJUSTMENT IS NULL OR l_ipyv_rec.ADJUSTMENT = OKC_API.G_MISS_NUM) THEN
               l_ipyv_rec.ADJUSTMENT := 0 ;
            END IF;
            l_ipyv_rec.PREMIUM := l_ipyv_rec.CALCULATED_PREMIUM + l_ipyv_rec.ADJUSTMENT ;
             x_message := px_ipyv_rec.ADJUSTMENT;
-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.insert_ins_policies
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.insert_ins_policies ');
    END;
  END IF;
           Okl_Ins_Policies_Pub.insert_ins_policies(
           p_api_version                  => l_api_version,
           p_init_msg_list                => OKC_API.G_FALSE,
           x_return_status                => l_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_ipyv_rec                     => l_ipyv_rec,
           x_ipyv_rec                     => lx_ipyv_rec
          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.insert_ins_policies ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.insert_ins_policies

	      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status := l_return_status ;
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              x_return_status := l_return_status ;
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
          px_ipyv_rec.ID :=   lx_ipyv_rec.ID;
  -- For Lease Insurance
     ELSIF (l_ipyv_rec.ipy_type = 'LEASE_POLICY' ) THEN
		calc_lease_premium(
         p_api_version                   =>l_api_version,
    	 p_init_msg_list                => Okc_Api.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    =>  x_msg_count,
         x_msg_data                     => x_msg_data,
         px_ipyv_rec                     => l_ipyv_rec,
         x_message                      => l_message,
        x_iasset_tbl                  => l_iasset_tbl );
                     x_message := '2';

    	 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status ;
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
               x_return_status := l_return_status ;
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
             x_message := '3';
	     l_ipyv_rec.SFWT_FLAG := 'T' ;
            l_ipyv_rec.deductible := 0 ;
            -- Policy Number // Quote Number generation
            BEGIN
              SELECT OKL_IPY_SEQ.NEXTVAL INTO l_seq FROM dual;
             EXCEPTION
          WHEN NO_DATA_FOUND THEN
                -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME,  'OKL_NO_SEQUENCE'  );
             WHEN OTHERS THEN
                 -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        		-- notify caller of an UNEXPECTED error
        		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        		-- verify that cursor was closed
  		   END ;
             OPEN c_policy_symbol (l_ipyv_rec.IPT_ID) ;
             FETCH  c_policy_symbol INTO l_policy_symbol , l_ipyv_rec.INSURANCE_FACTOR,l_ipyv_rec.FACTOR_CODE;
             ---Need to check for No Data Founf
             close  c_policy_symbol ;
             l_ipyv_rec.POLICY_NUMBER := l_policy_symbol || TO_CHAR(l_seq) ;
	     l_ipyv_rec.QUOTE_YN := 'Y' ;
	     l_ipyv_rec.ISS_CODE := 'QUOTE' ;

	     IF (px_ipyv_rec.ADJUSTMENT IS NULL OR px_ipyv_rec.ADJUSTMENT = OKC_API.G_MISS_NUM) THEN
	         l_ipyv_rec.ADJUSTMENT := 0 ;
	     ELSE
	       l_ipyv_rec.ADJUSTMENT  := px_ipyv_rec.ADJUSTMENT;
	     END IF;
            l_ipyv_rec.PREMIUM := l_ipyv_rec.CALCULATED_PREMIUM + l_ipyv_rec.ADJUSTMENT ;

             x_message := px_ipyv_rec.ADJUSTMENT;
-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.insert_ins_policies
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.insert_ins_policies ');
    END;
  END IF;
           Okl_Ins_Policies_Pub.insert_ins_policies(
           p_api_version                  => l_api_version,
           p_init_msg_list                => OKC_API.G_FALSE,
           x_return_status                => l_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_ipyv_rec                     => l_ipyv_rec,
           x_ipyv_rec                     => lx_ipyv_rec
          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.insert_ins_policies ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.insert_ins_policies

	      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status := l_return_status ;
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              x_return_status := l_return_status ;
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
     px_ipyv_rec.ID :=   lx_ipyv_rec.ID;
   IF l_iasset_tbl IS NOT NULL THEN
     IF l_iasset_tbl.COUNT > 0 THEN
         FOR i IN l_iasset_tbl.first..l_iasset_tbl.last LOOP
         IF l_iasset_tbl.EXISTS(i) THEN
	    l_inav_tbl(i).KLE_ID := l_iasset_tbl(i).KLE_ID ;
	    l_inav_tbl(i).asset_premium := l_iasset_tbl(i).PREMIUM ;
	    l_inav_tbl(i).IPY_ID  := lx_ipyv_rec.ID ;
            l_inav_tbl(i).LESSOR_premium := l_iasset_tbl(i).LESSOR_PREMIUM ;
	    l_inav_tbl(i).ORG_ID := lx_ipyv_rec.ORG_ID ; --added by zrehman as part of Bug#6363652 9-Oct-2007
	  END IF;
    END LOOP;
-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Assets_Pub.insert_ins_assets
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call Okl_Ins_Assets_Pub.insert_ins_assets ');
    END;
  END IF;
    	Okl_Ins_Assets_Pub.insert_ins_assets(
	          p_api_version                  => l_api_version,
          	  p_init_msg_list                => OKC_API.G_FALSE,
          	  x_return_status                => l_return_status,
                  x_msg_count                    => x_msg_count,
                  x_msg_data                     => x_msg_data,
                  p_inav_tbl                     => l_inav_tbl,
                  x_inav_tbl                     => lx_inav_tbl
          		);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call Okl_Ins_Assets_Pub.insert_ins_assets ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Assets_Pub.insert_ins_assets

              IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 x_return_status := l_return_status ;
	  	        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  x_return_status := l_return_status ;
	  	        RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
     END IF;
   END IF;
 END IF ;
 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
                  x_message := 'ab2';
    EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
	 END save_quote ;
  ---------------------------------------------------------------------------
  -- PROCEDURE save_accept_quote
  ---------------------------------------------------------------------------
  PROCEDURE save_accept_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN  ipyv_rec_type,
	 x_message                      OUT NOCOPY  VARCHAR2  )
	 IS
	 	 l_msg_count                   NUMBER ;
	l_msg_data                      VARCHAR2(2000);
	l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'save_ACCEPT_quote';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	p_contract_id                 NUMBER ;
	l_ipyv_rec            ipyv_rec_type ;
	lx_ipyv_rec  ipyv_rec_type ;
   l_iaaset_tbl  iasset_tbl_type ;
   l_message      VARCHAR2(200);
   l_inav_tbl                     Okl_Ina_Pvt.inav_tbl_type;
   l_policy_number                    NUMBER;
	 BEGIN
     x_return_status := Okc_Api.G_RET_STS_SUCCESS ;
     x_message := 'a' ;
             l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                             G_PKG_NAME,
                                            p_init_msg_list,
                                            l_api_version,
                                            p_api_version,
                                                      '_PROCESS',
                                                      l_return_status);
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
		l_ipyv_rec := P_ipyv_rec 	;

	 save_quote(
      p_api_version                  =>l_api_version ,
      p_init_msg_list                => Okc_Api.G_FALSE,
      x_return_status                => x_return_status,
      x_msg_count                  =>  x_msg_count,
      x_msg_data                   =>  x_msg_data,
      px_ipyv_rec                   =>  l_ipyv_rec,
	  x_message                   =>   x_message  );
          x_message :=  TO_CHAR(l_ipyv_rec.ID) ;
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
    	 accept_quote(p_api_version => l_api_version,
           		      p_init_msg_list => p_init_msg_list ,
           		      x_return_status => l_return_status  ,
	        	      x_msg_count => x_msg_count  ,
	        	      x_msg_data => x_msg_data ,
	        	      p_quote_id => l_ipyv_rec.ID
     			      );

			 	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

	         	   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
				 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN

	          	 	  RAISE OKC_API.G_EXCEPTION_ERROR;
	        	 END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
	 END save_accept_quote ;
  ---------------------------------------------------------------------------
  -- PROCEDURE calc_lease_premium
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- PROCEDURE Name	: calc_lease_premium
  -- Description	:ToCalculate Lease Premium for Contract
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- Changes
         --SSDESHPA Bug# 6318957 Fixed for Inv Org Data not getting Populated
  -- End of Comments
---------------------------------------------------------------------------

     PROCEDURE   calc_lease_premium(
         p_api_version                   IN NUMBER,
	     p_init_msg_list                IN VARCHAR2 ,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         px_ipyv_rec                     IN OUT NOCOPY ipyv_rec_type,
	 x_message                      OUT NOCOPY VARCHAR2,
         x_iasset_tbl                  OUT NOCOPY  iasset_tbl_type
     )IS
	l_msg_count                   NUMBER ;
	l_msg_data                      VARCHAR2(2000);
	l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'calc_lease_premium';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    p_contract_id                 NUMBER ;
    -- Cursor to get ASSET information of passed contract
	CURSOR okl_k_assets_csr (p_k_id       NUMBER) IS -- Bug 4105057
SELECT OTAT.DESCRIPTION ASSET_DESCRIPTION,
       OTAB.current_units QUANTITY,
       KLE_TOP.OEC OEC,
       TL.NAME ASSET_CATEGORY,
       OICC.IAC_CODE INSURANCE_CLASS_code,
       KLE_TOP.ID KLE_ID,
       OTAB.ASSET_NUMBER ASSET_NUMBER
FROM OKL_TXL_ASSETS_B OTAB,
     OKL_TXL_ASSETS_TL OTAT,
     OKX_ASST_CATGRS_V TL,
     OKL_INS_CLASS_CATS OICC,
     OKL_K_LINES KLE,
     OKL_K_LINES KLE_TOP,
     OKC_K_LINES_B CLE
WHERE KLE.ID = OTAB.KLE_ID
  AND KLE.ID = CLE.ID
  AND CLE.CLE_ID = KLE_TOP.ID
  AND TL.CATEGORY_ID = OTAB.DEPRECIATION_ID
  AND OTAB.ID = OTAT.ID
  AND OICC.IAY_ID = OTAB.DEPRECIATION_ID
  AND SYSDATE BETWEEN OICC.DATE_FROM AND NVL(OICC.DATE_TO, SYSDATE +1)
  AND OTAT.LANGUAGE = USERENV ('LANG')
  AND NOT EXISTS
      (Select '1'
       from okc_k_items cim
       where cim.cle_id = otab.kle_id
       AND cim.object1_id1 is not null)
  AND CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED' )
  AND OTAB.DNZ_KHR_ID  = p_k_id
UNION
SELECT OTAT.DESCRIPTION ASSET_DESCRIPTION,
       OTAB.current_units QUANTITY,
       KLE_TOP.OEC OEC,
       TL.NAME ASSET_CATEGORY,
       OICC.IAC_CODE INSURANCE_CLASS_code,
       KLE_TOP.ID KLE_ID,
       OTAB.ASSET_NUMBER ASSET_NUMBER
FROM OKL_TXL_ASSETS_B OTAB,
     OKL_TXL_ASSETS_TL OTAT,
     OKX_ASST_CATGRS_V TL,
     OKL_INS_CLASS_CATS OICC,
     OKL_K_LINES KLE ,
     OKL_K_LINES KLE_TOP ,
     OKC_K_LINES_B CLE ,
     OKL_K_HEADERS KHR
WHERE KLE.ID = OTAB.KLE_ID
  AND KLE.ID = CLE.ID
  AND CLE.CLE_ID = KLE_TOP.ID
  AND TL.CATEGORY_ID = KLE_TOP.ITEM_INSURANCE_CATEGORY
  AND OTAB.ID = OTAT.ID
  AND OICC.IAY_ID = KLE_TOP.ITEM_INSURANCE_CATEGORY
  AND SYSDATE BETWEEN OICC.DATE_FROM AND NVL(OICC.DATE_TO, SYSDATE +1)
  AND OTAT.LANGUAGE = USERENV('LANG')
  AND NOT EXISTS
      (Select '1'
       from okc_k_items cim
       where cim.cle_id = otab.kle_id
       AND cim.object1_id1 is not null)
  AND khr.id = CLE.DNZ_CHR_ID
  AND khr.deal_type = 'LOAN'
  AND CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED','BOOKED' )
  AND OTAB.DNZ_KHR_ID  = p_k_id
UNION
SELECT  OTL.ITEM_DESCRIPTION ASSET_DESCRIPTION,
       MODEL.NUMBER_OF_ITEMS QUANTITY,
       KLE.OEC OEC,
       TL.NAME ASSET_CATEGORY,
       OICC.IAC_CODE INSURANCE_CLASS_code,
       KLE.ID KLE_ID,
       FAD.ASSET_NUMBER ASSET_NUMBER
FROM OKL_K_LINES KLE ,
     OKC_K_LINES_B CLE,
     OKC_LINE_STYLES_B LS,
     OKC_K_ITEMS CIM,
     OKC_K_LINES_TL OTL,
     OKC_K_LINES_B ITEM_CLE,
     OKC_LINE_STYLES_B ITEM_LS,
     OKC_K_ITEMS MODEL ,
     OKX_ASST_CATGRS_V TL,
     OKL_INS_CLASS_CATS OICC,
     FA_ADDITIONS_B FAd,
     OKC_K_LINES_B FINAC_CLE,
     OKC_LINE_STYLES_B FINAC_LS
WHERE FINAC_LS.LTY_CODE = 'FREE_FORM1'
  AND FINAC_CLE.LSE_ID = FINAC_LS.ID
  AND FINAC_CLE.ID = KLE.ID
  AND OICC.IAY_ID = FAD.ASSET_CATEGORY_ID
  AND SYSDATE BETWEEN OICC.DATE_FROM AND NVL(OICC.DATE_TO, SYSDATE +1)
  AND FAD.ASSET_ID = CIM.OBJECT1_ID1
  AND CIM.OBJECT1_ID2 = '#'
  AND TL.CATEGORY_ID = FAD.ASSET_CATEGORY_ID
  AND MODEL.JTOT_OBJECT1_CODE = 'OKX_SYSITEM'
  AND MODEL.DNZ_CHR_ID = ITEM_CLE.DNZ_CHR_ID
  AND MODEL.cle_id = ITEM_CLE.ID
  AND ITEM_LS.LTY_CODE = 'ITEM'
  AND ITEM_LS.ID = ITEM_CLE.LSE_ID
  AND ITEM_CLE.CLE_ID = FINAC_CLE.ID
  AND OTL.ID = CLE.ID
  AND OTL.LANGUAGE = USERENV('LANG')
  AND CIM.DNZ_CHR_ID = CLE.DNZ_CHR_ID
  AND CIM.CLE_ID = CLE.ID
  AND CIM.JTOT_OBJECT1_CODE = 'OKX_ASSET'
  AND LS.ID = CLE.LSE_ID
  AND LS.LTY_CODE = 'FIXED_ASSET'
  AND CLE.CLE_ID = FINAC_CLE.ID
  AND FINAC_CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED' )
  AND CLE.DNZ_CHR_ID = p_k_id
UNION
SELECT OTL.ITEM_DESCRIPTION ASSET_DESCRIPTION,
       MODEL.NUMBER_OF_ITEMS QUANTITY,
       KLE.OEC OEC,
       TL.NAME ASSET_CATEGORY,
       OICC.IAC_CODE INSURANCE_CLASS_code,
       KLE.ID KLE_ID,
       FINAN_CLET.NAME ASSET_NUMBER
FROM OKL_K_LINES KLE,
     OKX_ASST_CATGRS_V TL,
     OKL_INS_CLASS_CATS OICC,
     OKC_K_LINES_B CLE,
     OKC_K_LINES_TL OTL,
     OKC_LINE_STYLES_B LS,
     OKC_K_LINES_B ITEM_CLE,
     OKC_LINE_STYLES_B ITEM_LS,
     OKC_K_ITEMS MODEL ,
     OKL_K_HEADERS KHR ,
     OKC_K_LINES_B FINAN_CLE ,
     OKC_K_LINES_TL FINAN_CLET
WHERE MODEL.cle_id = ITEM_CLE.ID
  AND MODEL.DNZ_CHR_ID = ITEM_CLE.DNZ_CHR_ID
  AND ITEM_LS.LTY_CODE = 'ITEM'
  AND ITEM_LS.ID = ITEM_CLE.LSE_ID
  AND ITEM_CLE.CLE_ID = FINAN_CLE.ID
  AND ITEM_CLE.DNZ_CHR_ID = FINAN_CLE.DNZ_CHR_ID
  AND CLE.CLE_ID = FINAN_CLE.ID
  AND CLE.DNZ_CHR_ID = FINAN_CLE.DNZ_CHR_ID
  AND TL.CATEGORY_ID = kle.ITEM_INSURANCE_CATEGORY
  AND OICC.IAY_ID = kle.ITEM_INSURANCE_CATEGORY
  AND SYSDATE BETWEEN OICC.DATE_FROM AND NVL(OICC.DATE_TO, SYSDATE +1)
  AND OTL.ID = CLE.ID
  AND OTL.LANGUAGE = USERENV('LANG')
  AND LS.ID = CLE.LSE_ID
  AND LS.LTY_CODE = 'FIXED_ASSET'
  AND FINAN_CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED' )
  AND FINAN_CLET.LANGUAGE = USERENV('LANG')
  AND FINAN_CLET.ID = FINAN_CLE.ID
  AND KLE.ID = FINAN_CLE.ID
  AND FINAN_CLE.DNZ_CHR_ID = KHR.ID
  AND FINAN_CLE.CHR_ID = KHR.ID
  AND FINAN_CLE.CLE_ID is null
  AND KHR.DEAL_TYPE = 'LOAN'
  AND CLE.DNZ_CHR_ID = p_k_id;

	 l_okl_k_assets_csr    okl_k_assets_csr%ROWTYPE;

   --- Cursor For Restrition country and asset
    CURSOR  okl_country_restriction (p_country_code VARCHAR2, p_asset_category NUMBER)  IS
       SELECT 'x'
       FROM OKL_INS_EXCLUSIONS_B
       WHERE COUNTRY_ID = p_country_code
       AND COLL_CODE = p_asset_category;

  --- Cursor For Restrition  and asset categor and SIC CODE
     CURSOR  okl_country_restriction (p_country_code VARCHAR2, p_asset_category NUMBER
     ,p_sic_code VARCHAR2)  IS
       SELECT 'x'
       FROM OKL_INS_EXCLUSIONS_B
       WHERE COUNTRY_ID = p_country_code
       AND COLL_CODE = p_asset_category
       AND SIC_CODE  =  p_sic_code;

  --- Cursor to check ASSET_CATEGORY
     cursor c_asset_category_valid (p_khr_id NUMBER) IS
     select 'x',OTAB.ASSET_NUMBER
     from OKL_TXL_ASSETS_B OTAB,
     OKL_K_LINES KLE,
     OKC_K_LINES_B CLE,
     OKC_LINE_STYLES_B LS
     WHERE OTAB.DNZ_KHR_ID = p_khr_id AND
     KLE.ID = OTAB.KLE_ID
     AND CLE.ID =  KLE.ID
     AND LS.ID = CLE.LSE_ID
     AND LS.LTY_CODE = 'FIXED_ASSET' -- Bug# 4102231
     and CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED' )
     and OTAB.DEPRECIATION_ID IS NULL
     UNION
     SELECT 'x', FAD.ASSET_NUMBER
     from
     OKC_K_LINES_B CLE,
     OKC_LINE_STYLES_B  LS,
     OKC_K_ITEMS CIM,
     FA_ADDITIONS_B FAD
     where
      FAD.ASSET_CATEGORY_ID IS  NULL
     AND FAD.ASSET_ID = CIM.OBJECT1_ID1
     AND CIM.DNZ_CHR_ID = CLE.DNZ_CHR_ID
     AND CIM.JTOT_OBJECT1_CODE   = 'OKX_ASSET'
     AND CIM.OBJECT1_ID1  = '#'
     AND CIM.CLE_ID = CLE.ID
     AND LS.LTY_CODE = 'FIXED_ASSET'
     AND LS.ID = CLE.LSE_ID
     and CLE.DNZ_CHR_ID = p_khr_id
     and CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED' ) ;





    -- To get capital amount of contarct
    CURSOR okl_k_capital_amt_csr (p_khr_id       NUMBER) IS
	 SELECT SUM(KLE.CAPITAL_AMOUNT) --,SUM(KLE.OEC)
		FROM OKC_K_LINES_B CLEB,OKL_K_LINES KLE
		  WHERE CLEB.ID = KLE.ID
          AND   CLEB.DNZ_CHR_ID = p_khr_id
          AND CLEB.CLE_ID IS NULL
	   GROUP BY  CLEB.DNZ_CHR_ID ;
       -- To get deal size  in months

   	 	CURSOR okl_k_deal_size_csr (p_khr_id       NUMBER) IS
        SELECT MONTHS_BETWEEN(END_DATE,START_DATE), CONTRACT_NUMBER ----20-Jan-2005 Bug# 4056484 PAGARG removing rounding
		FROM OKC_K_HEADERS_B
		WHERE ID =  p_khr_id ;
        -- To get sum of oec
CURSOR okl_k_total_oec_csr (p_khr_id       NUMBER) IS -- Bug 4105057
SELECT SUM(OEC)
FROM
(
SELECT  OTAB.DNZ_KHR_ID CONTRACT_ID,
        KLE_TOP.OEC OEC,
        OTAB.ASSET_NUMBER ASSET_NUMBER
FROM OKL_TXL_ASSETS_B OTAB,
       OKL_K_LINES KLE,
       OKL_K_LINES KLE_TOP,
       OKC_K_LINES_B CLE
WHERE KLE.ID = OTAB.KLE_ID
  AND KLE.ID = CLE.ID
  AND CLE.CLE_ID = KLE_TOP.ID
  AND NOT EXISTS
      (Select '1'
       from okc_k_items cim
       where cim.cle_id = otab.kle_id
       AND cim.object1_id1 is not null)
  AND CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED' )
  AND OTAB.DNZ_KHR_ID  = p_khr_id
UNION
SELECT OTAB.DNZ_KHR_ID CONTRACT_ID,KLE_TOP.OEC OEC,
OTAB.ASSET_NUMBER ASSET_NUMBER
FROM OKL_TXL_ASSETS_B OTAB,
     OKL_K_LINES KLE ,
     OKL_K_LINES KLE_TOP ,
     OKC_K_LINES_B CLE ,
     OKL_K_HEADERS KHR
WHERE KLE.ID = OTAB.KLE_ID
  AND KLE.ID = CLE.ID
  AND CLE.CLE_ID = KLE_TOP.ID
  AND NOT EXISTS
      (Select '1'
       from okc_k_items cim
       where cim.cle_id = otab.kle_id
       AND cim.object1_id1 is not null)
  AND khr.id = CLE.DNZ_CHR_ID
  AND khr.deal_type = 'LOAN'
  AND CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED','BOOKED' )
  AND OTAB.DNZ_KHR_ID  = p_khr_id
UNION
select CLE.DNZ_CHR_ID CONTRACT_ID,
       KLE.OEC OEC,
       FAD.ASSET_NUMBER ASSET_NUMBER
from OKL_K_LINES KLE ,
     OKC_K_LINES_B CLE,
     OKC_LINE_STYLES_B LS,
     OKC_K_ITEMS CIM,
     OKC_K_LINES_B ITEM_CLE,
     OKC_LINE_STYLES_B ITEM_LS,
     OKC_K_ITEMS MODEL ,
     FA_ADDITIONS_B FAd,
     OKC_K_LINES_B FINAC_CLE,
     OKC_LINE_STYLES_B FINAC_LS
where FINAC_LS.LTY_CODE = 'FREE_FORM1'
  AND FINAC_CLE.LSE_ID = FINAC_LS.ID
  AND FINAC_CLE.ID = KLE.ID
  AND FAD.ASSET_ID = CIM.OBJECT1_ID1
  AND CIM.OBJECT1_ID2 = '#'
  AND MODEL.JTOT_OBJECT1_CODE = 'OKX_SYSITEM'
  AND MODEL.DNZ_CHR_ID = CLE.DNZ_CHR_ID
  AND MODEL.cle_id = ITEM_CLE.ID
  AND ITEM_LS.LTY_CODE = 'ITEM'
  AND ITEM_LS.ID = ITEM_CLE.LSE_ID
  AND ITEM_CLE.CLE_ID = FINAC_CLE.ID
  AND CIM.DNZ_CHR_ID = CLE.DNZ_CHR_ID
  AND CIM.CLE_ID = CLE.ID
  AND CIM.JTOT_OBJECT1_CODE = 'OKX_ASSET'
  AND LS.ID = CLE.LSE_ID
  AND LS.LTY_CODE = 'FIXED_ASSET'
  AND CLE.CLE_ID = FINAC_CLE.ID
  AND FINAC_CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED' )
  AND CLE.DNZ_CHR_ID = p_khr_id
union
SELECT CLE.DNZ_CHR_ID CONTRACT_ID,
       KLE.OEC OEC,
       FINAN_CLET.NAME ASSET_NUMBER
FROM OKL_K_LINES KLE,
     OKC_K_LINES_B CLE,
     OKC_LINE_STYLES_B LS,
     OKC_K_LINES_B ITEM_CLE,
     OKC_LINE_STYLES_B ITEM_LS,
     OKC_K_ITEMS MODEL ,
     OKL_K_HEADERS KHR ,
     OKC_K_LINES_B FINAN_CLE ,
     OKC_K_LINES_TL FINAN_CLET
WHERE MODEL.cle_id = ITEM_CLE.ID
  AND MODEL.DNZ_CHR_ID = ITEM_CLE.DNZ_CHR_ID
  AND ITEM_LS.LTY_CODE = 'ITEM'
  AND ITEM_LS.ID = ITEM_CLE.LSE_ID
  AND ITEM_CLE.CLE_ID = FINAN_CLE.ID
  AND ITEM_CLE.DNZ_CHR_ID = FINAN_CLE.DNZ_CHR_ID
  AND CLE.CLE_ID = FINAN_CLE.ID
  AND CLE.DNZ_CHR_ID = FINAN_CLE.DNZ_CHR_ID
  AND LS.ID = CLE.LSE_ID
  AND LS.LTY_CODE = 'FIXED_ASSET'
  AND FINAN_CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED' )
  AND FINAN_CLET.LANGUAGE = USERENV('LANG')
  AND FINAN_CLET.ID = FINAN_CLE.ID
  AND KLE.ID = FINAN_CLE.ID
  AND FINAN_CLE.DNZ_CHR_ID = KHR.ID
  AND FINAN_CLE.CHR_ID = KHR.ID
  AND FINAN_CLE.CLE_ID is null
  AND KHR.DEAL_TYPE = 'LOAN'
  AND CLE.DNZ_CHR_ID = p_khr_id)
  GROUP BY CONTRACT_ID;

-- To get insurance product based on total oec, sysdate and insurer

         l_prt_count NUMBER := 0;

         -- inventory org change
         CURSOR okl_count_k_product_csr(p_isu_id NUMBER, p_total_oec NUMBER, p_from_date DATE ,p_inv_org_id NUMBER) IS
	 SELECT COUNT(*) --Bug:3825159
         FROM OKL_INS_PRODUCTS_B IPTB,
    	      MTL_SYSTEM_ITEMS_B_KFV MSIB
      	 WHERE IPTB.IPD_ID =MSIB.INVENTORY_ITEM_ID
	 AND iptb.isu_id  = p_isu_id
 	 AND IPTB.IPT_TYPE = 'LEASE_PRODUCT'
  	 AND p_total_oec BETWEEN IPTB.FACTOR_MIN AND IPTB.FACTOR_MAX
  	 AND p_from_date BETWEEN IPTB.DATE_FROM AND DECODE(IPTB.DATE_TO,NULL,p_from_date,IPTB.DATE_TO)
  	 AND MSIB.ORGANIZATION_ID = p_inv_org_id;


         l_product_name VARCHAR2(256);
         -- inventory org change
		CURSOR 	okl_k_product_csr(p_isu_id NUMBER, p_total_oec NUMBER, p_from_date DATE ,p_inv_org_id NUMBER) IS
			SELECT iptb.ID ,iptt.NAME --Bug:3825159
                        FROM OKL_INS_PRODUCTS_TL IPTT,
    			     OKL_INS_PRODUCTS_B IPTB,
			     MTL_SYSTEM_ITEMS_B_KFV MSIB
			WHERE IPTB.ID = IPTT.ID
			AND IPTT.LANGUAGE = USERENV('LANG')
 			AND IPTB.IPD_ID = MSIB.INVENTORY_ITEM_ID
 			AND iptb.isu_id  = p_isu_id
 			AND IPTB.IPT_TYPE = 'LEASE_PRODUCT'
 			AND p_total_oec BETWEEN IPTB.FACTOR_MIN AND IPTB.FACTOR_MAX
 		        AND p_from_date BETWEEN IPTB.DATE_FROM AND DECODE(IPTB.DATE_TO,NULL,p_from_date,IPTB.DATE_TO)
 			AND MSIB.ORGANIZATION_ID =p_inv_org_id;

            -- To get insurance rate based on oec of asset_category insurance product , insurance class ,country,  from date and payment frequency
            CURSOR okl_ins_rate_csr(p_location_code VARCHAR2, p_oec NUMBER, p_ipt_id NUMBER , p_ins_class  VARCHAR2, p_from_date DATE, p_freq_factor NUMBER) IS
		  		SELECT ((INSURED_RATE * p_oec )/100 ) * p_freq_factor,((INSURER_RATE * p_oec )/100 ) * p_freq_factor
				FROM OKL_INS_RATES INR
				WHERE INR.IPT_ID = p_ipt_id
                     AND INR.IAC_CODE = p_ins_class
                     AND INR.IC_ID = p_location_code
                     AND p_oec BETWEEN INR.FACTOR_RANGE_START AND INR.FACTOR_RANGE_END
                     AND p_from_date BETWEEN INR.DATE_FROM AND DECODE(INR.DATE_TO,NULL,p_from_date,INR.DATE_TO) ;
            -- tO SELECT INSURER
		    CURSOR  l_isu_csr(p_isu_id NUMBER) IS
            SELECT 'x'
            FROM OKX_INS_PROVIDER_V
            WHERE PARTY_ID = p_isu_id	;
        l_ipyv_rec                     ipyv_rec_type;
    	l_max_deal  NUMBER ;
	    l_max_term  NUMBER;
        l_min_term  NUMBER;
	    l_freq_factor  NUMBER;
	    l_con_deal_amount NUMBER;
	    l_deal_size NUMBER;
	    l_con_oec       NUMBER ;
	    l_func_oec       NUMBER ;
	    l_ins_class VARCHAR(30) ;
	    l_con_total_oec NUMBER ;
	    l_func_premium   NUMBER;
	    l_func_lessor_premium NUMBER;
	    l_product   NUMBER ;
            i           NUMBER  := 0 ;
	    l_dummy_var VARCHAR(1) := '?' ;
	    l_khr_st_date  DATE;
	    l_khr_end_date  DATE;
        l_asset_number VARCHAR2(15);
        l_contract_number OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE ;

        ----- For Multi Currency
        l_functional_currency  okl_k_headers_full_v.currency_code%TYPE := okl_accounting_util.get_func_curr_code;

		x_contract_currency   okl_k_headers_full_v.currency_code%TYPE;
		x_currency_conversion_type  okl_k_headers_full_v.currency_conversion_type%TYPE;
		x_currency_conversion_rate  okl_k_headers_full_v.currency_conversion_rate%TYPE;
		x_currency_conversion_date okl_k_headers_full_v.currency_conversion_date%TYPE;
		x_functional_covered_amt  NUMBER ;
		p_contract_currency      fnd_currencies_vl.currency_code%TYPE ;

		CURSOR l_contract_currency_csr(p_khr_id    IN   NUMBER) IS
		    SELECT  currency_code , deal_type, AUTHORING_ORG_ID
		    FROM    okl_k_headers_full_v
	         WHERE   id = p_khr_id;

        l_fun_deal_amount NUMBER;
        l_fun_total_oec  NUMBER;
        l_authoring_org_id okl_k_headers_full_v.authoring_org_id%TYPE;
         --- for Organization
        l_inv_org_id NUMBER;

        --- Loan Contract
        CURSOR c_loan_asset_category(p_khr_id NUMBER) IS
        select 'x',CLE.NAME , cle.id
	from OKL_K_LINES KLE,
	 OKC_K_LINES_V CLE, OKC_LINE_STYLES_B  LS
	WHERE CLE.ID =  KLE.ID
	and CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED' )
	and KLE.ITEM_INSURANCE_CATEGORY IS NULL
	AND LS.LTY_CODE = 'FREE_FORM1'
	AND LS.ID = CLE.LSE_ID
	AND CLE.chr_id = p_khr_id ;

	CURSOR c_loan_item_category(p_financial_line_id NUMBER) IS
	SELECT   mtl.ASSET_CATEGORY_ID, MTL.DESCRIPTION
	FROM
	  MTL_SYSTEM_ITEMS MTL,
	  OKC_K_items FA_ITEM ,
	  OKC_K_LINES_B MODEL,
	  OKC_LINE_STYLES_B LS_MODEL
	WHERE
	  MTL.INVENTORY_ITEM_ID = FA_ITEM.object1_id1
	  AND MTL.ORGANIZATION_ID =  FA_ITEM.object1_id2
	   AND FA_ITEM.JTOT_OBJECT1_CODE = 'OKX_SYSITEM'
	   AND MODEL.ID = FA_ITEM.cle_id
	   AND LS_MODEL.ID = MODEL.LSE_ID
	   AND LS_MODEL.LTY_CODE = 'ITEM'
           and MODEL.cle_id =p_financial_line_id;

           l_clev_rec	okl_okc_migration_pvt.clev_rec_type;
	   lx_clev_rec	okl_okc_migration_pvt.clev_rec_type;
	   l_klev_rec	Okl_Kle_Pvt.klev_rec_type ;
    	   lx_klev_rec	Okl_Kle_Pvt.klev_rec_type ;

    l_financial_line_id    NUMBER ;
    l_item      MTL_SYSTEM_ITEMS.DESCRIPTION%TYPE ;
    l_deal_type VARCHAR2(30);
    l_item_category NUMBER;

  BEGIN
   x_message  :=   Okc_Api.G_RET_STS_SUCCESS;
   x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                             G_PKG_NAME,
                                            p_init_msg_list,
                                            l_api_version,
                                            p_api_version,
                                            '_PROCESS',
                                            x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
          -- data is required
   --- Check for INSURANCE PROVIDER'S VALADITY
    IF ( ( px_ipyv_rec.isu_id IS NULL)  OR  (px_ipyv_rec.isu_id = OKC_API.G_MISS_NUM)) THEN
          OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'isu_id');
          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSE
		 OPEN   l_isu_csr(px_ipyv_rec.isu_id) ;
         FETCH l_isu_csr INTO l_dummy_var ;
         CLOSE l_isu_csr ;
          	-- still set to default means data was not found
         IF ( l_dummy_var = '?' ) THEN
            OKC_API.set_message(g_app_name,g_no_parent_record,
          				g_col_name_token,'isu_code',
		  			g_parent_table_token ,
          		  	    	'OKX_INS_PROVIDER_V');
  	    x_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
    END IF;


  -- For Payment frequency
  IF ((px_ipyv_rec.ipf_code IS NULL ) OR (px_ipyv_rec.ipf_code = OKC_API.G_MISS_CHAR )) THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ipf_code');
	x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
		-- Message --
  ELSE
		   l_return_status := Okl_Util.check_lookup_code( G_FND_LOOKUP_PAYMENT_FREQ,px_ipyv_rec.ipf_code);
	   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
   	          x_return_status := l_return_status;
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	       OKC_API.set_message(g_app_name,G_NO_PARENT_RECORD,g_col_name_token,
          		  	    	'Payment Frequency' ,g_parent_table_token ,'FND_LOOKUPS');
              x_return_status := l_return_status;
              RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
 END IF;
        -- For Contract ID
IF ((px_ipyv_rec.khr_id IS NULL ) OR (px_ipyv_rec.khr_id = OKC_API.G_MISS_NUM )) THEN
   x_return_status := OKC_API.G_RET_STS_ERROR;
   OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Contract ID');
   RAISE OKC_API.G_EXCEPTION_ERROR;
ELSE


   	OPEN  l_contract_currency_csr(px_ipyv_rec.khr_id) ;
        FETCH l_contract_currency_csr INTO p_contract_currency, l_deal_type, l_authoring_org_id ;
        CLOSE l_contract_currency_csr ;



   l_dummy_var := '?';
   IF l_deal_type <>'LOAN' THEN --smoduga added check for loan contract dealtype.As part
                                  -- item_insurance_category changes.
  --  Validate Category

   	OPEN   c_asset_category_valid(px_ipyv_rec.khr_id) ;
         FETCH c_asset_category_valid INTO l_dummy_var, l_asset_number ;
         CLOSE c_asset_category_valid ;
          	-- still set to default means data was not found
         IF ( l_dummy_var = 'x' ) THEN
          		OKC_API.set_message(g_app_name,
                     'OKL_NO_CATEGORY',
          	    g_col_name_token,
                     l_asset_number
                    );
  			x_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

    -- Validate Insurance Class
   ELSE
   -- To check item category in OKL_K_LINE
     OPEN   c_loan_asset_category(px_ipyv_rec.khr_id) ;

     LOOP
     	FETCH c_loan_asset_category INTO
     	    l_dummy_var,
     	    l_asset_number,
     	    l_financial_line_id ;
     	EXIT WHEN c_loan_asset_category%NOTFOUND;
     	  -- still set to default means data was not found
     	 IF ( l_dummy_var = 'x' ) THEN
     	    -- To check inventory setup
     	    l_item_category := NULL;
     	    OPEN   c_loan_item_category(l_financial_line_id) ;
     	    FETCH c_loan_item_category INTO
     	    l_item_category,l_item ;
     	    CLOSE c_loan_item_category;
     	    IF (l_item_category IS NULL) THEN  -- setup is incomplete
     	    -- otherwise throw an error
     	       		OKC_API.set_message(g_app_name,
	                           'OKL_NO_ITEM_CATEGORY',
	                	    'ITEM',
	                           l_item
	                          );
	        	x_return_status := OKC_API.G_RET_STS_ERROR;
	        	CLOSE c_loan_asset_category ;

	                RAISE OKC_API.G_EXCEPTION_ERROR;


     	    ELSE -- need to poplate value in okl_k_lines (financial)
     	    -- If asset_category in inventory setup, populate it in OKL_K_LINES
     	       l_clev_rec.ID := l_financial_line_id ;
	       l_klev_rec.ID := l_financial_line_id ;
	       l_klev_rec.ITEM_INSURANCE_CATEGORY := l_item_category ;
	        Okl_Contract_Pub.update_contract_line
	            (
	               p_api_version      => l_api_version ,
	            p_init_msg_list           => OKC_API.G_FALSE,
	            x_return_status      => x_return_status    ,
	            x_msg_count           => x_msg_count,
	            x_msg_data            => x_msg_data ,
	            p_clev_rec            => l_clev_rec  ,
	            p_klev_rec            => l_klev_rec,
	            x_clev_rec            => lx_clev_rec,
	            x_klev_rec            => lx_klev_rec );

     	         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     	                  CLOSE c_loan_asset_category ;
	                    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	          	CLOSE c_loan_asset_category ;
	                    RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;




     	    END IF;

     	  END IF;
       l_dummy_var := '?';
     END LOOP ;
     CLOSE c_loan_asset_category ;


   END IF;


END IF;
 -- For From Date
IF ((px_ipyv_rec.date_from IS NULL ) OR (px_ipyv_rec.date_from = OKC_API.G_MISS_DATE )) THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Policy Effective From');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
END IF;
-- For To date
IF ((px_ipyv_rec.date_to IS NULL ) OR (px_ipyv_rec.date_to = OKC_API.G_MISS_DATE )) THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Policy Effective To');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
END IF;
-- Quote date
IF ((px_ipyv_rec.DATE_QUOTED  IS NULL ) OR (px_ipyv_rec.DATE_QUOTED  = OKC_API.G_MISS_DATE )) THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Quote Effective From');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
END IF;
-- Quote expiry date
IF ((px_ipyv_rec.DATE_QUOTE_EXPIRY IS NULL ) OR (px_ipyv_rec.DATE_QUOTE_EXPIRY = OKC_API.G_MISS_DATE )) THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Quote Effective To');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
END IF;

 l_return_status:= Okl_Util.check_from_to_date_range( px_ipyv_rec.date_from
                      ,px_ipyv_rec.date_to );
       IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                          -- store SQL error message on message stack for caller
             OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,
                                                SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
 		     x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR ;
             RAISE G_EXCEPTION_HALT_VALIDATION;
	ELSIF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
		Okc_Api.set_message(p_app_name     => g_app_name,
	 	 		p_msg_name     => 'OKL_INVALID_END_DATE', -- 3745151 fix for wrong error message
	 	 		p_token1       => 'COL_NAME1',
	 	 		p_token1_value => 'Effective To',
	 	 		p_token2       => 'COL_NAME2',
	 	 		p_token2_value => 'Effective From');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
    	--- Get Contract Term
       BEGIN
             get_contract_term(px_ipyv_rec.khr_id ,
                 l_khr_st_date ,
                 l_khr_end_date  ,
                 l_return_status );
         IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                          -- store SQL error message on message stack for caller
 		     x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR ;
             RAISE G_EXCEPTION_HALT_VALIDATION;
	 ELSIF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
		x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
        		      -- verify that cursor was closed
  	 END ;

  ---  To validate with contract term

	  IF (px_ipyv_rec.date_from < l_khr_st_date) OR (px_ipyv_rec.date_from > l_khr_end_date) THEN
               -- store SQL error message on message stack for caller
              Okc_Api.set_message( p_app_name     => g_app_name,
	 	                  p_msg_name     => G_INVALID_INSURANCE_TERM );
	 	x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE OKC_API.G_EXCEPTION_ERROR;
           ELSIF (px_ipyv_rec.date_to < l_khr_st_date) OR (px_ipyv_rec.date_to > l_khr_end_date) THEN
                          Okc_Api.set_message( p_app_name     => g_app_name,
	 	         p_msg_name     => G_INVALID_INSURANCE_TERM );
	 	x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

          -- gboomina Bug 4744724 - Added - Validate Quote's date with Insurance Term - Start
	  IF (px_ipyv_rec.DATE_QUOTE_EXPIRY > px_ipyv_rec.date_to) THEN
               -- store SQL error message on message stack for caller
              Okc_Api.set_message( p_app_name     => g_app_name,
	 	                  p_msg_name     => G_INVALID_QUOTE_TERM );
	 	x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
          -- gboomina Bug 4744724 - Added - Validate Quote's date with Insurance Term - End


		-- For IPY TYPE
IF ((px_ipyv_rec.ipy_type IS NULL ) OR (px_ipyv_rec.ipy_type = OKC_API.G_MISS_CHAR )) THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Policy Type');
	x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
ELSE
  IF(  px_ipyv_rec.ipy_type <> 'LEASE_POLICY' )THEN
	OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Policy Type',G_COL_VALUE_TOKEN, 'Lease Policy' );
	x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF ;
END IF;
-- For Location
IF ((px_ipyv_rec.territory_code IS NULL ) OR (px_ipyv_rec.territory_code = OKC_API.G_MISS_CHAR )) THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Location');
	x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
END IF ;

	OPEN okl_k_capital_amt_csr(px_ipyv_rec.KHR_ID);
	FETCH okl_k_capital_amt_csr INTO l_con_deal_amount ;
	IF( okl_k_capital_amt_csr%NOTFOUND) THEN
           OKC_API.set_message(G_APP_NAME, G_NO_CAPITAL_AMOUNT );
	   IF okl_k_capital_amt_csr%ISOPEN THEN
		CLOSE okl_k_capital_amt_csr;
	    END IF;
		x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;
	CLOSE okl_k_capital_amt_csr;


  -- Get  System Profile value of maximum deal amount....
	l_max_deal := fnd_profile.value('OKLINMAXDEALSIZE');
IF ((l_max_deal IS NULL ) OR (l_max_deal = OKC_API.G_MISS_NUM )) THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
	OKC_API.set_message(G_APP_NAME, G_NO_SYSTEM_PROFILE,G_SYS_PROFILE_NAME,'OKLINMAXDEALSIZE' );
    x_message := OKL_INS_QUOTE_PVT.G_NO_INS ;
	RAISE OKC_API.G_EXCEPTION_ERROR;
END IF ;

---- Get deal amount in functional Currency
OKL_ACCOUNTING_UTIL.convert_to_functional_currency
(
 px_ipyv_rec.KHR_ID,
 l_functional_currency,
 l_khr_st_date,
 l_con_deal_amount,
 x_contract_currency  ,
 x_currency_conversion_type ,
 x_currency_conversion_rate,
 x_currency_conversion_date,
 l_fun_deal_amount
) ;


-- Business Rule for Maximum Coverage.
IF ( l_fun_deal_amount >l_max_deal) THEN

	OKC_API.set_message(G_APP_NAME, G_NO_INSURANCE,G_COL_NAME_TOKEN,
   l_contract_number,'SYS_VALUE', 'Maximum Deal Amount'  );
	x_return_status := OKC_API.G_RET_STS_ERROR;
    x_message := OKL_INS_QUOTE_PVT.G_NO_INS ;
					-- Message --
	RAISE OKC_API.G_EXCEPTION_ERROR;
END IF;
-- Get deal term in months

		OPEN okl_k_deal_size_csr(px_ipyv_rec.KHR_ID);
		-- Changed Contract ID to Contract Number 05/16/02
		FETCH okl_k_deal_size_csr INTO l_deal_size, l_contract_number ;
		IF( okl_k_deal_size_csr%NOTFOUND) THEN
		  OKC_API.set_message(G_APP_NAME, G_NO_K_TERM,G_COL_VALUE_TOKEN,l_contract_number );
		  IF okl_k_deal_size_csr%ISOPEN THEN
		    CLOSE okl_k_deal_size_csr;
		  END IF;
		  x_return_status := OKC_API.G_RET_STS_ERROR;
		  RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;
		CLOSE okl_k_deal_size_csr;

    -- get max deal term for insurance providing
	l_max_term := fnd_profile.value('OKLINMAXTERMFORINS');
	IF ((l_max_term IS NULL ) OR (l_max_term = OKC_API.G_MISS_NUM )) THEN
		OKC_API.set_message(G_APP_NAME, G_NO_SYSTEM_PROFILE,G_SYS_PROFILE_NAME,'OKLINMAXTERMFORINS' );
	 	  x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF ;
    -- get min deal term for insurance providing
	l_min_term := fnd_profile.value('OKLINMINTERMFORINS');
	IF ((l_min_term IS NULL ) OR (l_min_term = OKC_API.G_MISS_NUM )) THEN
		OKC_API.set_message(G_APP_NAME, G_NO_SYSTEM_PROFILE,
		G_SYS_PROFILE_NAME,'OKLINMINTERMFORINS' );
		  x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF ;

  -- Business Rule for term for which we can sell insurance
	IF ( (l_deal_size >l_max_term) OR  (l_deal_size < l_min_term) ) THEN
        x_message := OKL_INS_QUOTE_PVT.G_NO_INS ;

        OKC_API.set_message(G_APP_NAME, G_NO_INSURANCE,G_COL_NAME_TOKEN,
	   l_contract_number,'SYS_VALUE', 'Deal Term'  );
  	   x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

--- To get INSURANCE oec total
	OPEN okl_k_total_oec_csr(px_ipyv_rec.KHR_ID);
	FETCH okl_k_total_oec_csr INTO l_con_total_oec ;
	IF(okl_k_total_oec_csr%NOTFOUND) THEN
	    OKC_API.set_message(G_APP_NAME, 'OKL_NO_CAPITAL_AMOUNT' );
	    IF okl_k_total_oec_csr%ISOPEN THEN
		CLOSE okl_k_total_oec_csr;
	    END IF;
	    x_return_status := OKC_API.G_RET_STS_ERROR;
	    RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF ;
	CLOSE okl_k_total_oec_csr;


--- To Check total oec as zero
IF ((l_con_total_oec IS NULL ) OR (l_con_total_oec = OKC_API.G_MISS_NUM ) or  (l_con_total_oec = 0 )) THEN
        OKC_API.set_message(G_APP_NAME, 'OKL_NO_CAPITAL_AMOUNT' );
	x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
END IF ;
px_ipyv_rec.covered_amount := l_con_total_oec ;



---- Convert total OEC to functional
  OKL_ACCOUNTING_UTIL.convert_to_functional_currency
  (
   px_ipyv_rec.KHR_ID,
   l_functional_currency,
   l_khr_st_date,
   l_con_total_oec,
   x_contract_currency  ,
   x_currency_conversion_type ,
   x_currency_conversion_rate,
   x_currency_conversion_date,
   l_fun_total_oec ) ;

  -- changes for Inventory org
  --Bug # 6318957 SSDESHPA Changes Start
  -- get min deal term for insurance providing
  --P1 bug 6318957
    IF px_ipyv_rec.ORG_ID IS NULL OR px_ipyv_rec.ORG_ID = OKC_API.G_MISS_NUM THEN
       px_ipyv_rec.ORG_ID := l_authoring_org_id;
    END IF;
   l_inv_org_id := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_ITEM_INV_ORG_ID,px_ipyv_rec.ORG_ID);
   IF ((l_inv_org_id IS NULL ) OR (l_inv_org_id = OKC_API.G_MISS_NUM )) THEN
  	OKC_API.set_message(G_APP_NAME, G_NO_SYSTEM_PROFILE,
   		G_SYS_PROFILE_NAME,'OKL_K_ITEMS_INVENTORY_ORG' );
   		  x_return_status := OKC_API.G_RET_STS_ERROR;
   		RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF ;
   --Bug # 6318957 SSDESHPA Changes End
         -- inventory org change
         OPEN okl_count_k_product_csr(px_ipyv_rec.ISU_ID,l_fun_total_oec,px_ipyv_rec.date_from,l_inv_org_id );
     	  FETCH okl_count_k_product_csr INTO l_prt_count ;
	  CLOSE okl_count_k_product_csr;


         -- inventory org change
	OPEN okl_k_product_csr(px_ipyv_rec.ISU_ID,l_fun_total_oec,px_ipyv_rec.date_from ,l_inv_org_id );
	FETCH okl_k_product_csr INTO l_product, l_product_name ;
	IF(okl_k_product_csr%NOTFOUND) THEN
       		x_message := OKL_INS_QUOTE_PVT.G_NOT_ABLE ;
		OKC_API.set_message(G_APP_NAME, 'OKL_NO_INSPRODUCT',
       		   G_COL_NAME_TOKEN,l_contract_number );
		IF okl_k_product_csr%ISOPEN THEN
		  	CLOSE okl_k_product_csr;
		END IF;
		x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE OKC_API.G_EXCEPTION_ERROR;
	ELSE

	  IF(l_prt_count > 1 ) THEN
	    x_message := l_product_name  ;
	   LOOP
	     FETCH okl_k_product_csr INTO l_product, l_product_name ;
	     EXIT WHEN okl_k_product_csr%NOTFOUND;
	     x_message := x_message || ',' || l_product_name ;
           END LOOP ;


	   OKC_API.set_message(G_APP_NAME, 'OKL_MULTIPLE_LSEINS_PRODUCTS',
	          		   G_COL_NAME_TOKEN,x_message );
	   IF okl_k_product_csr%ISOPEN THEN
	   	CLOSE okl_k_product_csr;
	   END IF;
	   x_return_status := OKC_API.G_RET_STS_ERROR;
	   RAISE OKC_API.G_EXCEPTION_ERROR;
	  END IF;
	END IF;
    px_ipyv_rec.IPT_ID  := l_product ;
	CLOSE okl_k_product_csr;

-- To implement term of policy can not be greater or less than deal term
   	IF(px_ipyv_rec.ipf_code = 'MONTHLY') THEN
		l_freq_factor := 1;
	ELSIF(px_ipyv_rec.ipf_code = 'BI_MONTHLY') THEN
		l_freq_factor := 1/2;
	ELSIF(px_ipyv_rec.ipf_code = 'HALF_YEARLY') THEN
			   l_freq_factor := 6;	--- ETC.
	ELSIF(px_ipyv_rec.ipf_code = 'QUARTERLY') THEN
			 	l_freq_factor := 3;
	ELSIF(px_ipyv_rec.ipf_code = 'YEARLY') THEN
			 	l_freq_factor := 12;
--	ELSIF(px_ipyv_rec.ipf_code = 'LEASE_FREQUENCY') THEN
			  -- To be implement
--			 	l_freq_factor := 12;
	ELSIF(px_ipyv_rec.ipf_code = 'LUMP_SUM') THEN
	 	l_freq_factor := MONTHS_BETWEEN(px_ipyv_rec.date_to,px_ipyv_rec.date_from); --20-Jan-2005 Bug# 4056484 PAGARG removing rounding
	END IF;

        -- To get assets for passed contract
      OPEN okl_k_assets_csr (px_ipyv_rec.khr_id)	;
	    px_ipyv_rec.CALCULATED_PREMIUM := 0 ;
	    LOOP
	    i := i + 1 ;
        FETCH okl_k_assets_csr INTO l_okl_k_assets_csr;
	    EXIT WHEN okl_k_assets_csr%NOTFOUND;
            l_con_oec     := l_okl_k_assets_csr.OEC ;
	     IF ((l_con_oec IS NULL ) OR (l_con_oec = OKC_API.G_MISS_NUM )) THEN
		   OKC_API.set_message(G_APP_NAME, G_NO_OEC,G_COL_NAME_TOKEN , l_okl_k_assets_csr.ASSET_DESCRIPTION);
		   x_return_status := OKC_API.G_RET_STS_ERROR;
		   RAISE OKC_API.G_EXCEPTION_ERROR;
	     END IF ;
        x_iasset_tbl(i).KLE_ID    := l_okl_k_assets_csr.KLE_ID ;
    	 IF ((x_iasset_tbl(i).KLE_ID IS NULL ) OR (x_iasset_tbl(i).KLE_ID = OKC_API.G_MISS_NUM )) THEN
		   OKC_API.set_message(G_APP_NAME, G_NO_KLE ,G_COL_NAME_TOKEN ,l_okl_k_assets_csr.ASSET_DESCRIPTION );
		   x_return_status := OKC_API.G_RET_STS_ERROR;
			RAISE OKC_API.G_EXCEPTION_ERROR;
	    END IF ;
		l_ins_class := l_okl_k_assets_csr.INSURANCE_CLASS_code ;
  		IF ((l_ins_class IS NULL ) OR (l_ins_class = OKC_API.G_MISS_CHAR )) THEN
             --
		 OKC_API.set_message(G_APP_NAME, G_NO_INS_CLASS, 'ASSET_CAT',l_okl_k_assets_csr.ASSET_CATEGORY );
		 x_return_status := OKC_API.G_RET_STS_ERROR;
		 RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF ;
      BEGIN
       -- Conver to functional OEC
       OKL_ACCOUNTING_UTIL.convert_to_functional_currency
         (
          px_ipyv_rec.KHR_ID,
          l_functional_currency,
          l_khr_st_date,
          l_con_oec,
          x_contract_currency  ,
          x_currency_conversion_type ,
          x_currency_conversion_rate,
          x_currency_conversion_date,
          l_func_oec ) ;


         OPEN okl_ins_rate_csr(px_ipyv_rec.territory_code,
         l_func_oec,l_product,
         l_ins_class , px_ipyv_rec.DATE_FROM, l_freq_factor );
	    FETCH okl_ins_rate_csr INTO l_func_premium, l_func_lessor_premium ;
	    IF(okl_ins_rate_csr%NOTFOUND) THEN
                 x_message := OKL_INS_QUOTE_PVT.G_NOT_ABLE ;
		   	 OKC_API.set_message(G_APP_NAME, 'OKL_NO_INSPRODUCT_RATE',
                      G_COL_NAME_TOKEN,l_contract_number );
		    IF okl_ins_rate_csr%ISOPEN THEN
		     	CLOSE okl_ins_rate_csr;
		     END IF;
		     x_return_status := OKC_API.G_RET_STS_ERROR;
			 RAISE OKC_API.G_EXCEPTION_ERROR;
	      END IF ;
	      -- get lessor premium in contract currency

	      OKL_ACCOUNTING_UTIL.convert_to_contract_currency
	      (
	       px_ipyv_rec.KHR_ID,
	       l_functional_currency,
	       px_ipyv_rec.DATE_FROM,
	       l_func_lessor_premium,
	       x_contract_currency  ,
	       x_currency_conversion_type ,
	       x_currency_conversion_rate ,
	       x_currency_conversion_date ,
	       x_iasset_tbl(i).LESSOR_PREMIUM
              ) ;

	        x_iasset_tbl(i).LESSOR_PREMIUM :=
	      okl_accounting_util.cross_currency_round_amount(p_amount =>
	      x_iasset_tbl(i).LESSOR_PREMIUM,
                           p_currency_code => x_contract_currency);

	      --- get asset premium in contract currency
	      OKL_ACCOUNTING_UTIL.convert_to_contract_currency
	      	      ( px_ipyv_rec.KHR_ID,
	      	       l_functional_currency,
	      	       px_ipyv_rec.DATE_FROM,
	      	       l_func_premium,
	      	       x_contract_currency  ,
	      	       x_currency_conversion_type ,
	      	       x_currency_conversion_rate ,
	      	       x_currency_conversion_date ,
	      	       x_iasset_tbl(i).PREMIUM  ) ;

	      	      x_iasset_tbl(i).PREMIUM :=
	      okl_accounting_util.cross_currency_round_amount(p_amount =>
	               x_iasset_tbl(i).PREMIUM,
                       p_currency_code => x_contract_currency);

		CLOSE okl_ins_rate_csr;

		EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
			  RAISE OKC_API.G_EXCEPTION_ERROR;
		  WHEN OTHERS THEN
                    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,
                   SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
		      IF okl_ins_rate_csr%ISOPEN THEN
  	      	      CLOSE okl_ins_rate_csr;
  	          END IF;
  	          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR ;
			  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
	   END;
		 px_ipyv_rec.CALCULATED_PREMIUM := px_ipyv_rec.CALCULATED_PREMIUM+ x_iasset_tbl(i).PREMIUM ;
	END LOOP ;
     CLOSE okl_k_assets_csr ;
	  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
END calc_lease_premium ;
----------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE calc_optional_premium
  ---------------------------------------------------------------------------
     PROCEDURE   calc_optional_premium(
         p_api_version                   IN NUMBER,
		 p_init_msg_list                IN VARCHAR2 ,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_ipyv_rec                     IN  ipyv_rec_type,
	 x_message                      OUT NOCOPY VARCHAR2,
         x_ipyv_rec                  OUT NOCOPY  ipyv_rec_type
     )IS
	l_msg_count                   NUMBER ;
	l_msg_data                      VARCHAR2(2000);
	l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'calc_optional_premium';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	p_contract_id                 NUMBER ;

   	CURSOR okl_k_deal_size_csr (p_khr_id       NUMBER) IS
       -- Bug# 4056484 PAGARG removing rounding
       SELECT MONTHS_BETWEEN(END_DATE,START_DATE), CONTRACT_NUMBER
		FROM OKC_K_HEADERS_B
		WHERE ID =  p_khr_id ;


        CURSOR okl_ins_rate_csr(p_territory_code VARCHAR2,p_covered_amount NUMBER, p_ipt_id NUMBER , p_from_date DATE, p_freq_factor NUMBER, p_fact_val NUMBER) IS
		  SELECT ((INSURED_RATE * p_covered_amount )/100 ) * p_freq_factor
			FROM OKL_INS_RATES INR
			WHERE INR.IPT_ID = p_ipt_id AND
			p_fact_val BETWEEN INR.FACTOR_RANGE_START AND INR.FACTOR_RANGE_END AND
			p_from_date BETWEEN INR.DATE_FROM AND DECODE(INR.DATE_TO,NULL,p_from_date,INR.DATE_TO)
            AND IC_ID = p_territory_code;

	   CURSOR  l_isu_csr(p_isu_id NUMBER) IS
            SELECT 'x'
            FROM OKX_INSURER_V
            WHERE PARTY_ID = p_isu_id	;
         l_ipyv_rec                     ipyv_rec_type;
	 l_max_deal  NUMBER ;
	 l_max_term  NUMBER;
         l_min_term  NUMBER;
	l_freq_factor  NUMBER;
	l_deal_amount NUMBER;
	l_deal_size NUMBER;
	l_oec       NUMBER ;
	l_ins_class VARCHAR(30) ;
	l_total_oec NUMBER ;
	l_product   NUMBER ;
        i           NUMBER  := 0 ;
	l_dummy_var VARCHAR(1) := '?' ;
	l_contract_number  OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE ;


	l_functional_currency  okl_k_headers_full_v.currency_code%TYPE := okl_accounting_util.get_func_curr_code;

	x_contract_currency   okl_k_headers_full_v.currency_code%TYPE;
	x_currency_conversion_type  okl_k_headers_full_v.currency_conversion_type%TYPE;
	x_currency_conversion_rate  okl_k_headers_full_v.currency_conversion_rate%TYPE;
	x_currency_conversion_date okl_k_headers_full_v.currency_conversion_date%TYPE;
	x_functional_covered_amt  NUMBER ;
	p_contract_currency      fnd_currencies_vl.currency_code%TYPE ;

	CURSOR l_contract_currency_csr(p_khr_id    IN   NUMBER) IS
	    SELECT  currency_code, start_date
	    FROM    okl_k_headers_full_v
         WHERE   id = p_khr_id;
         x_func_calculated_premium NUMBER ;
         l_con_start_date   DATE ;

  BEGIN

--    x_no_data_found := TRUE;
-- Get current database values
    x_message  :=   Okc_Api.G_RET_STS_SUCCESS;
   x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                             G_PKG_NAME,
                                            p_init_msg_list,
                                            l_api_version,
                                            p_api_version,
                                               '_PROCESS',
                                              x_return_status);
            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
   ------------------------------------------------------------------

           -- For Factor Value
   IF ((p_ipyv_rec.factor_value IS NULL ) OR (p_ipyv_rec.factor_value = OKC_API.G_MISS_NUM )) THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Factor Value');
      RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;



    -- For Payment frequency
  IF ((p_ipyv_rec.ipf_code IS NULL ) OR (p_ipyv_rec.ipf_code = OKC_API.G_MISS_CHAR )) THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Payment Frequency');
	x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
		-- Message --
  ELSE
		   l_return_status := Okl_Util.check_lookup_code( G_FND_LOOKUP_PAYMENT_FREQ,p_ipyv_rec.ipf_code);
	   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	      x_return_status := l_return_status;
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	     OKC_API.set_message(g_app_name,G_NO_PARENT_RECORD,g_col_name_token,
          		  	    	'Payment Frequency' ,g_parent_table_token ,'FND_LOOKUPS');
              x_return_status := l_return_status;
              RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
 END IF;
        -- For Contract ID
IF ((p_ipyv_rec.khr_id IS NULL ) OR (p_ipyv_rec.khr_id = OKC_API.G_MISS_NUM )) THEN
   x_return_status := OKC_API.G_RET_STS_ERROR;
   OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Contract ID');
   RAISE OKC_API.G_EXCEPTION_ERROR;
ELSE
   -- TEMP validate contract id
   NULL;
END IF;

 -- For From Date
IF ((p_ipyv_rec.date_from IS NULL ) OR (p_ipyv_rec.date_from = OKC_API.G_MISS_DATE )) THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Policy Effective From');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
END IF;
-- For To date
IF ((p_ipyv_rec.date_to IS NULL ) OR (p_ipyv_rec.date_to = OKC_API.G_MISS_DATE )) THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Policy Effective To');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
END IF;

-- Quote date
IF ((p_ipyv_rec.DATE_QUOTED  IS NULL ) OR (p_ipyv_rec.DATE_QUOTED  = OKC_API.G_MISS_DATE )) THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Quote Effective From');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
END IF;
-- Quote expiry date
IF ((p_ipyv_rec.DATE_QUOTE_EXPIRY IS NULL ) OR (p_ipyv_rec.DATE_QUOTE_EXPIRY = OKC_API.G_MISS_DATE )) THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Quote Effective To');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
END IF;

 --- From and To Date
 l_return_status:= Okl_Util.check_from_to_date_range( p_ipyv_rec.date_from  ,p_ipyv_rec.date_to );
 IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                          -- store SQL error message on message stack for caller
             OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,
                                                SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
 		     x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR ;
             RAISE G_EXCEPTION_HALT_VALIDATION;
 ELSIF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	Okc_Api.set_message(
	p_app_name     => g_app_name,
	p_msg_name     => 'OKL_GREATER_THAN',
	p_token1       => 'COL_NAME1',
	p_token1_value => 'End Date',
	p_token2       => 'COL_NAME2',
	p_token2_value => 'Start Date'
	);
     x_return_status := OKC_API.G_RET_STS_ERROR;
     RAISE OKC_API.G_EXCEPTION_ERROR;
 END IF;

-- For Covered Amount Check
IF ((p_ipyv_rec.COVERED_AMOUNT IS NULL ) OR (p_ipyv_rec.COVERED_AMOUNT = OKC_API.G_MISS_NUM )) THEN
	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Covered Amount');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE OKC_API.G_EXCEPTION_ERROR;
END IF;
------------------------------------------------------------------
-- For IPY TYPE
IF ((p_ipyv_rec.ipy_type IS NULL ) OR (p_ipyv_rec.ipy_type = OKC_API.G_MISS_CHAR )) THEN
		 OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Policy Type');
			x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE OKC_API.G_EXCEPTION_ERROR;
ELSE
		IF(  p_ipyv_rec.ipy_type <> 'OPTIONAL_POLICY' )THEN
			  OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Policy Type',G_COL_VALUE_TOKEN, 'Optional Policy' );
			   x_return_status := OKC_API.G_RET_STS_ERROR;
			   RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF ;
END IF;


		OPEN okl_k_deal_size_csr(p_ipyv_rec.KHR_ID);
		FETCH okl_k_deal_size_csr INTO l_deal_size , l_contract_number ;
		IF( okl_k_deal_size_csr%NOTFOUND) THEN
		    	   OKC_API.set_message(G_APP_NAME, G_NO_K_TERM,G_COL_VALUE_TOKEN,l_contract_number );
		  				x_return_status := OKC_API.G_RET_STS_ERROR;
		  	IF okl_k_deal_size_csr%ISOPEN THEN
		    	   CLOSE okl_k_deal_size_csr;
		    	 END IF;
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;
		CLOSE okl_k_deal_size_csr;






     		 IF(p_ipyv_rec.ipf_code = 'MONTHLY') THEN
			   l_freq_factor := 1;
		 ELSIF(p_ipyv_rec.ipf_code = 'HALF_YEARLY') THEN
			l_freq_factor := 6;	--- ETC.
		 ELSIF(p_ipyv_rec.ipf_code = 'QUARTERLY') THEN
			l_freq_factor := 3;
		 ELSIF(p_ipyv_rec.ipf_code = 'YEARLY') THEN
			l_freq_factor := 12;
--		 ELSIF(p_ipyv_rec.ipf_code = 'LEASE_FREQUENCY') THEN
			  -- To be implement
--		 	l_freq_factor := 12;
		 ELSIF(p_ipyv_rec.ipf_code = 'LUMP_SUM') THEN
		 -- To be implement
			 	l_freq_factor := MONTHS_BETWEEN( p_ipyv_rec.date_to,p_ipyv_rec.date_from); --Bug# 4056484 PAGARG removing rounding
                ELSE
                  OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,
                     G_COL_VALUE_TOKEN,'Payment Frequency' );
		    x_return_status := OKC_API.G_RET_STS_ERROR;
           	    RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;
		x_ipyv_rec.CALCULATED_PREMIUM := 0 ;

         -- Convert covered amount to functional currency
         --1 Get Contract Currency


	 	OPEN l_contract_currency_csr(p_ipyv_rec.KHR_ID);
	 	FETCH l_contract_currency_csr INTO  p_contract_currency, l_con_start_date;
	 	IF( l_contract_currency_csr%NOTFOUND) THEN
	 	  OKC_API.set_message(G_APP_NAME, G_NO_K_TERM,G_COL_VALUE_TOKEN,l_contract_number );
			x_return_status := OKC_API.G_RET_STS_ERROR;
		  IF l_contract_currency_csr%ISOPEN THEN
			CLOSE l_contract_currency_csr;
		  END IF;
	 	  RAISE OKC_API.G_EXCEPTION_ERROR;
	 	END IF;
	 	CLOSE l_contract_currency_csr;


         --2 get converted amount
         OKL_ACCOUNTING_UTIL.convert_to_functional_currency
	 (
	  p_ipyv_rec.khr_id,
	  l_functional_currency ,
	  l_con_start_date,
	  p_ipyv_rec.COVERED_AMOUNT,
	  x_contract_currency  ,
	  x_currency_conversion_type ,
	  x_currency_conversion_rate  ,
	  x_currency_conversion_date,
	  x_functional_covered_amt
          ) ;

	 OPEN okl_ins_rate_csr(p_ipyv_rec.territory_code,x_functional_covered_amt
	 ,p_ipyv_rec.ipt_id , p_ipyv_rec.DATE_FROM, l_freq_factor,
	  p_ipyv_rec.factor_value );
	  FETCH okl_ins_rate_csr INTO x_func_calculated_premium ;
	 IF(okl_ins_rate_csr%NOTFOUND) THEN
		OKC_API.set_message(G_APP_NAME, 'OKL_NO_OPTINSPRODUCT_RATE');
		x_return_status := OKC_API.G_RET_STS_ERROR;
	   IF okl_ins_rate_csr%ISOPEN THEN
  	      	      CLOSE okl_ins_rate_csr;
  	    END IF;
			  RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;
	CLOSE okl_ins_rate_csr;

	OKL_ACCOUNTING_UTIL.convert_to_contract_currency
		 	 (
			  p_ipyv_rec.khr_id,
		 	  l_functional_currency,
		 	  p_ipyv_rec.DATE_FROM,
		 	  x_func_calculated_premium,
		 	  x_contract_currency  ,
		 	  x_currency_conversion_type ,
		 	  x_currency_conversion_rate  ,
		 	  x_currency_conversion_date,
		 	  x_ipyv_rec.CALCULATED_PREMIUM
                  ) ;
                    x_ipyv_rec.CALCULATED_PREMIUM :=
		  okl_accounting_util.cross_currency_round_amount(p_amount =>
		    x_ipyv_rec.CALCULATED_PREMIUM,
                    p_currency_code => x_contract_currency);


	  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
END calc_optional_premium ;

---------------------------------------------------------------------------
-- Start of comments
--skgautam
-- Function Name	: calc_total_premium
--workflow
-- Description		:Calculates the total premium
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
-- Added as part of fix of bug:3967640

PROCEDURE calc_total_premium(p_api_version                  IN NUMBER,
                             p_init_msg_list                IN VARCHAR2 ,
                             x_return_status                OUT NOCOPY VARCHAR2,
                             x_msg_count                    OUT NOCOPY NUMBER,
                             x_msg_data                     OUT NOCOPY VARCHAR2,
                             p_pol_qte_id                   IN  VARCHAR2,
                             x_total_premium                OUT NOCOPY NUMBER) IS

 l_msg_count                   NUMBER ;
 l_msg_data                    VARCHAR2(2000);
 l_api_version                 CONSTANT NUMBER := 1;
 l_api_name                    CONSTANT VARCHAR2(30) := 'calc_total_premium';
 l_return_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

 l_ipf_code                    VARCHAR2(50);
 l_freq_factor                 NUMBER;
 l_date_to                     DATE;
 l_date_from                   DATE;
 l_premium                     NUMBER := 0;
 l_pol_durs                    NUMBER := 0;
 l_tot_durs                    NUMBER := 0;
 l_tot_premium                 NUMBER := 0;

--bug:3967640
 l_contract_id                 OKC_K_HEADERS_B.ID%TYPE;
 l_currency                    OKC_K_HEADERS_B.CURRENCY_CODE%TYPE;
 l_precision                   NUMBER:= 0;

--Declaring cursor to get policy/quote premium,frequny info.
CURSOR c_pol_qte_dtl(c_id NUMBER) IS
SELECT premium,ipf_code,date_from,date_to,khr_id
FROM   OKL_INS_POLICIES_B
WHERE  ID = c_id;

--Get contract currency
CURSOR c_contract_currency_csr(p_khr_id    IN   NUMBER) IS
SELECT  CURRENCY_CODE
FROM    OKC_K_HEADERS_B
WHERE   ID = p_khr_id;

--Get contract currency Precision
CURSOR c_currency_precision(p_currency_code VARCHAR2) IS
SELECT PRECISION
FROM fnd_currencies_vl
WHERE currency_code = p_currency_code
AND enabled_flag = 'Y'
AND TRUNC(NVL(start_date_active, SYSDATE)) <= TRUNC(SYSDATE)
AND TRUNC(NVL(end_date_active, SYSDATE))   >= TRUNC(SYSDATE);
BEGIN

x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                            G_PKG_NAME,
                                            p_init_msg_list,
                                            l_api_version,
                                            p_api_version,
                                            '_PROCESS',
                                            l_return_status);
            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

--Open cursor for QOTE or POLICY
OPEN c_pol_qte_dtl(p_pol_qte_id);
FETCH c_pol_qte_dtl INTO l_premium,l_ipf_code,l_date_from,l_date_to,l_contract_id;
CLOSE c_pol_qte_dtl;

-- bug:3967640
-- Open cursor to get currency code
OPEN  c_contract_currency_csr(l_contract_id) ;
FETCH c_contract_currency_csr INTO l_currency;
CLOSE c_contract_currency_csr ;

-- bug:3967640
-- Open cursor to get currency precision
OPEN c_currency_precision(l_currency);
FETCH c_currency_precision INTO l_precision;
CLOSE c_currency_precision;

--getting the total policy duration
    l_pol_durs  := ROUND(MONTHS_BETWEEN( l_date_to,l_date_from));

--setting frequency factor value based on payment frequency
    IF(l_ipf_code = 'MONTHLY') THEN
			  l_freq_factor := 1;
    ELSIF(l_ipf_code = 'BI_MONTHLY') THEN
        l_freq_factor := 1/2;
		 ELSIF(l_ipf_code = 'HALF_YEARLY') THEN
			  l_freq_factor := 6;
		 ELSIF(l_ipf_code = 'QUARTERLY') THEN
			  l_freq_factor := 3;
		 ELSIF(l_ipf_code = 'YEARLY') THEN
			  l_freq_factor := 12;
		 ELSE
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,
        G_COL_VALUE_TOKEN,'Payment Frequency' );
        x_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
	l_tot_durs    := l_pol_durs/l_freq_factor;
-- calculating total premium
	l_tot_premium := l_premium * l_tot_durs;
        l_tot_premium := TRUNC(l_tot_premium,l_precision); --bug:3967640
	x_total_premium := l_tot_premium;

OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
END calc_total_premium;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    NULL;
  END api_copy;
    FUNCTION get_stream_header (
    p_stmv_rec                     IN Okl_Stm_Pvt.stmv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN Okl_Stm_Pvt.stmv_rec_type IS
    CURSOR okl_stmv_pk_csr (p_khr_id            IN NUMBER,
	p_kle_id   IN NUMBER,
	p_sty_id IN NUMBER) IS
    SELECT  ID,
            OBJECT_VERSION_NUMBER,
            SGN_CODE,
            SAY_CODE,
            STY_ID,
            KLE_ID,
            KHR_ID,
            ACTIVE_YN,
            DATE_CURRENT,
            DATE_WORKING,
            DATE_HISTORY,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            PROGRAM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Streams_V
     WHERE okl_streams_v.khr_id     = p_khr_id AND
	 okl_streams_v.kle_id     = p_kle_id
	 AND okl_streams_v.sty_id     = p_sty_id;
    l_okl_stmv_pk                  okl_stmv_pk_csr%ROWTYPE;
    l_stmv_rec                     Okl_Stm_Pvt.stmv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_stmv_pk_csr (p_stmv_rec.khr_id,p_stmv_rec.kle_id,p_stmv_rec.sty_id  );
    FETCH okl_stmv_pk_csr INTO
              l_stmv_rec.ID,
              l_stmv_rec.OBJECT_VERSION_NUMBER,
              l_stmv_rec.SGN_CODE,
              l_stmv_rec.SAY_CODE,
              l_stmv_rec.STY_ID,
              l_stmv_rec.KLE_ID,
              l_stmv_rec.KHR_ID,
              l_stmv_rec.ACTIVE_YN,
              l_stmv_rec.DATE_CURRENT,
              l_stmv_rec.DATE_WORKING,
              l_stmv_rec.DATE_HISTORY,
              l_stmv_rec.COMMENTS,
              l_stmv_rec.CREATED_BY,
              l_stmv_rec.CREATION_DATE,
              l_stmv_rec.LAST_UPDATED_BY,
              l_stmv_rec.LAST_UPDATE_DATE,
              l_stmv_rec.PROGRAM_ID,
              l_stmv_rec.REQUEST_ID,
              l_stmv_rec.PROGRAM_APPLICATION_ID,
              l_stmv_rec.PROGRAM_UPDATE_DATE,
              l_stmv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_stmv_pk_csr%NOTFOUND;
    CLOSE okl_stmv_pk_csr;
    RETURN(l_stmv_rec);
  END get_stream_header;
  ----------------------------------------------------------------------------
  ------- activate_ins_streams
  ----------------------------------------------------------------------------
    PROCEDURE  activate_ins_streams(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_contract_id                  IN NUMBER
         ) IS
	l_msg_count                   NUMBER ;
	l_msg_data                      VARCHAR2(2000);
	l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ACTIVATE_INS_STREAMS';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	CURSOR okl_ipyv_pk_csr (p_id       NUMBER) IS
	     SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            KHR_ID,
	    KLE_ID,
            ISS_CODE,
            IPY_TYPE
      FROM Okl_Ins_Policies_V
     WHERE Okl_Ins_Policies_V.KHR_ID  = p_id
           AND ISS_CODE = 'ACCEPTED' ;
	 l_okl_ipyv_pk_csr    okl_ipyv_pk_csr%ROWTYPE;
    l_ipyv_rec                     ipyv_rec_type;
	lx_ipyv_rec                     ipyv_rec_type;
  BEGIN
--    x_no_data_found := TRUE;
-- Get current database values
   l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                       G_PKG_NAME,
                                                      p_init_msg_list,
                                                      l_api_version,
                                                      p_api_version,
                                                      '_PROCESS',
                                                      l_return_status);

            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

      OPEN okl_ipyv_pk_csr (p_contract_id)	;
	  LOOP
       FETCH okl_ipyv_pk_csr INTO l_okl_ipyv_pk_csr;
	      EXIT WHEN okl_ipyv_pk_csr%NOTFOUND;
              l_ipyv_rec.ID := l_okl_ipyv_pk_csr.ID ;
              l_ipyv_rec.OBJECT_VERSION_NUMBER := l_okl_ipyv_pk_csr.OBJECT_VERSION_NUMBER ;
              l_ipyv_rec.KLE_ID  := l_okl_ipyv_pk_csr.KLE_ID ;
			  l_ipyv_rec.KHR_ID  := l_okl_ipyv_pk_csr.KHR_ID ;
			  l_ipyv_rec.ISS_CODE := l_okl_ipyv_pk_csr.ISS_CODE ;
              l_ipyv_rec.IPY_TYPE  := l_okl_ipyv_pk_csr.IPY_TYPE ;
	 	activate_ins_stream(
	          p_api_version                    => l_api_version,
	          p_init_msg_list                => Okc_Api.G_FALSE,
	          x_return_status                => l_return_status,
	          x_msg_count                    => x_msg_count,
	          x_msg_data                     => x_msg_data,
	          p_ipyv_rec                     => l_ipyv_rec
	          );
	       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            CLOSE okl_ipyv_pk_csr;
	 	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	 	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            CLOSE okl_ipyv_pk_csr;
	 	  	RAISE OKC_API.G_EXCEPTION_ERROR;
	       END IF;
   		l_ipyv_rec.ISS_CODE := 'PENDING' ;

		-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies
		  IF(IS_DEBUG_PROCEDURE_ON) THEN
		    BEGIN
		        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
		    END;
		  END IF;
		Okl_Ins_Policies_Pub.update_ins_policies(
			         p_api_version                  => p_api_version,
			          p_init_msg_list                => OKC_API.G_FALSE,
			          x_return_status                => l_return_status,
			          x_msg_count                    => x_msg_count,
			          x_msg_data                     => x_msg_data,
			          p_ipyv_rec                     => l_ipyv_rec,
			          x_ipyv_rec                     => lx_ipyv_rec
			          );
		  IF(IS_DEBUG_PROCEDURE_ON) THEN
		    BEGIN
		        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
		    END;
		  END IF;
		-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies

		 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
		    RAISE OKC_API.G_EXCEPTION_ERROR;
		 END IF;

	END LOOP ;
	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  --     x_no_data_found := okl_inav_pk_csr%NOTFOUND;
      CLOSE okl_ipyv_pk_csr;
    EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
END activate_ins_streams ;
 ---------------------------------------------------------------------------
  -- FUNCTION validate_contract_line
  ---------------------------------------------------------------------------
 FUNCTION validate_contract_line (
          p_kle_id IN  NUMBER
        ) RETURN VARCHAR2 IS
          l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
		  l_dummy_var		VARCHAR2(1) := '?' ;
          CURSOR okl_k_line_csr(p_kle_id  IN NUMBER) IS
	        SELECT 'x'
	        FROM  OKL_K_LINES
       WHERE  OKL_K_LINES.ID = p_kle_id;
        BEGIN
          OPEN  okl_k_line_csr(p_kle_id);
         FETCH okl_k_line_csr INTO l_dummy_var ;
         CLOSE okl_k_line_csr ;
		     	-- still set to default means data was not found
    		IF ( l_dummy_var = '?' ) THEN
    			OKC_API.set_message(g_app_name,
    						G_INVALID_CONTRACT_LINE);
    			l_return_status := OKC_API.G_RET_STS_ERROR;
    		END IF;
         RETURN(l_return_status);
         EXCEPTION
           WHEN OTHERS THEN
               -- store SQL error message on message stack for caller
               OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      		-- notify caller of an UNEXPECTED error
      		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      		-- verify that cursor was closed
		IF okl_k_line_csr%ISOPEN THEN
		   CLOSE okl_k_line_csr;
		END IF;
          	RETURN(l_return_status);
      END validate_contract_line;
-----------------------------------------------------------------------
   PROCEDURE  activate_ins_streams(
		 errbuf           OUT NOCOPY VARCHAR2,
		 retcode          OUT NOCOPY NUMBER
      )  IS
	l_init_msg_list              VARCHAR2(1) := Okc_Api.G_FALSE ;
	l_msg_count                   NUMBER ;
	l_msg_data                      VARCHAR2(2000);
	l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ACTIVATE_INS_STREAMS';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	l_percentage_criteria         NUMBER ;
	l_afterlease_criteria         NUMBER ;

    l_policy_id                   NUMBER;
    l_policy_number               VARCHAR2(50);
    activated_pol_tbl             OKL_INS_QUOTE_PVT.policy_tbl_type ;
    nonactivated_pol_tbl          OKL_INS_QUOTE_PVT.policy_tbl_type;
    l_activated_counter           NUMBER := 0;
    l_notactivated_counter        NUMBER := 0;
    l_khr_number                  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE := OKC_API.G_MISS_CHAR ;

    -- Bug 3742614 Modified Cursor definition
    CURSOR okl_eli_policies_csr(l_afterlease_criteria  IN NUMBER,l_percentage_criteria IN NUMBER )
    IS
      SELECT IPY.ID
            ,IPY.POLICY_NUMBER
            ,OKHB.CONTRACT_NUMBER
      FROM OKC_K_HEADERS_B OKHB
          ,OKL_INS_POLICIES_B IPY
          ,OKL_TRX_CONTRACTS CTRX
          ,OKC_STATUSES_B OSTS
      WHERE OKHB.ID = IPY.KHR_ID
        AND OKHB.ID = CTRX.KHR_ID
        AND OKHB.STS_CODE = OSTS.CODE
        AND OSTS.STE_CODE = 'ACTIVE'
        AND IPY.ISS_CODE = 'PENDING'
        AND CTRX.TCN_TYPE = 'BKG'
       --rkuttiya added for 12.1.1 Multi GAAP
        AND CTRX.REPRESENTATION_TYPE = 'PRIMARY'
       --
        AND (CTRX.DATE_TRANSACTION_OCCURRED + l_afterlease_criteria) < SYSDATE

      UNION

      SELECT IPY.ID
            ,IPY.POLICY_NUMBER
            ,OKHB.CONTRACT_NUMBER
      FROM OKC_K_HEADERS_B OKHB
          ,OKL_INS_POLICIES_B IPY
          ,OKL_IN_RAMOUNT_BC_V KLRA -- Bug 5897792
      WHERE KLRA.KLE_ID = IPY.KLE_ID
        AND OKHB.ID = IPY.KHR_ID -- smoduga fix for 4383565
        AND KLRA.AMOUNT_RECEIVED >= (IPY.PREMIUM * l_percentage_criteria);

    l_okl_eli_policies_csr	okl_eli_policies_csr%ROWTYPE;
	BEGIN

      -- Bug 3742614 Formatted Output
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'-------------------------------------------------------------');
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'---      Automatic Insurance Activation Start      ---');
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'-------------------------------------------------------------');
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'--Request: '|| FND_GLOBAL.CONC_REQUEST_ID|| ' ---------Date: '||TO_CHAR(SYSDATE)||'  ---');
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'-------------------------------------------------------------');

	-- Get values from system profile
	l_afterlease_criteria := fnd_profile.value('OKLINDAYSFORACTIVATION');
    -- Bug 3742614 changed the profile name and output message
	l_percentage_criteria := fnd_profile.value('OKLINPERCENTFORACTIVATION');
	-- Check for NULL values and return if either of these is null
	IF l_afterlease_criteria = Okc_Api.G_MISS_NUM OR l_afterlease_criteria IS NULL    THEN
		 Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'SYSTEM PROFILE FOR OKLINDAYSFORACTIVATION IS NOT defined');
	   RETURN;
    END IF;
		-- Check for NULL values and return if any of these is null
	IF l_percentage_criteria = Okc_Api.G_MISS_NUM OR     l_percentage_criteria IS NULL    THEN
        Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'SYSTEM PROFILE FOR OKLINPERCENTFORACTIVATION IS NOT defined');
        RETURN;
    END IF;
    OPEN  okl_eli_policies_csr(l_afterlease_criteria ,l_percentage_criteria );
	LOOP
      FETCH okl_eli_policies_csr INTO l_okl_eli_policies_csr;
	    EXIT WHEN okl_eli_policies_csr%NOTFOUND;

        l_policy_id := l_okl_eli_policies_csr.ID;
        l_policy_number := l_okl_eli_policies_csr.POLICY_NUMBER;
        l_khr_number := l_okl_eli_policies_csr.CONTRACT_NUMBER;

        -- Bug 3742614 Calling different procedure to activate policy
	 	activate_ins_policy(
	          p_api_version                    => l_api_version,
	          p_init_msg_list                => Okc_Api.G_TRUE,
	          x_return_status                => l_return_status,
	          x_msg_count                    => l_msg_count,
	          x_msg_data                     => l_msg_data,
	          p_ins_policy_id                => l_policy_id
	          );

        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- Bug 3742614 building the table for Formated output for activated and
          -- errored policies with reasons
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Policy Number : ' ||l_policy_number|| ' Can not be Activated' );
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'--Reason IS ----' );
          FOR i IN 1..l_msg_count
          LOOP
            JTF_PLSQL_API.get_messages(i,l_msg_data);
            Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
          END LOOP;
          l_notactivated_counter := l_notactivated_counter + 1;
          nonactivated_pol_tbl(l_notactivated_counter).CONTRACT_NUMBER := l_khr_number;
          nonactivated_pol_tbl(l_notactivated_counter).POLICY_NUMBER := l_policy_number;
          RETURN;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
        THEN
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Policy Number : ' ||l_policy_number || ' Can not be Activated' );
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'--Reason is ----' );
          FOR i IN 1..l_msg_count
          LOOP
            JTF_PLSQL_API.get_messages(i,l_msg_data);
            Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
          END LOOP;
          l_notactivated_counter:= l_notactivated_counter + 1 ;
          nonactivated_pol_tbl(l_notactivated_counter).CONTRACT_NUMBER := l_khr_number;
          nonactivated_pol_tbl(l_notactivated_counter).POLICY_NUMBER := l_policy_number;
        ELSE
          l_activated_counter:= l_activated_counter + 1;
          activated_pol_tbl(l_activated_counter).CONTRACT_NUMBER := l_khr_number;
          activated_pol_tbl(l_activated_counter).POLICY_NUMBER := l_policy_number;
        END IF;

	END LOOP ;
    CLOSE okl_eli_policies_csr ;

    -- Bug 3742614 Formated output
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'---------------------- Summary -----------------------------');
    IF (activated_pol_tbl.COUNT > 0)
    THEN
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'---- Policies Activated -----');
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||'Contract Number     Policy Number ' );
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||'--------------------------------' );

      FOR i IN activated_pol_tbl.first..activated_pol_tbl.last
      LOOP
        Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||activated_pol_tbl(i).CONTRACT_NUMBER  ||'    ' ||activated_pol_tbl(i).POLICY_NUMBER  );
      END LOOP;

      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Total    = ' || activated_pol_tbl.COUNT);
    END IF;

    IF (nonactivated_pol_tbl.COUNT > 0)
    THEN
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'---- Policies Not Activated -----');
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||'Contract Number     Policy Number ' );
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||'--------------------------------' );

      FOR n IN nonactivated_pol_tbl.first..nonactivated_pol_tbl.last
      LOOP
        Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||nonactivated_pol_tbl(n).CONTRACT_NUMBER  ||'    ' ||nonactivated_pol_tbl(n).POLICY_NUMBER );
      END LOOP;

      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Total   = ' || nonactivated_pol_tbl.COUNT);
    END IF;

    Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'-------------------------------------------------------------');
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'---      Automatic Insurance Activation End      ---');
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'-------------------------------------------------------------');

  END  activate_ins_streams ;
---------------------------------------------------------------------------
  -- PROCEDURE activate_ins_stream
  ---------------------------------------------------------------------------
PROCEDURE  activate_ins_stream(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN ipyv_rec_type
         )IS

        p_sty_id NUMBER;
	l_stmv_rec		     Okl_Streams_Pvt.stmv_rec_type;
	l_row_notfound                 BOOLEAN := TRUE;
	l_msg_count                   NUMBER ;
	l_msg_data                      VARCHAR2(2000);
	l_api_version                 CONSTANT NUMBER := 1;
    	l_api_name                     CONSTANT VARCHAR2(30) := 'ACTIVATE_INS_STREAM';
    	l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	x_stmv_rec		   Okl_Streams_Pvt.stmv_rec_type;
	l_khr_status                    VARCHAR2 (30) ;
	lx_ipyv_rec       				ipyv_rec_type ;
	l_ipyv_rec                     ipyv_rec_type ;
        l_contract_number           VARCHAR2(120); --3745151 Invalid error message fix.
   BEGIN
		   l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                       G_PKG_NAME,
                                                      p_init_msg_list,
                                                      l_api_version,
                                                      p_api_version,
                                                      '_PROCESS',
                                                      l_return_status);

            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

-------------------------------------------------------------------------
---- Check for Status of Contract
---------------------------------------------------------------------------
	l_return_status :=	get_contract_status(p_ipyv_rec.khr_id, l_khr_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


-------------------------------------------------------------------------
---- Check for Policy Statuses
---------------------------------------------------------------------------

   IF (p_ipyv_rec.ISS_CODE <> 'ACCEPTED' ) THEN
      OKC_API.set_message(G_APP_NAME,'OKL_INVALID_POLICY' );
	  l_return_status := OKC_API.G_RET_STS_ERROR ;
	   RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF ;


-------------------------------------------------------------------------
---- Check for Contract Line
---------------------------------------------------------------------------
l_return_status :=	validate_contract_line(p_ipyv_rec.kle_id);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
---------------------------------------------------------------------
----------- get stream
-------------------------------------------------------------------
        --  get Stream type

     -- Call to get the stream type id, change made for insurance user defined streams,  bug 3924300

           OKL_STREAMS_UTIL.get_primary_stream_type(p_ipyv_rec.khr_id,
                                                   'INSURANCE_RECEIVABLE',
                                                   l_return_status,
                                                   p_sty_id);

        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                     OKC_API.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN,'INSURANCE RECEIVABLE'); --bug 4024785
                     RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;



        	-- SET values to retrieve record
	     l_stmv_rec.khr_id :=  p_ipyv_rec.khr_id ;
	     l_stmv_rec.kle_id :=  p_ipyv_rec.kle_id ;
	     l_stmv_rec.sty_id :=  p_sty_id ;


	     -- get Stream Record
		  l_stmv_rec := get_stream_header(l_stmv_rec,l_row_notfound );

	      IF (l_row_notfound = TRUE ) THEN
			 OKC_API.set_message(G_APP_NAME,
             	   G_NO_STREAM_REC_FOUND
               			   );
		     RAISE OKC_API.G_EXCEPTION_ERROR;
		  END IF;

		 IF (   UPPER(l_stmv_rec.active_yn)= 'Y'  ) THEN
                    SELECT contract_number INTO l_contract_number
                    from OKC_K_HEADERS_B
                    WHERE ID = p_ipyv_rec.khr_id;
	       OKC_API.set_message(G_APP_NAME,
               G_STREAM_ALREADY_ACTIVE,'COL_NAME',l_contract_number);

		     RAISE OKC_API.G_EXCEPTION_ERROR;
		  END IF;
		  l_stmv_rec.active_yn := 'Y' ;
		  l_stmv_rec.date_current := SYSDATE ;
          l_stmv_rec.SAY_CODE := 'CURR' ;
-- Start of wraper code generated automatically by Debug code generator for Okl_Streams_Pub.update_streams
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call Okl_Streams_Pub.update_streams   ');
    END;
  END IF;
		  Okl_Streams_Pub.update_streams  (
	   p_api_version                   => l_api_version,
       p_init_msg_list                => Okc_Api.G_FALSE  ,
       x_return_status                => l_return_status  ,
       x_msg_count                    => x_msg_count,
       x_msg_data                     => x_msg_data ,
       p_stmv_rec                     =>  l_stmv_rec,
       x_stmv_rec                       => x_stmv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call Okl_Streams_Pub.update_streams   ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Streams_Pub.update_streams

	        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN

              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
			l_ipyv_rec  := p_ipyv_rec ;
			l_ipyv_rec.ISS_CODE := 'PENDING' ;

-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
             Okl_Ins_Policies_Pub.update_ins_policies(
	         p_api_version                  => p_api_version,
	          p_init_msg_list                => OKC_API.G_FALSE,
	          x_return_status                => l_return_status,
	          x_msg_count                    => x_msg_count,
	          x_msg_data                     => x_msg_data,
	          p_ipyv_rec                     => l_ipyv_rec,
	          x_ipyv_rec                     => lx_ipyv_rec
	          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies

          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

          -- gboomina start - Bug 4728636
          OKL_BILLING_CONTROLLER_PVT.track_next_bill_date ( p_ipyv_rec.khr_id );
          -- gboomina end - Bug 4728636

	  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
	  EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
END  activate_ins_stream ;

 ---------------------------------------------------------------------------
  -- PROCEDURE policy_payment
  ---------------------------------------------------------------------------
  PROCEDURE        policy_payment(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_rec                   IN  ipyv_rec_type)
      IS
      	 l_api_version                 CONSTANT NUMBER := 1;
         l_api_name                     CONSTANT VARCHAR2(30) := 'policy_payment';
         l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
         l_lessor_premium              NUMBER;
         l_yearly_payment              NUMBER;
         CURSOR okl_lessor_premium(p_ipy_id NUMBER) IS
         SELECT SUM(LESSOR_PREMIUM)
         FROM OKL_INS_ASSETS INA
         WHERE  INA.IPY_ID = p_ipy_id ;

         l_percentage NUMBER ;
         l_term NUMBER;
         l_not_yearly_pay NUMBER;
         l_strm_type_id  NUMBER;


       l_factor  NUMBER;

       l_payment_tbl  NUMBER := 0 ;

        CURSOR okl_ins_rate_csr(p_territory_code VARCHAR2,
           p_ipt_id NUMBER , p_from_date DATE, p_fact_val NUMBER) IS
		  SELECT INSURER_RATE/ INSURED_RATE
			FROM OKL_INS_RATES INR
			WHERE INR.IPT_ID = p_ipt_id AND
			p_fact_val BETWEEN INR.FACTOR_RANGE_START AND INR.FACTOR_RANGE_END AND
			p_from_date BETWEEN INR.DATE_FROM AND DECODE(INR.DATE_TO,NULL,p_from_date + 1,INR.DATE_TO)
            AND IC_ID = p_territory_code;



    CURSOR c_trx_type (cp_name VARCHAR2, cp_language VARCHAR2) IS
      SELECT  id
      FROM    okl_trx_types_tl
      WHERE   name      = cp_name
      AND     language  = cp_language;



       l_payment  NUMBER;
       l_yearly_payment_freq NUMBER := 0 ;
       j NUMBER := 0;
       l_ptid NUMBER ;
       l_trx_type_ID NUMBER ;
       lnsexp_tbl_type insexp_tbl_type;
       lnsexp_index  NUMBER ;
       l_payment_tbl_type payment_tbl_type;

      BEGIN

                   l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                     G_PKG_NAME,
                                                      p_init_msg_list,
                                                      l_api_version,
                                                      p_api_version,
                                                      '_PROCESS',
                                                      x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;


-- gboomina starts Bug#4661337 Changed OKLINPERCENTTOTOTALPAYMENT tO OKLINPERCENTTOTALPAYMENT
                l_percentage  := fnd_profile.value('OKLINPERCENTTOTALPAYMENT');
-- gboomina ends Bug#4661337
              IF((l_percentage IS NULL ) OR (l_percentage = OKC_API.G_MISS_NUM )) THEN
                 l_percentage := 1;
              ELSE
                l_percentage := l_percentage /100 ;
              END IF;





              -- GET stream type
   -- Cursor replaced with the call to get the stream type id, change made for insurance user defined streams,  bug 3924300

     OKL_STREAMS_UTIL.get_primary_stream_type(p_ipyv_rec.khr_id,
                                                   'INSURANCE_PAYABLE',
                                                   l_return_status,
                                                   l_strm_type_id);

     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_PAYABLE'); --bug 4024785
                   x_return_status := OKC_API.G_RET_STS_ERROR ;
                   RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;


               OPEN c_trx_type ('Disbursement', 'US');
               FETCH c_trx_type INTO l_trx_type_ID;
               IF(c_trx_type%NOTFOUND) THEN
                         Okc_Api.set_message(G_APP_NAME,'OKL_AM_NO_TRX_TYPE_FOUND',
                           'TRY_NAME','Disbursement'); --Changed message code for bug 3745151
                         x_return_status := OKC_API.G_RET_STS_ERROR ;
                         CLOSE c_trx_type ;
                     RAISE OKC_API.G_EXCEPTION_ERROR;
               END if ;
               CLOSE c_trx_type ;


         IF (p_ipyv_rec.IPY_TYPE = 'LEASE_POLICY'  ) THEN
           OPEN okl_lessor_premium(p_ipyv_rec.id) ;
           FETCH  okl_lessor_premium INTO l_lessor_premium ;
           IF (okl_lessor_premium%NOTFOUND) THEN
             		  OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,
                   G_COL_NAME_TOKEN,'Policy Number' );
                   CLOSE  okl_lessor_premium ;
        		  RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
           CLOSE  okl_lessor_premium ;

               	IF(p_ipyv_rec.ipf_code = 'MONTHLY') THEN
            		l_yearly_payment := l_percentage * l_lessor_premium * 12;
            	ELSIF(p_ipyv_rec.ipf_code = 'BI_MONTHLY') THEN
            		l_yearly_payment := l_percentage * l_lessor_premium * 24;
            	ELSIF(p_ipyv_rec.ipf_code = 'HALF_YEARLY') THEN
			       l_yearly_payment := l_percentage * l_lessor_premium * 2;	--- ETC.
            	ELSIF(p_ipyv_rec.ipf_code = 'QUARTERLY') THEN
			     	l_yearly_payment := l_percentage * l_lessor_premium * 4 ;
            	ELSIF(p_ipyv_rec.ipf_code = 'YEARLY') THEN
			     	l_yearly_payment := l_percentage * l_lessor_premium ;
            	END IF;
          ELSIF (P_ipyv_rec.IPY_TYPE = 'OPTIONAL_POLICY'  ) THEN

             OPEN okl_ins_rate_csr(p_ipyv_rec.territory_code , p_ipyv_rec.ipt_id  ,
             p_ipyv_rec.date_from , p_ipyv_rec.factor_value );
            FETCH okl_ins_rate_csr INTO l_factor ;
            IF(okl_ins_rate_csr%NOTFOUND) THEN
		OKC_API.set_message(G_APP_NAME, 'OKL_NO_OPTINSPRODUCT_RATE');
                x_return_status := OKC_API.G_RET_STS_ERROR ;
             CLOSE okl_ins_rate_csr ;
             RAISE OKC_API.G_EXCEPTION_ERROR;
             END if ;
            CLOSE okl_ins_rate_csr;


--            l_factor := l_insurer_rate / l_insured_rate ;

               	IF(p_ipyv_rec.ipf_code = 'MONTHLY') THEN
            		l_yearly_payment := l_percentage * (p_ipyv_rec.CALCULATED_PREMIUM * l_factor) * 12;
            	ELSIF(p_ipyv_rec.ipf_code = 'BI_MONTHLY') THEN
            		l_yearly_payment := l_percentage * (p_ipyv_rec.CALCULATED_PREMIUM * l_factor) * 24;
            	ELSIF(p_ipyv_rec.ipf_code = 'HALF_YEARLY') THEN
			       l_yearly_payment := l_percentage * (p_ipyv_rec.CALCULATED_PREMIUM * l_factor) * 2;	--- ETC.
            	ELSIF(p_ipyv_rec.ipf_code = 'QUARTERLY') THEN
			     	l_yearly_payment := l_percentage * (p_ipyv_rec.CALCULATED_PREMIUM * l_factor) * 4 ;
            	ELSIF(p_ipyv_rec.ipf_code = 'YEARLY') THEN
			     	l_yearly_payment := l_percentage * (p_ipyv_rec.CALCULATED_PREMIUM * l_factor) ;
            	END IF;
          END IF;

                l_term := MONTHS_BETWEEN(p_ipyv_rec.DATE_TO, p_ipyv_rec.DATE_FROM); --Bug# 4056484 PAGARG removing rounding

                l_yearly_payment_freq := ROUND(l_term / 12) ;
                --gboomina Bug 4774011 - Round of l_term - Start
                l_not_yearly_pay :=  mod(ROUND(l_term), 12);
                --gboomina Bug 4774011 - Round of l_term - End

                lnsexp_tbl_type(1).AMOUNT  :=  l_yearly_payment /12 ;
                lnsexp_tbl_type(1).PERIOD  :=  l_term;


                IF (l_yearly_payment_freq > 0 ) then

                    FOR i IN 1..l_yearly_payment_freq LOOP
                     j := i - 1 ;

                    -- CREATE table for expense
                l_payment_tbl := l_payment_tbl + 1;
                l_payment_tbl_type(l_payment_tbl).DUE_DATE :=add_months(p_ipyv_rec.date_from, (j )*12) ; -- Bug 4213633
                l_payment_tbl_type(l_payment_tbl).AMOUNT :=l_yearly_payment ;

                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                 END IF;
                 END LOOP;
             END IF;

             IF (l_not_yearly_pay > 0 ) THEN
              --j := j + 1; bug 4056603


                l_payment := l_not_yearly_pay * (l_yearly_payment/12) ;

                l_payment_tbl := l_payment_tbl + 1;
                --gboomina Bug 4774011 - Changing the calculation of Due date - Start
                l_payment_tbl_type(l_payment_tbl).DUE_DATE := add_months(p_ipyv_rec.date_from, (l_yearly_payment_freq)*12) ; --bug 4056603
                --gboomina Bug 4774011 - Changing the calculation of Due date - End
                l_payment_tbl_type(l_payment_tbl).AMOUNT :=l_payment ;
             END IF ;


         payment_stream(
                    p_api_version                  =>l_api_version,
                    p_init_msg_list             => OKC_API.G_FALSE,
                    x_return_status             =>   l_return_status,
                    x_msg_count                =>    x_msg_count,
                    x_msg_data                  =>  x_msg_data ,
                   p_ipyv_rec                 => p_ipyv_rec,
                 p_payment_tbl_type   =>  l_payment_tbl_type );

                  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                 END IF;




             -- Create accrual streams
	     	 create_insexp_streams(
	     		            p_api_version                  =>l_api_version,
				    p_init_msg_list             => OKC_API.G_FALSE,
				    x_return_status             => l_return_status,
				    x_msg_count                =>  x_msg_count,
                		    x_msg_data                  =>  x_msg_data ,
	     		            p_insexp_tbl                => lnsexp_tbl_type,
	     		            p_khr_id          => p_ipyv_rec.khr_id ,
                   		    p_kle_id          => p_ipyv_rec.kle_id,
	     		            p_date_from       => p_ipyv_rec.date_from  );


	     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	     	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	     	 RAISE OKC_API.G_EXCEPTION_ERROR;
	      END IF;


	 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
     EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
       END policy_payment;

 ---------------------------------------------------------------------------
  -- PROCEDURE activate_insurance_policy
  ---------------------------------------------------------------------------
PROCEDURE   activate_ins_policy(
         p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ins_policy_id                     IN NUMBER
         ) IS

         CURSOR c_vendor_exist (p_khr_id NUMBER , p_isu_id  NUMBER) IS
         select 'x'
            from
              OKC_K_PARTY_ROLES_B CPLB
            where  CPLB.CHR_ID = p_khr_id
               and CPLB.DNZ_CHR_ID = p_khr_id
               and CPLB.OBJECT1_ID1 = p_isu_id
               and CPLB.JTOT_OBJECT1_CODE = 'OKX_VENDOR'
               and CPLB.RLE_CODE = 'OKL_VENDOR';




	       	CURSOR  C_OKL_STRM_TYPE_REC2_V IS
			select ID
			from OKL_STRM_TYPE_TL
			where NAME = 'INSURANCE EXPENSE'
	       	AND  LANGUAGE = 'US';



    ---- For accrual
    CURSOR c_okl_strem_rec_acc (l_recv_strm_id NUMBER,
       p_contract_line NUMBER,
       p_contract_id NUMBER  ) IS
       SELECT STM.ID , STM.active_yn
       FROM  OKL_STREAMS STM
       WHERE  STM.STY_ID = l_recv_strm_id
      AND STM.KLE_ID = p_contract_line
      AND STM.KHR_ID = p_contract_id
      AND STM.PURPOSE_CODE IS NULL;


    ---- For Reporting accrual
    CURSOR c_okl_strem_rec_repacc (l_recv_strm_id NUMBER ,
       p_contract_line NUMBER,
       p_contract_id NUMBER ) IS
       SELECT STM.ID , STM.active_yn
       FROM  OKL_STREAMS STM
       WHERE  STM.STY_ID = l_recv_strm_id
      AND STM.KLE_ID = p_contract_line
      AND STM.KHR_ID = p_contract_id
      AND STM.PURPOSE_CODE ='REPORT';


	l_stmv_rec		     Okl_Streams_Pvt.stmv_rec_type;
	l_stmv_rec2		     Okl_Streams_Pvt.stmv_rec_type;
	l_stmv_rec3		     Okl_Streams_Pvt.stmv_rec_type;
	l_stmv_rec4		     Okl_Streams_Pvt.stmv_rec_type;

	x_stmv_rec		   Okl_Streams_Pvt.stmv_rec_type;

        lx_ipyv_rec                    	ipyv_rec_type ;
	l_ipyv_rec                     	ipyv_rec_type ;
	 l_api_version                 	CONSTANT NUMBER := 1;
         l_api_name                     CONSTANT VARCHAR2(30) := 'activate_ins_policy';
         l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
         l_clev_rec			okl_okc_migration_pvt.clev_rec_type;
         lx_clev_rec		        okl_okc_migration_pvt.clev_rec_type;
	 l_klev_rec			Okl_Kle_Pvt.klev_rec_type ;
	 l_dummy                    	VARCHAR2(1) := '?';
         lx_klev_rec		        Okl_Kle_Pvt.klev_rec_type ;
         l_row_notfound                 BOOLEAN := TRUE;
	 l_khr_status                 	VARCHAR2(30) ;
         l_cplv_rec_type                okl_okc_migration_pvt.cplv_rec_type;
         x_cplv_rec_type                okl_okc_migration_pvt.cplv_rec_type;
         p_sty_id                       NUMBER;
         l_total_oec                    NUMBER;

	 --gboomina 26-Oct-05 Bug#4558486 - Added - Start
         l_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;
         lx_kplv_rec     okl_k_party_roles_pvt.kplv_rec_type;
         --gboomina 26-Oct-05 Bug#4558486 - Added - End


CURSOR okl_k_total_oec_csr (p_khr_id       NUMBER ) IS --Bug 4105057
SELECT SUM(OEC)
FROM
(
SELECT  OTAB.DNZ_KHR_ID CONTRACT_ID,
        KLE_TOP.OEC OEC,
        OTAB.ASSET_NUMBER ASSET_NUMBER
FROM OKL_TXL_ASSETS_B OTAB,
       OKL_K_LINES KLE,
       OKL_K_LINES KLE_TOP,
       OKC_K_LINES_B CLE
WHERE KLE.ID = OTAB.KLE_ID
  AND KLE.ID = CLE.ID
  AND CLE.CLE_ID = KLE_TOP.ID
  AND NOT EXISTS
      (Select '1'
       from okc_k_items cim
       where cim.cle_id = otab.kle_id
       AND cim.object1_id1 is not null)
  AND CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED' )
  AND OTAB.DNZ_KHR_ID  = p_khr_id
UNION
SELECT OTAB.DNZ_KHR_ID CONTRACT_ID,KLE_TOP.OEC OEC,
OTAB.ASSET_NUMBER ASSET_NUMBER
FROM OKL_TXL_ASSETS_B OTAB,
     OKL_K_LINES KLE ,
     OKL_K_LINES KLE_TOP ,
     OKC_K_LINES_B CLE ,
     OKL_K_HEADERS KHR
WHERE KLE.ID = OTAB.KLE_ID
  AND KLE.ID = CLE.ID
  AND CLE.CLE_ID = KLE_TOP.ID
  AND NOT EXISTS
      (Select '1'
       from okc_k_items cim
       where cim.cle_id = otab.kle_id
       AND cim.object1_id1 is not null)
  AND khr.id = CLE.DNZ_CHR_ID
  AND khr.deal_type = 'LOAN'
  AND CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED','BOOKED' )
  AND OTAB.DNZ_KHR_ID  = p_khr_id
UNION
select CLE.DNZ_CHR_ID CONTRACT_ID,
       KLE.OEC OEC,
       FAD.ASSET_NUMBER ASSET_NUMBER
from OKL_K_LINES KLE ,
     OKC_K_LINES_B CLE,
     OKC_LINE_STYLES_B LS,
     OKC_K_ITEMS CIM,
     OKC_K_LINES_B ITEM_CLE,
     OKC_LINE_STYLES_B ITEM_LS,
     OKC_K_ITEMS MODEL ,
     FA_ADDITIONS_B FAd,
     OKC_K_LINES_B FINAC_CLE,
     OKC_LINE_STYLES_B FINAC_LS
where FINAC_LS.LTY_CODE = 'FREE_FORM1'
  AND FINAC_CLE.LSE_ID = FINAC_LS.ID
  AND FINAC_CLE.ID = KLE.ID
  AND FAD.ASSET_ID = CIM.OBJECT1_ID1
  AND CIM.OBJECT1_ID2 = '#'
  AND MODEL.JTOT_OBJECT1_CODE = 'OKX_SYSITEM'
  AND MODEL.DNZ_CHR_ID = CLE.DNZ_CHR_ID
  AND MODEL.cle_id = ITEM_CLE.ID
  AND ITEM_LS.LTY_CODE = 'ITEM'
  AND ITEM_LS.ID = ITEM_CLE.LSE_ID
  AND ITEM_CLE.CLE_ID = FINAC_CLE.ID
  AND CIM.DNZ_CHR_ID = CLE.DNZ_CHR_ID
  AND CIM.CLE_ID = CLE.ID
  AND CIM.JTOT_OBJECT1_CODE = 'OKX_ASSET'
  AND LS.ID = CLE.LSE_ID
  AND LS.LTY_CODE = 'FIXED_ASSET'
  AND CLE.CLE_ID = FINAC_CLE.ID
  AND FINAC_CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED' )
  AND CLE.DNZ_CHR_ID = p_khr_id
union
SELECT CLE.DNZ_CHR_ID CONTRACT_ID,
       KLE.OEC OEC,
       FINAN_CLET.NAME ASSET_NUMBER
FROM OKL_K_LINES KLE,
     OKC_K_LINES_B CLE,
     OKC_LINE_STYLES_B LS,
     OKC_K_LINES_B ITEM_CLE,
     OKC_LINE_STYLES_B ITEM_LS,
     OKC_K_ITEMS MODEL ,
     OKL_K_HEADERS KHR ,
     OKC_K_LINES_B FINAN_CLE ,
     OKC_K_LINES_TL FINAN_CLET
WHERE MODEL.cle_id = ITEM_CLE.ID
  AND MODEL.DNZ_CHR_ID = ITEM_CLE.DNZ_CHR_ID
  AND ITEM_LS.LTY_CODE = 'ITEM'
  AND ITEM_LS.ID = ITEM_CLE.LSE_ID
  AND ITEM_CLE.CLE_ID = FINAN_CLE.ID
  AND ITEM_CLE.DNZ_CHR_ID = FINAN_CLE.DNZ_CHR_ID
  AND CLE.CLE_ID = FINAN_CLE.ID
  AND CLE.DNZ_CHR_ID = FINAN_CLE.DNZ_CHR_ID
  AND LS.ID = CLE.LSE_ID
  AND LS.LTY_CODE = 'FIXED_ASSET'
  AND FINAN_CLE.STS_CODE NOT IN ( 'TERMINATED' , 'EXPIRED','ABANDONED' )
  AND FINAN_CLET.LANGUAGE = USERENV('LANG')
  AND FINAN_CLET.ID = FINAN_CLE.ID
  AND KLE.ID = FINAN_CLE.ID
  AND FINAN_CLE.DNZ_CHR_ID = KHR.ID
  AND FINAN_CLE.CHR_ID = KHR.ID
  AND FINAN_CLE.CLE_ID is null
  AND KHR.DEAL_TYPE = 'LOAN'
  AND CLE.DNZ_CHR_ID = p_khr_id)
  GROUP BY CONTRACT_ID;
	BEGIN
        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                       G_PKG_NAME,
                                                      p_init_msg_list,
                                                      l_api_version,
                                                      p_api_version,
                                                      '_PROCESS',
                                                      x_return_status);
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := Okc_Api.G_RET_STS_ERROR;
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              -- Status temp
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

----------------------------------------------------------------------
-----------  get Record ---------------------------------------
---------------------------------------------------------------------
       l_ipyv_rec.ID := p_ins_policy_id ;
       l_ipyv_rec :=   get_rec (l_ipyv_rec, l_row_notfound );
--------------------------------------------------------------------------
----  Check for Quote or Policy
------------------------------------------------------------------------

-- check for Third Party
   IF (l_ipyv_rec.IPY_TYPE = 'THIRD_PARTY_POLICY'  ) THEN
		  OKC_API.set_message(G_APP_NAME,G_INVALID_FOR_ACTIVE_TYPE,
           G_COL_NAME_TOKEN,l_ipyv_rec.IPY_TYPE );
            -- Status temp
		  RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;
-------------------------------------------------------------------------
------ Check for Policy Status
-------------------------------------------------------------------------
 -- Check for Status
	IF (l_ipyv_rec.ISS_CODE <> 'PENDING' ) THEN
		  OKC_API.set_message(G_APP_NAME,G_INVALID_FOR_ACTIVE_STATUS ); --3745151 Fix for invalid error message.
		  RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

-------------------------------------------------------------------------
---- Check for Status of Contract
---------------------------------------------------------------------------
	l_return_status :=	get_contract_status(l_ipyv_rec.khr_id, l_khr_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   IF (l_khr_status <> 'ACTIVE' ) THEN
      OKC_API.set_message(G_APP_NAME,G_K_NOT_ACTIVE );
	  RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF ;

   ------------------------------------------------------------------
   ---------- Compare OEC
   --------------------------------------------------
   IF (l_ipyv_rec.IPY_TYPE = 'LEASE_POLICY') THEN

        OPEN okl_k_total_oec_csr(l_ipyv_rec.KHR_ID );
        FETCH okl_k_total_oec_csr INTO l_total_oec ;
        CLOSE okl_k_total_oec_csr ;
       IF ((l_total_oec IS NULL ) OR l_total_oec  = OKC_API.G_MISS_NUM  ) THEN
		OKC_API.set_message(G_APP_NAME,'OKL_INVALID_VALUE',
		G_COL_NAME_TOKEN,'OEC' );
		RAISE OKC_API.G_EXCEPTION_ERROR;
	ELSIF( l_total_oec <>  l_ipyv_rec.COVERED_AMOUNT ) THEN
	  	OKC_API.set_message(G_APP_NAME,'OKL_STRUCTURE_CHANGED');
		RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;


   END IF ;

   ------------------------------

			-- Set Values in OKC_CONTRACT_LINE
---------------------------------------------------------------------------
			l_clev_rec.ID := l_ipyv_rec.KLE_ID ;
  			l_clev_rec.sts_code :=  'BOOKED';
			l_klev_rec.ID := l_ipyv_rec.KLE_ID ;

		  Okl_Contract_Pub.update_contract_line
		   (
    	   p_api_version      => l_api_version ,
		   p_init_msg_list           => OKC_API.G_FALSE,
		   x_return_status      => l_return_status    ,
		   x_msg_count           => x_msg_count,
		   x_msg_data            => x_msg_data ,
		   p_clev_rec            => l_clev_rec  ,
		   p_klev_rec            => l_klev_rec,
		   x_clev_rec            => lx_clev_rec,
		   x_klev_rec            => lx_klev_rec
		   );

            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              -- Status temp
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN

              -- Status temp
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
            -- CREATE  Role only if vendor is not there
            OPEN c_vendor_exist(l_ipyv_rec.KHR_ID ,l_ipyv_rec.ISU_ID );
            FETCH c_vendor_exist INTO l_dummy ;
            CLOSE c_vendor_exist ;

            IF ( l_dummy = '?' ) THEN

            	l_cplv_rec_type.sfwt_flag := 'N';
            	l_cplv_rec_type.CHR_ID := l_ipyv_rec.KHR_ID ;
            	l_cplv_rec_type.DNZ_CHR_ID := l_ipyv_rec.KHR_ID ;
            	l_cplv_rec_type.RLE_CODE := 'OKL_VENDOR' ;
            	l_cplv_rec_type.OBJECT1_ID1 := l_ipyv_rec.ISU_ID ;
            	l_cplv_rec_type.OBJECT1_ID2 := '#' ;
            	l_cplv_rec_type.JTOT_OBJECT1_CODE :=  'OKX_VENDOR' ;
-- Start of wraper code generated automatically by Debug code generator for okl_k_party_roles_pvt.create_k_party_role
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call okl_k_party_roles_pvt.create_k_party_role ');
    END;
  END IF;
  -- gboomina 26-Oct-05 Bug#4558486 Start - Changed okl_okc_migration_pvt.create_k_party_role to okl_k_party_roles_pvt.create_k_party_role
            	okl_k_party_roles_pvt.create_k_party_role(
        		p_api_version                  =>l_api_version,
        		p_init_msg_list             => OKC_API.G_FALSE,
        		x_return_status             =>   l_return_status,
        		 x_msg_count                =>    x_msg_count,
        		x_msg_data                  =>  x_msg_data ,
        		p_cplv_rec                     =>  l_cplv_rec_type,
        		x_cplv_rec                  =>    x_cplv_rec_type,
			p_kplv_rec                  => l_kplv_rec,
                        x_kplv_rec                  => lx_kplv_rec);

-- gboomina 26-Oct-05 Bug#4558486 End - Changed okl_okc_migration_pvt.create_k_party_role to okl_k_party_roles_pvt.create_k_party_role
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call okl_k_party_roles_pvt.create_k_party_role ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_k_party_roles_pvt.create_k_party_role
        	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

             	  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        	  RAISE OKC_API.G_EXCEPTION_ERROR;
        	END IF;
          END IF ;


        	-- Payment Call Temp

          	policy_payment(
              p_api_version                  => p_api_version,
	      p_init_msg_list                => OKC_API.G_FALSE,
	      x_return_status                => l_return_status,
	      x_msg_count                    => x_msg_count,
	      x_msg_data                     => x_msg_data,
	      p_ipyv_rec                     => l_ipyv_rec );


                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	  	       RAISE OKC_API.G_EXCEPTION_ERROR;
	        END IF;


          -------- Activate Policy
		  l_ipyv_rec.ISS_CODE := 'ACTIVE' ;
          l_ipyv_rec.ACTIVATION_DATE := SYSDATE ;
-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
          Okl_Ins_Policies_Pub.update_ins_policies(
	      p_api_version                  => p_api_version,
	      p_init_msg_list                => OKC_API.G_FALSE,
	      x_return_status                => l_return_status,
	      x_msg_count                    => x_msg_count,
	      x_msg_data                     => x_msg_data,
	      p_ipyv_rec                     => l_ipyv_rec,
	      x_ipyv_rec                     => lx_ipyv_rec	);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies

          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	  	RAISE OKC_API.G_EXCEPTION_ERROR;
	  END IF;



	      -- Activate Income Accrual Streams

                   -- cursor fetch replaced with  the call, change made for user defined streams,  bug 3924300
                OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_INCOME_ACCRUAL',
                                                   l_return_status,
                                                   p_sty_id);

                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        OKC_API.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN,'INSURANCE_INCOME_ACCRUAL' ); --bug 4024785
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;




		   --- For Accrual
		       OPEN c_okl_strem_rec_acc(p_sty_id,
		        l_ipyv_rec.kle_id,
		        l_ipyv_rec.khr_id);
		       FETCH c_okl_strem_rec_acc INTO  l_stmv_rec.id, l_stmv_rec.active_yn;
		  	 IF(l_stmv_rec.id IS NOT NULL AND l_stmv_rec.id <> OKC_API.G_MISS_NUM) THEN

		  	    IF (   UPPER(l_stmv_rec.active_yn)= 'Y'  ) THEN
			   	OKC_API.set_message(G_APP_NAME,
			   	G_STREAM_ALREADY_ACTIVE  );

			   	RAISE OKC_API.G_EXCEPTION_ERROR;
	      		    END IF;

	      		    l_stmv_rec.active_yn := 'Y' ;
			    l_stmv_rec.date_current := SYSDATE ;
			    l_stmv_rec.SAY_CODE := 'CURR' ;


-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
		              OKL_STREAMS_PUB.update_streams(
		                  p_api_version
		                 ,p_init_msg_list
		                  ,x_return_status
		                  ,x_msg_count
		                  ,x_msg_data
		                  ,l_stmv_rec
		                  ,x_stmv_rec
		               );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams

		           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		              CLOSE c_okl_strem_rec_acc ;
		              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
		              CLOSE c_okl_strem_rec_acc ;
		              RAISE OKC_API.G_EXCEPTION_ERROR;
		           END IF;
		        END IF;
                     CLOSE c_okl_strem_rec_acc ;




                     --- For Reporting Accrual
		       OPEN c_okl_strem_rec_repacc(p_sty_id,
		        l_ipyv_rec.kle_id,
		        l_ipyv_rec.khr_id);
		       FETCH c_okl_strem_rec_repacc INTO  l_stmv_rec2.id, l_stmv_rec2.active_yn;
		  	 IF(l_stmv_rec2.id IS NOT NULL AND l_stmv_rec2.id <> OKC_API.G_MISS_NUM) THEN

		  	    IF (   UPPER(l_stmv_rec2.SAY_CODE)= 'CURR'  ) THEN --3965948
			   	OKC_API.set_message(G_APP_NAME,
			   	G_STREAM_ALREADY_ACTIVE  );

			   	CLOSE c_okl_strem_rec_repacc ;
			   	RAISE OKC_API.G_EXCEPTION_ERROR;
	      		    END IF;

                                    -- Made stream inactive bug 3965948
	      		    l_stmv_rec2.active_yn := 'N' ;
			    l_stmv_rec2.date_current := SYSDATE ;
			    l_stmv_rec2.SAY_CODE := 'CURR' ;


-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
		              OKL_STREAMS_PUB.update_streams(
		                  p_api_version
		                 ,p_init_msg_list
		                  ,x_return_status
		                  ,x_msg_count
		                  ,x_msg_data
		                  ,l_stmv_rec2
		                  ,x_stmv_rec
		               );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams

		           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		              CLOSE c_okl_strem_rec_repacc ;
		              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
		              CLOSE c_okl_strem_rec_repacc ;
		              RAISE OKC_API.G_EXCEPTION_ERROR;
		           END IF;
		        END IF;
                     CLOSE c_okl_strem_rec_repacc ;


 	      		---- For expense

                        -- cursor fetch replaced with function call, change done for user defined streams,  bug 3924300


		         OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_EXPENSE_ACCRUAL',
                                                   l_return_status,
                                                   p_sty_id);

		     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        OKC_API.set_message(G_APP_NAME,'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN,'INSURANCE_EXPENSE_ACCRUAL'); --bug 4024785
                        RAISE OKC_API.G_EXCEPTION_ERROR;
		     END IF;



			   --- For Accrual
			       OPEN c_okl_strem_rec_acc(p_sty_id,
				l_ipyv_rec.kle_id,
				l_ipyv_rec.khr_id);
			       FETCH c_okl_strem_rec_acc INTO  l_stmv_rec3.id, l_stmv_rec3.active_yn;
				 IF(l_stmv_rec3.id IS NOT NULL AND l_stmv_rec3.id <> OKC_API.G_MISS_NUM) THEN

				    IF (   UPPER(l_stmv_rec3.active_yn)= 'Y'  ) THEN
					OKC_API.set_message(G_APP_NAME,
					G_STREAM_ALREADY_ACTIVE  );

					RAISE OKC_API.G_EXCEPTION_ERROR;
				    END IF;

				    l_stmv_rec3.active_yn := 'Y' ;
				    l_stmv_rec3.date_current := SYSDATE ;
				    l_stmv_rec3.SAY_CODE := 'CURR' ;


-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
				      OKL_STREAMS_PUB.update_streams(
					  p_api_version
					 ,p_init_msg_list
					  ,x_return_status
					  ,x_msg_count
					  ,x_msg_data
					  ,l_stmv_rec3
					  ,x_stmv_rec
				       );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams

				   IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
				      CLOSE c_okl_strem_rec_acc ;
				      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
				   ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
				      CLOSE c_okl_strem_rec_acc ;
				      RAISE OKC_API.G_EXCEPTION_ERROR;
				   END IF;
				END IF;
			     CLOSE c_okl_strem_rec_acc ;




			     --- For Reporting Accrual
			       OPEN c_okl_strem_rec_repacc(p_sty_id,
				l_ipyv_rec.kle_id,
				l_ipyv_rec.khr_id);
			       FETCH c_okl_strem_rec_repacc INTO  l_stmv_rec4.id, l_stmv_rec4.active_yn;
				 IF(l_stmv_rec4.id IS NOT NULL AND l_stmv_rec4.id <> OKC_API.G_MISS_NUM) THEN

				    IF (   UPPER(l_stmv_rec4.SAY_CODE)= 'CURR'  ) THEN -- 3965948
					OKC_API.set_message(G_APP_NAME,
					G_STREAM_ALREADY_ACTIVE  );

					CLOSE c_okl_strem_rec_repacc ;
					RAISE OKC_API.G_EXCEPTION_ERROR;
				    END IF;

                                    -- Made Stream inactive bug 3965948
				    l_stmv_rec4.active_yn := 'N' ;
				    l_stmv_rec4.date_current := SYSDATE ;
				    l_stmv_rec4.SAY_CODE := 'CURR' ;


-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
				      OKL_STREAMS_PUB.update_streams(
					  p_api_version
					 ,p_init_msg_list
					  ,x_return_status
					  ,x_msg_count
					  ,x_msg_data
					  ,l_stmv_rec4
					  ,x_stmv_rec
				       );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams

				   IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
				      CLOSE c_okl_strem_rec_repacc ;
				      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
				   ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
				      CLOSE c_okl_strem_rec_repacc ;
				      RAISE OKC_API.G_EXCEPTION_ERROR;
				   END IF;
				END IF;
                     CLOSE c_okl_strem_rec_repacc ;


	  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
     EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
          WHEN OTHERS THEN
            x_return_status :=OKC_API.HANDLE_EXCEPTIONS
            (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PROCESS'
            );
		END  activate_ins_policy;
--------------------------------------------------------------------------------

  ----------------------------------------------------------------
    --- Accept Optional Quote --------
    ----------------------------------------------------------------
    PROCEDURE accept_optional_quote(
           p_api_version                  IN NUMBER,
           p_init_msg_list                IN VARCHAR2 ,
           x_return_status                OUT NOCOPY VARCHAR2,
           x_msg_count                    OUT NOCOPY NUMBER,
           x_msg_data                     OUT NOCOPY VARCHAR2,
           p_quote_id                     IN NUMBER,
           x_policy_number 		  OUT NOCOPY VARCHAR2
           ) IS
 l_api_version                 CONSTANT NUMBER := 1;
     l_api_name                     CONSTANT VARCHAR2(30) := 'accept_optional_quote';
     l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_quote_type                   VARCHAR2(30);
     l_ipyv_rec 			           ipyv_rec_type ;
     l_inqv_rec                     ipyv_rec_type ;
 	lx_inqv_rec                    ipyv_rec_type ;
     lx_ipyv_rec                   ipyv_rec_type ;
     l_row_notfound    BOOLEAN := TRUE ;
	 l_kle_id    NUMBER ;
	 l_khr_status  VARCHAR2(30);
     FUNCTION get_optional_policy (
               l_inqv_rec               IN   ipyv_rec_type
             ) RETURN ipyv_rec_type IS
               l_ipyv_rec 			   ipyv_rec_type ;

            -- Smoduga Fix for 3232868 Increment policy number for optional quotes.

               l_seq                    NUMBER ;
               l_policy_symbol          VARCHAR2(10) ;

              CURSOR c_policy_symbol IS
              SELECT POLICY_SYMBOL
               FROM OKL_INS_PRODUCTS_B
               WHERE id = l_ipyv_rec.ipt_id;

            -- END Smoduga Fix for 3232868 Increment policy number for optional quotes.

             BEGIN
             	l_ipyv_rec := l_inqv_rec ;

             -- Smoduga Fix for 3232868 Increment policy number for optional quotes.
                    BEGIN
                      SELECT OKL_IPY_SEQ.NEXTVAL INTO l_seq FROM dual;
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        -- store SQL error message on message stack for caller
                       OKC_API.set_message(G_APP_NAME,  'OKL_NO_SEQUENCE'  );
                    WHEN OTHERS THEN
                        -- store SQL error message on message stack for caller
                       OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                 	-- notify caller of an UNEXPECTED error
        		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	            END ;
               OPEN c_policy_symbol;
               FETCH c_policy_symbol INTO l_policy_symbol ;
                  IF( c_policy_symbol%NOTFOUND) THEN
                 	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> G_INVALID_VALUE,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'Policy Symbol');
                   END IF;
               close c_policy_symbol ;

	        l_ipyv_rec.POLICY_NUMBER := l_policy_symbol || TO_CHAR(l_seq) ;

            -- END Smoduga Fix for 3232868 Increment policy number for optional quotes.

 	        l_ipyv_rec.ID := OKC_API.G_MISS_NUM ;
 	        l_ipyv_rec.object_version_number := 1 ;
 	        l_ipyv_rec.ISS_CODE := 'ACCEPTED'; -- Fix for bug 2522378
 	        l_ipyv_rec.QUOTE_YN  := 'N' ;
 	        l_ipyv_rec.DATE_QUOTED := OKC_API.G_MISS_DATE ;
 	        l_ipyv_rec.DATE_QUOTE_EXPIRY := OKC_API.G_MISS_DATE ;
 	        l_ipyv_rec.ORG_ID := OKC_API.G_MISS_NUM;
 	        l_ipyv_rec.REQUEST_ID := OKC_API.G_MISS_NUM;
 	        l_ipyv_rec.PROGRAM_APPLICATION_ID := OKC_API.G_MISS_NUM;
 	        l_ipyv_rec.PROGRAM_ID := OKC_API.G_MISS_NUM;
 	        l_ipyv_rec.PROGRAM_UPDATE_DATE := OKC_API.G_MISS_DATE ;
 	        l_ipyv_rec.created_by          :=   OKC_API.G_MISS_NUM;
 	        l_ipyv_rec.creation_date       := OKC_API.G_MISS_DATE ;
 	        l_ipyv_rec.last_updated_by     :=   OKC_API.G_MISS_NUM;
 	        l_ipyv_rec.last_update_date    := OKC_API.G_MISS_DATE ;
             l_ipyv_rec.last_update_login   :=   OKC_API.G_MISS_NUM;
               	RETURN(l_ipyv_rec);
           END get_optional_policy;
      BEGIN
           l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                      G_PKG_NAME,
                                                     p_init_msg_list,
                                                     l_api_version,
                                                     p_api_version,
                                                     '_PROCESS',
                                                     x_return_status);
           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
           -- Assigning ID to record
           l_inqv_rec.id := p_quote_id ;
           -- Get the current quote from database
       	  l_inqv_rec := get_rec(l_inqv_rec);
 	    -- Validate whether it is accetable quote or not
 		/*
 		      1. Quote should not be expired
 		      2. Status of Quote should be quote
 		      3. It should not be Third party policy
 			  */
 		   -- Check for Status
 		   IF (l_inqv_rec.ISS_CODE <> 'QUOTE' AND l_inqv_rec.QUOTE_YN <> 'YES'  ) THEN
 		      OKC_API.set_message(G_APP_NAME,
 	               	G_INVALID_QUOTE );
                RAISE OKC_API.G_EXCEPTION_ERROR;
 			END IF;
 			-- Check for Status
 		   IF (l_inqv_rec.DATE_QUOTE_EXPIRY < SYSDATE ) THEN
 		      OKC_API.set_message(G_APP_NAME,
 	               	G_EXPIRED_QUOTE );
             RAISE OKC_API.G_EXCEPTION_ERROR;
 			END IF;
 			-- Check for Third Party is taken care in deciding policy type
          -- Make Policy related changes
          l_ipyv_rec := get_optional_policy(l_inqv_rec);
           -- Insert Policy
-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.insert_ins_policies
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.insert_ins_policies ');
    END;
  END IF;
           Okl_Ins_Policies_Pub.insert_ins_policies(
          p_api_version                  => p_api_version,
           p_init_msg_list                => OKC_API.G_FALSE,
           x_return_status                => l_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_ipyv_rec                     => l_ipyv_rec,
           x_ipyv_rec                     => lx_ipyv_rec
           );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.insert_ins_policies ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.insert_ins_policies
           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
 	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
 	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
 	  	RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
        l_ipyv_rec.id := lx_ipyv_rec.id ;
 	  -- Create Line
 	create_contract_line(
          p_api_version                  => l_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ipyv_rec                     => l_ipyv_rec,
          x_kle_id 		=> l_kle_id );
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
 	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
 	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
 	  	RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
    	l_ipyv_rec.KLE_ID := l_kle_id ;
    -- Create Stream
              create_ins_streams(
         p_api_version                    => l_api_version,
         p_init_msg_list                => Okc_Api.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_ipyv_rec                     => l_ipyv_rec
         );

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	  	RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

          create_insinc_streams(
         p_api_version                    => l_api_version,
         p_init_msg_list                => Okc_Api.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_ipyv_rec                     => l_ipyv_rec
        );

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	  	RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

     -- activate stream
	 -------------------------------------------------------------------------
---- Check for Status of Contract
---------------------------------------------------------------------------
	l_return_status :=	get_contract_status(l_ipyv_rec.khr_id, l_khr_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


	 	 	activate_ins_stream(
	          p_api_version                    => l_api_version,
	          p_init_msg_list                => Okc_Api.G_FALSE,
	          x_return_status                => l_return_status,
	          x_msg_count                    => x_msg_count,
	          x_msg_data                     => x_msg_data,
	          p_ipyv_rec                     => l_ipyv_rec
	          );

	       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	 	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	 	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	 	  	RAISE OKC_API.G_EXCEPTION_ERROR;
		  ELSIF	(l_return_status = G_NOT_ACTIVE) THEN
			  NULL;
	       END IF;
	  IF (l_khr_status = 'ACTIVE' ) THEN
		-- activate policy
		   activate_ins_policy(
	          p_api_version                    => l_api_version,
	          p_init_msg_list                => Okc_Api.G_FALSE,
	          x_return_status                => l_return_status,
	          x_msg_count                    => x_msg_count,
	          x_msg_data                     => x_msg_data,
			   p_ins_policy_id               => l_ipyv_rec.id
	          );
	       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	 	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	 	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	 	  	RAISE OKC_API.G_EXCEPTION_ERROR;
	       END IF;
	  END IF;
	  -----
     -- update quote
           -- Put Policy Number in Quote record
           l_inqv_rec.IPY_ID := l_ipyv_rec.ID;
-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
           Okl_Ins_Policies_Pub.update_ins_policies(
 	      p_api_version                  => p_api_version,
 	      p_init_msg_list                => OKC_API.G_FALSE,
 	      x_return_status                => l_return_status,
 	      x_msg_count                    => x_msg_count,
 	      x_msg_data                     => x_msg_data,
 	      p_ipyv_rec                     => l_inqv_rec,
 	      x_ipyv_rec                     => lx_inqv_rec
           	);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRINQB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies
           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
 	  	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
 	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
 	  	RAISE OKC_API.G_EXCEPTION_ERROR;
 	  END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
       EXCEPTION
         WHEN OKC_API.G_EXCEPTION_ERROR THEN
           x_return_status := OKC_API.HANDLE_EXCEPTIONS
           (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PROCESS'
           );
         WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
           x_return_status :=OKC_API.HANDLE_EXCEPTIONS
           (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PROCESS'
           );
         WHEN OTHERS THEN
           x_return_status :=OKC_API.HANDLE_EXCEPTIONS
           (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PROCESS'
           );
    END accept_optional_quote;
-----------------------------------------
   PROCEDURE accept_quote(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 ,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_quote_id                     IN NUMBER ) IS
  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'accept_quote';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_quote_type                   VARCHAR2(30);
  l_policy_number                VARCHAR2(20);
  l_khr_id                       NUMBER;
  l_missing_streams              VARCHAR2(500);
  l_st_gen_tmpt_set              VARCHAR2(100);
  l_pdt_id                       NUMBER;

-- The following two cursors written for user defined streams,  bug 3924300
   Cursor check_insurance_streams_csr(p_contract_id NUMBER) is
        select stream_type_purpose from okl_strm_type_b
        where stream_type_purpose like 'INSURANCE%'
        AND stream_type_purpose  NOT IN
        (select stl.primary_sty_purpose
        from OKL_STRM_TMPT_LINES_UV stl,
             okc_k_headers_b chr,
             okl_k_headers oklchr
        where stl.primary_sty_purpose like 'INSURANCE%'
        and  stl.primary_yn = 'Y'
        and  stl.pdt_id = oklchr.pdt_id
        and (STL.START_DATE <= chr.start_date)
        and (STL.END_DATE >= chr.start_date OR STL.END_DATE IS NULL)
        and chr.id = p_contract_id
        and chr.id = oklchr.id);

  Cursor get_contract_id(p_quote_id NUMBER) is
     Select khr_id --Bug:3825159
     from OKL_INS_POLICIES_B
     where id = p_quote_id;

 Cursor get_product_id(p_contract_id NUMBER) is
    Select pdt_id
    from okl_k_headers
    where id = p_contract_id;

 Cursor get_st_gen_template_set_name(p_pdt_id NUMBER) is
    Select st_gen_tmpt_set_name
    from  OKL_STRM_TMPT_LINES_UV
    where pdt_id = p_pdt_id
    and rownum<2;

  FUNCTION get_quote_type (
          p_quote_id IN  NUMBER,
          x_quote_type OUT NOCOPY VARCHAR2
        ) RETURN VARCHAR2 IS
          l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
          CURSOR inq_type_csr (quote_id  IN NUMBER) IS
	        SELECT IPY_TYPE
	        FROM OKL_INS_POLICIES_V
       WHERE OKL_INS_POLICIES_V.ID = quote_id;
        BEGIN
          OPEN  inq_type_csr(p_quote_id);
         FETCH inq_type_csr INTO x_quote_type ;
         IF (inq_type_csr%NOTFOUND) THEN
                 -- store SQL error message on message stack for caller
               OKC_API.set_message(G_APP_NAME,
               			   G_INVALID_QUOTE
                             );
                   CLOSE inq_type_csr;
                   l_return_status := OKC_API.G_RET_STS_ERROR;
                    RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
         CLOSE inq_type_csr ;
         RETURN(l_return_status);
         EXCEPTION
           WHEN OTHERS THEN
               -- store SQL error message on message stack for caller
               OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      		-- notify caller of an UNEXPECTED error
      		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      		-- verify that cursor was closed
		IF inq_type_csr%ISOPEN THEN
		   CLOSE inq_type_csr;
		END IF;
          	RETURN(l_return_status);
      END get_quote_type;
   BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                   G_PKG_NAME,
                                                  p_init_msg_list,
                                                  l_api_version,
                                                  p_api_version,
                                                  '_PROCESS',
                                                  x_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


        -- Check to see if all the insurance stream type purposes are associated with the if
        -- stream generation template used by the current contract
         -- Check implemented for Insurance user defined streams,  bug 3924300


           Open get_contract_id(p_quote_id);
           Fetch get_contract_id into l_khr_id;
           If get_contract_id%NOTFOUND then
               close get_contract_id;
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           End if;
           Close get_contract_id;

          Open get_product_id(l_khr_id);
          Fetch get_product_id into l_pdt_id;
          If get_product_id%NOTFOUND then
               close get_product_id;
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           End if;
          Close get_product_id;

          Open get_st_gen_template_set_name(l_pdt_id); --bug 4001494
          Fetch get_st_gen_template_set_name  into l_st_gen_tmpt_set;
          If get_st_gen_template_set_name%NOTFOUND then
               close get_st_gen_template_set_name;
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           End if;
          Close get_st_gen_template_set_name;

          for streams_rec in check_insurance_streams_csr(l_khr_id)  loop
            if streams_rec.stream_type_purpose is not null then
                 l_missing_streams := l_missing_streams||streams_rec.stream_type_purpose||', ';
            end if;
          end loop;
               if l_missing_streams is not null then
                    l_missing_streams := substr(l_missing_streams,1,length(l_missing_streams)-2);
                     -- message to display the missing streams in the stream generation template
                            OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_INS_STRM_PURPOSE_NOT_FOUND',
                            p_token1       => 'STRM_TEM_NAME',
                            p_token1_value => l_st_gen_tmpt_set,
                            p_token2       => 'PURPOSES',
                            p_token2_value => l_missing_streams);
                    RAISE OKC_API.G_EXCEPTION_ERROR;
               end if;


         -- End the check for insurance stream type purpose existence

        l_return_status := get_quote_type(p_quote_id, l_quote_type);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    	IF  ((l_quote_type IS NULL ) OR (l_quote_type = OKC_API.G_MISS_CHAR )) THEN

  		     OKC_API.set_message(G_APP_NAME,
	               	G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Quote Type' ); -- 3745151 Fix for invalid error message.
               RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;
        IF (l_quote_type = 'LEASE_POLICY' ) THEN

	           accept_lease_quote(p_api_version => l_api_version,
           		      p_init_msg_list => p_init_msg_list ,
           		      x_return_status => l_return_status  ,
	        	      x_msg_count => x_msg_count  ,
	        	      x_msg_data => x_msg_data ,
	        	      p_quote_id => p_quote_id,
     			      x_policy_number => l_policy_number
     			      );
			 	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	         	   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
				 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	          	 	   RAISE OKC_API.G_EXCEPTION_ERROR;
	        	 END IF;
         ELSIF (l_quote_type = 'OPTIONAL_POLICY' ) THEN
		accept_optional_quote(p_api_version => l_api_version,
           		      p_init_msg_list => p_init_msg_list ,
           		      x_return_status => l_return_status  ,
	        	      x_msg_count => x_msg_count  ,
	        	      x_msg_data => x_msg_data ,
	        	      p_quote_id => p_quote_id,
     			      x_policy_number => l_policy_number
     			      );
		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	          RAISE OKC_API.G_EXCEPTION_ERROR;
	    END IF;
        ELSE
			OKC_API.set_message(G_APP_NAME,
	               	G_INVALID_QUOTE_TYPE,G_COL_NAME_TOKEN,l_quote_type ); -- 3745151  Fix for invalid error message.
	END IF;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PROCESS'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PROCESS'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PROCESS'
        );
END accept_quote;
END Okl_Ins_Quote_Pvt;

/
