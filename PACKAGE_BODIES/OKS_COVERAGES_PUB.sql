--------------------------------------------------------
--  DDL for Package Body OKS_COVERAGES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_COVERAGES_PUB" AS
/* $Header: OKSPMCVB.pls 120.0 2005/05/25 18:12:24 appldev noship $*/
PROCEDURE CREATE_ACTUAL_COVERAGE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_ac_rec_in     	    IN  ac_rec_TYPE,
    p_restricted_update     IN VARCHAR2 DEFAULT 'F',
    x_Actual_coverage_id    OUT NOCOPY NUMBER) IS

    l_ac_rec_in    	        AC_REC_TYPE;
    l_api_name        CONSTANT VARCHAR2(30) := 'create_actual_coverage';
    l_return_status   VARCHAR2(1);
BEGIN
    l_ac_rec_in  := p_ac_rec_in;
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    -- Call to Complex API procedure
    oks_coverages_pvt.create_actual_coverage(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
            l_ac_rec_in,
            p_restricted_update,
            x_actual_coverage_Id);
            --dbms_output.put_line('in cov pvt'||l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     ELSIF l_return_status IS NULL
     THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;
   x_Return_status:=l_Return_Status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
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
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_actual_coverage;
PROCEDURE Undo_Header(
    p_api_version	    IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Header_id    	    IN NUMBER) IS
    l_api_name        CONSTANT VARCHAR2(30) := 'Undo_Header';
    l_return_status   VARCHAR2(1);

BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Call to Complex API procedure
    oks_coverages_pvt.Undo_Header(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
        P_Header_id);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

     END IF;
   x_Return_status:=l_Return_Status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
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
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END Undo_Header;
PROCEDURE Undo_Line(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Line_Id               IN NUMBER) Is
    l_api_name        CONSTANT VARCHAR2(30) := 'Undo_Line';
    l_return_status   VARCHAR2(1);
BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
/*
    -- Call to Complex API procedure
    oks_coverages_pvt.Undo_Line(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
        P_Line_id);
*/

--Added
	OKS_SETUP_UTIL_PUB.Delete_Contract_Line(
   											 	p_api_version     ,
    											p_init_msg_list   ,
    											p_line_id  ,
    											x_return_status,
    											x_msg_count    ,
    											x_msg_data     );





   l_Return_status:=x_Return_Status;
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
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

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END Undo_Line;


PROCEDURE Update_cov_eff(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_service_Line_Id       IN NUMBER,
    p_new_start_date        IN DATE,
    p_new_end_date          IN DATE)
IS

    l_api_name        CONSTANT VARCHAR2(30) := 'Update_cov_eff';
    l_return_status   VARCHAR2(1);
BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
--  dbms_output.put_line('Before calling update_cov Value of l_return_status='||l_return_status);
    -- Call to Complex API procedure
    oks_coverages_pvt.Update_coverage_effectivity(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
            P_service_Line_id,
            p_new_start_date,
            p_new_end_date);
-- dbms_output.put_line('After calling update_cov Value of l_return_status='||l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    X_Return_status:=l_Return_Status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

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

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END Update_cov_eff;


PROCEDURE INSTANTIATE_COVERAGE(
    p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_service_Line_Id       IN NUMBER,
    x_actual_coverage_id    OUT NOCOPY NUMBER) IS

l_api_version              CONSTANT    NUMBER         := 1.0;
l_init_msg_list            CONSTANT    VARCHAR2(1)    := 'T';
l_return_status            VARCHAR2(3);
l_return_msg               VARCHAR2(2000);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_msg_index_out            Number;
l_commit                   Varchar2(2000):='F';
l_ac_rec_type              oks_coverages_pub.ac_rec_type;
l_api_name                 CONSTANT VARCHAR2(30) := 'Instantiate_Coverage';

CURSOR  Cur_covtmpl_id(p_cle_id IN NUMBER) Is
SELECT  oxs.Coverage_template_Id,
        cle1.start_date,
        cle1.end_date
FROM    OKC_K_LINES_B cle1,
        OKC_K_ITEMS   cim ,
        OKX_SYSTEM_ITEMS_V oxs
WHERE   cle1.Lse_Id IN (1,19,14)
AND     cim.cle_Id=cle1.Id
AND     oxs.Id1=cim.object1_Id1
AND     oxs.Id2=cim.object1_id2
AND     cle1.Id = p_cle_id;

BEGIN

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_ac_rec_type.Svc_cle_Id := P_service_line_Id;

   -- getting coverage temp id

    FOR Cur_covtmpl_rec in Cur_covtmpl_id(P_service_line_Id) LOOP

     l_ac_rec_type.Tmp_cle_Id := Cur_covtmpl_rec.Coverage_template_Id;
     l_ac_rec_type.Start_date := Cur_covtmpl_rec.start_date;
     l_ac_rec_type.End_Date   := Cur_covtmpl_rec.end_date;

    END LOOP;

   OKS_COVERAGES_PUB.CREATE_ACTUAL_COVERAGE(
        p_api_version	        => l_api_version,
        p_init_msg_list         => l_init_msg_list,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        P_ac_rec_in    	        => l_ac_rec_type,
        p_restricted_update     => 'F',
        x_Actual_coverage_id    => x_Actual_coverage_id);

--dbms_output.put_line('Value of l_return_status='||l_return_status);

/*     IF l_msg_count > 0
      THEN
       FOR i in 1..l_msg_count
       LOOP
        fnd_msg_pub.get (p_msg_index     => -1,
                         p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                         p_data          => l_msg_data,
                         p_msg_index_out => l_msg_index_out);

--dbms_output.put_line('Value of l_msg_data='||l_msg_data);

       END LOOP;
     END IF;
*/
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

--dbms_output.put_line('Value of x_Actual_coverage_id='||TO_CHAR(x_Actual_coverage_id));

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

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


END INSTANTIATE_COVERAGE;


PROCEDURE DELETE_COVERAGE(
    p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_service_Line_Id       IN NUMBER) IS

l_api_version              CONSTANT    NUMBER         := 1.0;
l_init_msg_list            CONSTANT    VARCHAR2(1)    := 'T';
l_return_status            VARCHAR2(3);
l_return_msg               VARCHAR2(2000);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_msg_index_out            Number;
l_commit                   Varchar2(2000):='F';
l_api_name                 CONSTANT VARCHAR2(30) := 'Delete_Coverage';

CURSOR  Cur_cov_Id IS
SELECT  id
FROM    OKC_K_LINES_B
WHERE   CLE_ID = P_service_Line_Id
AND     LSE_ID in ( 2,15,20);

BEGIN

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

FOR Cov_Id_rec IN Cur_cov_Id LOOP
/*
OKS_COVERAGES_PUB.Undo_Line(
    p_api_version	        => l_api_version,
    p_init_msg_list         => l_init_msg_list,
    x_return_status         => l_return_status,
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data,
    P_Line_Id               => Cov_Id_rec.Id);

--dbms_output.put_line('status:'||l_return_status);
*/

/* Valiate Status added */



/*OKS_COVERAGES_PVT.Undo_Line(
    p_api_version	        => l_api_version,
    p_init_msg_list         => l_init_msg_list,
    x_return_status         => l_return_status,
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data,
    p_validate_status       => 'N',
    P_Line_Id               => Cov_Id_rec.Id);*/

--03/16/04 chkrishn modified to call api with no validate status
OKS_COVERAGES_PVT.Undo_Line(l_api_version, l_init_msg_list,l_return_status,l_msg_count,l_msg_data,Cov_Id_rec.Id);


/*
     IF l_msg_count > 0
      THEN
       FOR i in 1..l_msg_count
       LOOP
        fnd_msg_pub.get (p_msg_index     => -1,
                         p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                         p_data          => l_msg_data,
                         p_msg_index_out => l_msg_index_out);

--dbms_output.put_line('Value of l_msg_data='||l_msg_data);

       END LOOP;
     END IF;
*/
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;


END LOOP;

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
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


END DELETE_COVERAGE;


Procedure CHECK_COVERAGE_MATCH
   ( p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Source_contract_Line_Id       IN NUMBER,
    P_Target_contract_Line_Id       IN NUMBER,
    x_coverage_match         OUT NOCOPY VARCHAR2) IS

l_api_version              CONSTANT    NUMBER         := 1.0;
l_init_msg_list            CONSTANT    VARCHAR2(1)    := 'T';
l_return_status            VARCHAR2(3);
l_return_msg               VARCHAR2(2000);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_msg_index_out            Number;
l_commit                   Varchar2(2000):='F';
--l_api_name                 CONSTANT VARCHAR2(30) := 'Delete_Coverage';
l_api_name                 CONSTANT VARCHAR2(30) := 'Check_Coverage_Match';

BEGIN

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

   OKS_COVERAGES_PVT.CHECK_COVERAGE_MATCH
    (p_api_version	            => l_api_version,
    p_init_msg_list             => l_init_msg_list,
    x_return_status             => l_return_status,
    x_msg_count                 => l_msg_count,
    x_msg_data                  => l_msg_data,
    P_Source_contract_Line_Id   => P_Source_contract_Line_Id,
    P_Target_contract_Line_Id   => P_Target_contract_Line_Id,
    x_coverage_match            => x_coverage_match);
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
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END CHECK_COVERAGE_MATCH;

  PROCEDURE  CREATE_ADJUSTED_COVERAGE(
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    P_Source_contract_Line_Id       IN NUMBER,
    P_Target_contract_Line_Id       IN NUMBER,
    x_Actual_coverage_id            OUT NOCOPY NUMBER) IS

    l_ac_rec_in    	                AC_REC_TYPE;
    l_api_name                      CONSTANT VARCHAR2(30) := 'CREATE_ADJUSTED_COVERAGE';
    l_return_status                 VARCHAR2(1);

BEGIN

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Call to Complex API procedure

    oks_coverages_pvt.CREATE_ADJUSTED_COVERAGE(
	                   p_api_version,
	                   p_init_msg_list,
	                   l_return_status,
	                   x_msg_count,
	                   x_msg_data,
                       P_Source_contract_Line_Id ,
                       P_Target_contract_Line_Id,
                       x_actual_coverage_Id);


    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     ELSIF l_return_status IS NULL
     THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

   x_Return_status:=l_Return_Status;
   OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

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
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END CREATE_ADJUSTED_COVERAGE;


  PROCEDURE OKS_BILLRATE_MAPPING(
                                p_api_version           IN NUMBER ,
                                p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                p_business_process_id   IN NUMBER,
                                p_time_labor_tbl_in     IN OKS_COVERAGES_PVT.time_labor_tbl,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_msg_count             OUT NOCOPY NUMBER,
                                x_msg_data              OUT NOCOPY VARCHAR2) IS


 l_api_version   NUMBER := 1;
l_init_msg_list            VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
l_return_status            VARCHAR2(1);
l_return_msg               VARCHAR2(2000);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_api_name                 VARCHAR2(30):= 'OKS_BILLRATE_MAPPING';


   BEGIN

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
         raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

-- call the oks_billrate_mapping PVT API

OKS_COVERAGES_PVT.OKS_BILLRATE_MAPPING(
                                p_api_version,
                                p_init_msg_list,
                                p_business_process_id,
                                p_time_labor_tbl_in,
                                x_return_status,
                                x_msg_count,
                                x_msg_data);
    x_Return_status:=l_Return_Status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION

WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKC_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PUB');
    ROLLBACK ;
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKC_API.G_RET_STS_UNEXP_ERROR',
       x_msg_count,
       x_msg_data,
       '_PUB');
    ROLLBACK ;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK ;

   END OKS_BILLRATE_MAPPING ;



PROCEDURE Version_Coverage(
				p_api_version                  IN NUMBER,
				p_init_msg_list                IN VARCHAR2,
				x_return_status                OUT NOCOPY VARCHAR2,
                x_msg_count                    OUT NOCOPY NUMBER,
                x_msg_data                     OUT NOCOPY VARCHAR2,
                p_chr_id                          IN NUMBER,
                p_major_version                IN NUMBER) IS
 l_api_version   NUMBER := 1;
l_init_msg_list            VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
l_return_status            VARCHAR2(1);
l_return_msg               VARCHAR2(2000);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_api_name                 VARCHAR2(30):= 'version_Coverage';

BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;


OKS_COVERAGES_PVT.version_Coverage(
                                p_api_version,
                                p_init_msg_list,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                p_chr_id,
                                p_major_version);

    x_Return_status:=l_Return_Status;




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
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK ;


END Version_Coverage;


PROCEDURE Restore_Coverage(
				p_api_version                  IN NUMBER,
				p_init_msg_list                IN VARCHAR2,
				x_return_status                OUT NOCOPY VARCHAR2,
                x_msg_count                    OUT NOCOPY NUMBER,
                x_msg_data                     OUT NOCOPY VARCHAR2,
                p_chr_id                          IN NUMBER) IS

 l_api_version   NUMBER := 1;
l_init_msg_list            VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
l_return_status            VARCHAR2(1);
l_return_msg               VARCHAR2(2000);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_api_name                 VARCHAR2(30):= 'Restore_Coverage';
BEGIN

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

OKS_COVERAGES_PVT.Restore_Coverage(
                                p_api_version,
                                p_init_msg_list,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                p_chr_id);

    x_Return_status:=l_Return_Status;


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
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK ;
END Restore_Coverage;



PROCEDURE	Delete_History(
    			p_api_version                  IN NUMBER,
    			p_init_msg_list                IN VARCHAR2,
    			x_return_status                OUT NOCOPY VARCHAR2,
    			x_msg_count                    OUT NOCOPY NUMBER,
    			x_msg_data                     OUT NOCOPY VARCHAR2,
    			p_chr_id                       IN NUMBER) IS

 l_api_version   NUMBER := 1;
l_init_msg_list            VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
l_return_status            VARCHAR2(1);
l_return_msg               VARCHAR2(2000);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_api_name                 VARCHAR2(30):= 'Delete_History';
BEGIN

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

OKS_COVERAGES_PVT.DELETE_HISTORY (
                                p_api_version,
                                p_init_msg_list,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                p_chr_id);

    x_Return_status:=l_Return_Status;


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
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK ;
END DELETE_HISTORY;

PROCEDURE Delete_Saved_Version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER) IS

 l_api_version   NUMBER := 1;
l_init_msg_list            VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
l_return_status            VARCHAR2(1);
l_return_msg               VARCHAR2(2000);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_api_name                 VARCHAR2(30):= 'Delete_Saved_Version';
BEGIN

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

OKS_COVERAGES_PVT.Delete_Saved_Version (
                                p_api_version,
                                p_init_msg_list,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                p_chr_id);

    x_Return_status:=l_Return_Status;

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
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK ;
END;

END OKS_COVERAGES_PUB;

/
