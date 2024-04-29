--------------------------------------------------------
--  DDL for Package Body OKC_OUTCOME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OUTCOME_PUB" as
/* $Header: OKCPOCEB.pls 120.0 2005/05/25 23:11:11 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
--



  FUNCTION migrate_ocev(p_ocev_rec1 IN ocev_rec_type,
                        p_ocev_rec2 IN ocev_rec_type)
    RETURN ocev_rec_type IS
    l_ocev_rec ocev_rec_type;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'migrate_ocev';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    l_ocev_rec.id                    := p_ocev_rec1.id;
    l_ocev_rec.object_version_number := p_ocev_rec1.object_version_number;
    l_ocev_rec.pdf_id                := p_ocev_rec1.pdf_id;
    l_ocev_rec.cnh_id                := p_ocev_rec1.cnh_id;
    l_ocev_rec.dnz_chr_id            := p_ocev_rec1.dnz_chr_id;
    l_ocev_rec.success_resource_id       := p_ocev_rec1.success_resource_id;
    l_ocev_rec.failure_resource_id       := p_ocev_rec1.failure_resource_id;
    l_ocev_rec.created_by            := p_ocev_rec1.created_by;
    l_ocev_rec.creation_date         := p_ocev_rec1.creation_date;
    l_ocev_rec.last_updated_by       := p_ocev_rec1.last_updated_by;
    l_ocev_rec.last_update_date      := p_ocev_rec1.last_update_date;
    l_ocev_rec.last_update_login     := p_ocev_rec1.last_update_login;
    l_ocev_rec.sfwt_flag             := p_ocev_rec2.sfwt_flag;
    l_ocev_rec.seeded_flag           := p_ocev_rec2.seeded_flag;
    l_ocev_rec.application_id        := p_ocev_rec2.application_id;
    l_ocev_rec.comments              := p_ocev_rec2.comments;
    l_ocev_rec.enabled_yn            := p_ocev_rec2.enabled_yn;
    l_ocev_rec.attribute_category    := p_ocev_rec2.attribute_category;
    l_ocev_rec.attribute1            := p_ocev_rec2.attribute1;
    l_ocev_rec.attribute2            := p_ocev_rec2.attribute2;
    l_ocev_rec.attribute3            := p_ocev_rec2.attribute3;
    l_ocev_rec.attribute4            := p_ocev_rec2.attribute4;
    l_ocev_rec.attribute5            := p_ocev_rec2.attribute5;
    l_ocev_rec.attribute6            := p_ocev_rec2.attribute6;
    l_ocev_rec.attribute7            := p_ocev_rec2.attribute7;
    l_ocev_rec.attribute8            := p_ocev_rec2.attribute8;
    l_ocev_rec.attribute9            := p_ocev_rec2.attribute9;
    l_ocev_rec.attribute10           := p_ocev_rec2.attribute10;
    l_ocev_rec.attribute11           := p_ocev_rec2.attribute11;
    l_ocev_rec.attribute12           := p_ocev_rec2.attribute12;
    l_ocev_rec.attribute13           := p_ocev_rec2.attribute13;
    l_ocev_rec.attribute14           := p_ocev_rec2.attribute14;
    l_ocev_rec.attribute15           := p_ocev_rec2.attribute15;

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

    RETURN (l_ocev_rec);
  END migrate_ocev;

  FUNCTION migrate_oatv(p_oatv_rec1 IN oatv_rec_type,
                        p_oatv_rec2 IN oatv_rec_type)
    RETURN oatv_rec_type IS
    l_oatv_rec oatv_rec_type;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'migrate_oatv';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;


    l_oatv_rec.id                    := p_oatv_rec1.id;
    l_oatv_rec.pdp_id                := p_oatv_rec1.pdp_id;
    l_oatv_rec.oce_id                := p_oatv_rec1.oce_id;
    l_oatv_rec.aae_id                := p_oatv_rec1.aae_id;
    l_oatv_rec.dnz_chr_id            := p_oatv_rec1.dnz_chr_id;
    l_oatv_rec.object_version_number := p_oatv_rec1.object_version_number;
    l_oatv_rec.seeded_flag           := p_oatv_rec1.seeded_flag;
    l_oatv_rec.application_id        := p_oatv_rec1.application_id;
    l_oatv_rec.created_by            := p_oatv_rec1.created_by;
    l_oatv_rec.creation_date         := p_oatv_rec1.creation_date;
    l_oatv_rec.last_updated_by       := p_oatv_rec1.last_updated_by;
    l_oatv_rec.last_update_date      := p_oatv_rec1.last_update_date;
    l_oatv_rec.last_update_login     := p_oatv_rec1.last_update_login;
    l_oatv_rec.value                 := p_oatv_rec2.value;

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

    RETURN (l_oatv_rec);
  END migrate_oatv;

  PROCEDURE add_language IS
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'add_language';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    okc_outcome_pvt.add_language;

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

  END;

  --Object type procedure for insert
  PROCEDURE create_outcomes_args(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_rec		    IN ocev_rec_type,
    p_oatv_tbl              IN oatv_tbl_type,
    x_ocev_rec              OUT NOCOPY ocev_rec_type,
    x_oatv_tbl              OUT NOCOPY oatv_tbl_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'create_outcomes_args';
    l_return_status	    VARCHAR2(1);
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'create_outcomes_args';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					      p_init_msg_list,
					      '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call to Complex API procedure
    okc_outcome_pvt.create_outcomes_args(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ocev_rec,
	    p_oatv_tbl,
	    x_ocev_rec,
	    x_oatv_tbl);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OTHERS',
       x_msg_count,
       x_msg_data,
       '_PUB');
       IF (l_debug = 'Y') THEN
          okc_debug.Log('4000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END create_outcomes_args;

  --Object type procedure for update
  PROCEDURE update_outcomes_args(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_rec		    IN ocev_rec_type,
    p_oatv_tbl              IN oatv_tbl_type,
    x_ocev_rec              OUT NOCOPY ocev_rec_type,
    x_oatv_tbl              OUT NOCOPY oatv_tbl_type) IS

    l_api_version           CONSTANT NUMBER := 1;
    l_api_name              CONSTANT VARCHAR2(30) := 'update_outcomes_args';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'update_outcomes_args';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					      p_init_msg_list,
					      '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

   --Call to Complex API procedure
    okc_outcome_pvt.update_outcomes_args(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ocev_rec,
	    p_oatv_tbl,
	    x_ocev_rec,
	    x_oatv_tbl);
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OTHERS',
       x_msg_count,
       x_msg_data,
       '_PUB');
       IF (l_debug = 'Y') THEN
          okc_debug.Log('4000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END update_outcomes_args;

  --Object type procedure for validate
  PROCEDURE validate_outcomes_args(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ocev_rec		    IN ocev_rec_type,
    p_oatv_tbl              IN oatv_tbl_type) IS

    l_api_version           CONSTANT NUMBER := 1;
    l_api_name              CONSTANT VARCHAR2(30) := 'V_validate_process_def';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'validate_outcomes_args';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					      p_init_msg_list,
					      '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okc_outcome_pvt.validate_outcomes_args(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ocev_rec,
	    p_oatv_tbl);
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OTHERS',
       x_msg_count,
       x_msg_data,
       '_PUB');
       IF (l_debug = 'Y') THEN
          okc_debug.Log('4000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END validate_outcomes_args;

  --Procedures for Outcomes

  PROCEDURE create_outcome(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_ocev_rec		    IN ocev_rec_type,
    			    x_ocev_rec              OUT NOCOPY ocev_rec_type) IS

 	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_outcome';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_ocev_rec      ocev_rec_type := p_ocev_rec;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'create_outcome';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);

    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	-- USER HOOK CALL FOR BEFORE, STARTS
    	g_ocev_rec := l_ocev_rec;

    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'B');
    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--get values back from hook call
	 l_ocev_rec := migrate_ocev(l_ocev_rec, g_ocev_rec);

        -- Call to procedure of complex API
	okc_outcome_pvt.create_outcome(p_api_version   => p_api_version,
    				        p_init_msg_list => p_init_msg_list,
    				        x_return_status => x_return_status,
    				        x_msg_count     => x_msg_count,
    				   	x_msg_data      => x_msg_data,
    				   	p_ocev_rec      => l_ocev_rec,
    				   	x_ocev_rec      => x_ocev_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_ERROR;
     	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_ocev_rec := x_ocev_rec;

    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'A');

    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;
	--USER HOOK CALL FOR AFTER, ENDS

    	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);


 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
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
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('4000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END create_outcome;

  PROCEDURE create_outcome(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_ocev_tbl		    IN ocev_tbl_type,
    			    x_ocev_tbl              OUT NOCOPY ocev_tbl_type) IS

    	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'create_outcome';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_ocev_tbl.COUNT > 0 THEN
      i := p_ocev_tbl.FIRST;
      LOOP
        create_outcome(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ocev_tbl(i),
	    x_ocev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_ocev_tbl.LAST);
        i := p_ocev_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END create_outcome;

 PROCEDURE lock_outcome(p_api_version	    	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_ocev_rec		    IN ocev_rec_type) IS

    	 l_api_name	 CONSTANT VARCHAR2(30) := 'lock_outcome';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'lock_outcome';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);

    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

    	-- Call to procedure of complex API
	okc_outcome_pvt.lock_outcome(p_api_version   => p_api_version,
    				    p_init_msg_list => p_init_msg_list,
    				    x_return_status => x_return_status,
    				    x_msg_count     => x_msg_count,
    				    x_msg_data      => x_msg_data,
				    p_ocev_rec      => p_ocev_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

      	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);


 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
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
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('4000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  end lock_outcome;

  PROCEDURE lock_outcome(p_api_version	   IN NUMBER,
    			  p_init_msg_list  IN VARCHAR2 ,
    			  x_return_status  OUT NOCOPY VARCHAR2,
    			  x_msg_count      OUT NOCOPY NUMBER,
    			  x_msg_data       OUT NOCOPY VARCHAR2,
    			  p_ocev_tbl       IN ocev_tbl_type) IS

    	    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	    i				   NUMBER := 0;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'lock_outcome';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_ocev_tbl.COUNT > 0 THEN
      i := p_ocev_tbl.FIRST;
      LOOP
        lock_outcome(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ocev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_ocev_tbl.LAST);
        i := p_ocev_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END lock_outcome;

  PROCEDURE update_outcome(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_ocev_rec		    IN ocev_rec_type,
    			    x_ocev_rec              OUT NOCOPY ocev_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'update_outcome';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_ocev_rec      ocev_rec_type := p_ocev_rec;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'update_outcome';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);

    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	-- USER HOOK CALL FOR BEFORE, STARTS
	g_ocev_rec := l_ocev_rec;

    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'B');

    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--get values back from hook call
	l_ocev_rec := migrate_ocev(l_ocev_rec, g_ocev_rec);

    	-- Call to procedure of complex API
	okc_outcome_pvt.update_outcome(p_api_version   => p_api_version,
    				    p_init_msg_list => p_init_msg_list,
    				    x_return_status => x_return_status,
    				    x_msg_count     => x_msg_count,
    				    x_msg_data      => x_msg_data,
    				    p_ocev_rec      => l_ocev_rec,
    				    x_ocev_rec      => x_ocev_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

  	--USER HOOK CALL FOR AFTER, STARTS
	g_ocev_rec := x_ocev_rec;

    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'A');

    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;
	--USER HOOK CALL FOR AFTER, ENDS

    	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);


 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
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
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('4000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  end update_outcome;

  PROCEDURE update_outcome(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
     			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_ocev_tbl		    IN ocev_tbl_type,
    			    x_ocev_tbl              OUT NOCOPY ocev_tbl_type) IS

        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i			       NUMBER := 0;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'update_outcome';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_ocev_tbl.COUNT > 0 THEN
      i := p_ocev_tbl.FIRST;
      LOOP
        update_outcome(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ocev_tbl(i),
	    x_ocev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_ocev_tbl.LAST);
        i := p_ocev_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END update_outcome;

  PROCEDURE delete_outcome(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_ocev_rec		    IN ocev_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_outcome';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_ocev_rec      ocev_rec_type := p_ocev_rec;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'delete_outcome';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);

    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	-- USER HOOK CALL FOR BEFORE, STARTS
    	g_ocev_rec := l_ocev_rec;

    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'B');
    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--get values back from hook call
	l_ocev_rec := migrate_ocev(l_ocev_rec, g_ocev_rec);

    	-- Call to procedure of complex API
	okc_outcome_pvt.delete_outcome(p_api_version   => p_api_version,
    				    p_init_msg_list => p_init_msg_list,
    				    x_return_status => x_return_status,
    				    x_msg_count     => x_msg_count,
    				    x_msg_data      => x_msg_data,
    				    p_ocev_rec      => l_ocev_rec);
      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

      	--USER HOOK CALL FOR AFTER, STARTS
    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'A');

    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;
	--USER HOOK CALL FOR AFTER, ENDS

    	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);


 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
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
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('4000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  end delete_outcome;

  PROCEDURE delete_outcome(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_ocev_tbl		    IN ocev_tbl_type) IS

        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i			       NUMBER := 0;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'delete_outcome';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_ocev_tbl.COUNT > 0 THEN
      i := p_ocev_tbl.FIRST;
      LOOP
        delete_outcome(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ocev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_ocev_tbl.LAST);
        i := p_ocev_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END delete_outcome;

  PROCEDURE validate_outcome(p_api_version	      IN NUMBER,
    			      p_init_msg_list         IN VARCHAR2 ,
    			      x_return_status         OUT NOCOPY VARCHAR2,
    			      x_msg_count             OUT NOCOPY NUMBER,
    			      x_msg_data              OUT NOCOPY VARCHAR2,
    			      p_ocev_rec	      IN ocev_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'validate_outcome';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_ocev_rec      ocev_rec_type := p_ocev_rec;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'validate_outcome';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);

    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	-- USER HOOK CALL FOR BEFORE, STARTS
    	g_ocev_rec := l_ocev_rec;

    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'B');

    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--get values back from hook call
	l_ocev_rec := migrate_ocev(l_ocev_rec, g_ocev_rec);

    	-- Call to procedure of complex API
	okc_outcome_pvt.validate_outcome(p_api_version   => p_api_version,
    				      p_init_msg_list => p_init_msg_list,
    				      x_return_status => x_return_status,
    				      x_msg_count     => x_msg_count,
    				      x_msg_data      => x_msg_data,
    				      p_ocev_rec      => l_ocev_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS

    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'A');

    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;
	--USER HOOK CALL FOR AFTER, ENDS

    	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
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
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('4000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END validate_outcome;

  PROCEDURE validate_outcome(p_api_version	      IN NUMBER,
    			      p_init_msg_list         IN VARCHAR2 ,
    			      x_return_status         OUT NOCOPY VARCHAR2,
    			      x_msg_count             OUT NOCOPY NUMBER,
    			      x_msg_data              OUT NOCOPY VARCHAR2,
    			      p_ocev_tbl	      IN ocev_tbl_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i				   NUMBER := 0;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'validate_outcome';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_ocev_tbl.COUNT > 0 THEN
      i := p_ocev_tbl.FIRST;
      LOOP
        validate_outcome(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ocev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_ocev_tbl.LAST);
        i := p_ocev_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END validate_outcome;

  --Procedures for Outcome Arguments

  PROCEDURE create_out_arg(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_oatv_rec        IN  oatv_rec_type,
    				  x_oatv_rec        OUT NOCOPY oatv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_out_arg';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_oatv_rec      oatv_rec_type := p_oatv_rec;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'create_out_arg';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);

    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	-- USER HOOK CALL FOR BEFORE, STARTS
    	g_oatv_rec := l_oatv_rec;

    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'B');

    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--get values back from hook call
	l_oatv_rec := migrate_oatv(l_oatv_rec, g_oatv_rec);

    	-- Call to procedure of complex API
	okc_outcome_pvt.create_out_arg(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_oatv_rec      => l_oatv_rec,
    				    	  x_oatv_rec      => x_oatv_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_oatv_rec := x_oatv_rec;

    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'A');

    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;
	--USER HOOK CALL FOR AFTER, ENDS

    	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);


 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
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
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('4000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  end create_out_arg;

  PROCEDURE create_out_arg(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_oatv_tbl	    IN  oatv_tbl_type,
    				  x_oatv_tbl        OUT NOCOPY oatv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'create_out_arg';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_oatv_tbl.COUNT > 0 THEN
      i := p_oatv_tbl.FIRST;
      LOOP
        create_out_arg(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_oatv_tbl(i),
	    x_oatv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_oatv_tbl.LAST);
        i := p_oatv_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END create_out_arg;

  PROCEDURE lock_out_arg(p_api_version	    IN  NUMBER,
    				p_init_msg_list     IN  VARCHAR2 ,
    				x_return_status     OUT NOCOPY VARCHAR2,
    				x_msg_count         OUT NOCOPY NUMBER,
    				x_msg_data          OUT NOCOPY VARCHAR2,
    				p_oatv_rec	    IN  oatv_rec_type) IS
  	 l_api_name	 CONSTANT VARCHAR2(30) := 'lock_out_arg';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_oatv_rec      oatv_rec_type := p_oatv_rec;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'lock_out_arg';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);

    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

    	-- Call to procedure of complex API
	okc_outcome_pvt.lock_out_arg(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_oatv_rec      => l_oatv_rec);

	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

    	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);


 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
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
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('4000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  end lock_out_arg;

  PROCEDURE lock_out_arg(p_api_version	    IN  NUMBER,
    				p_init_msg_list     IN  VARCHAR2 ,
    				x_return_status     OUT NOCOPY VARCHAR2,
    				x_msg_count         OUT NOCOPY NUMBER,
    				x_msg_data          OUT NOCOPY VARCHAR2,
    				p_oatv_tbl	    IN  oatv_tbl_type) IS
        l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i			NUMBER := 0;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'lock_out_arg';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_oatv_tbl.COUNT > 0 THEN
      i := p_oatv_tbl.FIRST;
      LOOP
        lock_out_arg(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_oatv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_oatv_tbl.LAST);
        i := p_oatv_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  End lock_out_arg;

  PROCEDURE update_out_arg(p_api_version	    IN NUMBER,
    				  p_init_msg_list   IN VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_oatv_rec        IN oatv_rec_type,
    				  x_oatv_rec        OUT NOCOPY oatv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'update_out_arg';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_oatv_rec      oatv_rec_type := p_oatv_rec;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'update_out_arg';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);
    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	-- USER HOOK CALL FOR BEFORE, STARTS
    	g_oatv_rec := l_oatv_rec;

    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
				p_before_after   => 'B');
    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--get values back from hook call
	l_oatv_rec := migrate_oatv(l_oatv_rec, g_oatv_rec);

    	-- Call to procedure of complex API
	okc_outcome_pvt.update_out_arg(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_oatv_rec      => l_oatv_rec,
    				    	  x_oatv_rec      => x_oatv_rec);

	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_oatv_rec := x_oatv_rec;

    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'A');
    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;
	--USER HOOK CALL FOR AFTER, ENDS

    	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);


 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
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
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('4000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END update_out_arg;

  PROCEDURE update_out_arg(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_oatv_tbl	    IN  oatv_tbl_type,
    				  x_oatv_tbl        OUT NOCOPY oatv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'update_out_arg';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_oatv_tbl.COUNT > 0 THEN
      i := p_oatv_tbl.FIRST;
      LOOP
        update_out_arg(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_oatv_tbl(i),
	    x_oatv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_oatv_tbl.LAST);
        i := p_oatv_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END update_out_arg;

  PROCEDURE delete_out_arg(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_oatv_rec	    IN  oatv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_out_arg';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_oatv_rec      oatv_rec_type := p_oatv_rec;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'delete_out_arg';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);

    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	-- USER HOOK CALL FOR BEFORE, STARTS
    	g_oatv_rec := l_oatv_rec;

    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'B');
    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--get values back from hook call
	l_oatv_rec := migrate_oatv(l_oatv_rec, g_oatv_rec);

    	-- Call to procedure of complex API
	okc_outcome_pvt.delete_out_arg(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_oatv_rec      => l_oatv_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

        --USER HOOK CALL FOR AFTER, STARTS
    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'A');

    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;
	--USER HOOK CALL FOR AFTER, ENDS

    	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
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
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('4000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END delete_out_arg;

  PROCEDURE delete_out_arg(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
     				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_oatv_tbl	    IN  oatv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'delete_out_arg';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_oatv_tbl.COUNT > 0 THEN
       i := p_oatv_tbl.FIRST;
      LOOP
        delete_out_arg(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_oatv_tbl(i));
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;
        EXIT WHEN (i = p_oatv_tbl.LAST);
        i := p_oatv_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END delete_out_arg;

  PROCEDURE validate_out_arg(p_api_version	IN  NUMBER,
    				    p_init_msg_list     IN  VARCHAR2 ,
    				    x_return_status     OUT NOCOPY VARCHAR2,
    				    x_msg_count         OUT NOCOPY NUMBER,
    				    x_msg_data          OUT NOCOPY VARCHAR2,
   				    p_oatv_rec		IN  oatv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'validate_out_arg';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_oatv_rec      oatv_rec_type := p_oatv_rec;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'validate_out_arg';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);

    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	-- USER HOOK CALL FOR BEFORE, STARTS
    	g_oatv_rec := l_oatv_rec;

    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'B');
    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--get values back from hook call
	l_oatv_rec := migrate_oatv(l_oatv_rec, g_oatv_rec);

    	-- Call to procedure of complex API
	okc_outcome_pvt.validate_out_arg(p_api_version   => p_api_version,
    			   		    p_init_msg_list => p_init_msg_list,
    				    	    x_return_status => x_return_status,
    				    	    x_msg_count     => x_msg_count,
    				    	    x_msg_data      => x_msg_data,
    				    	    p_oatv_rec      => l_oatv_rec);

	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
    	okc_util.call_user_hook(x_return_status  => x_return_status,
     				p_package_name   => g_pkg_name,
     				p_procedure_name => l_api_name,
     				p_before_after   => 'A');
    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;
	--USER HOOK CALL FOR AFTER, ENDS

    	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);


 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
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
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
       IF (l_debug = 'Y') THEN
          okc_debug.Log('4000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END validate_out_arg;

  PROCEDURE validate_out_arg(p_api_version	IN NUMBER,
    				    p_init_msg_list     IN VARCHAR2 ,
    				    x_return_status     OUT NOCOPY VARCHAR2,
    				    x_msg_count         OUT NOCOPY NUMBER,
    				    x_msg_data          OUT NOCOPY VARCHAR2,
    				    p_oatv_tbl		IN oatv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
   --
   l_proc varchar2(72) := '  okc_outcome_pub.'||'validate_out_arg';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_oatv_tbl.COUNT > 0 THEN
      i := p_oatv_tbl.FIRST;
      LOOP
        validate_out_arg(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_oatv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_oatv_tbl.LAST);
        i := p_oatv_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.Log('1000: Leaving ',2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('3000: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;
  END validate_out_arg;

END okc_outcome_pub;

/
