--------------------------------------------------------
--  DDL for Package Body OKC_PROCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PROCESS_PUB" as
/* $Header: OKCPPDFB.pls 120.0 2005/05/25 19:22:46 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  FUNCTION migrate_pdfv(p_pdfv_rec1 IN pdfv_rec_type,
                        p_pdfv_rec2 IN pdfv_rec_type)
    RETURN pdfv_rec_type IS
    l_pdfv_rec pdfv_rec_type;
  BEGIN
    l_pdfv_rec.id                    := p_pdfv_rec1.id;
    l_pdfv_rec.object_version_number := p_pdfv_rec1.object_version_number;
    l_pdfv_rec.created_by            := p_pdfv_rec1.created_by;
    l_pdfv_rec.creation_date         := p_pdfv_rec1.creation_date;
    l_pdfv_rec.last_updated_by       := p_pdfv_rec1.last_updated_by;
    l_pdfv_rec.last_update_date      := p_pdfv_rec1.last_update_date;
    l_pdfv_rec.last_update_login     := p_pdfv_rec1.last_update_login;
    l_pdfv_rec.sfwt_flag             := p_pdfv_rec2.sfwt_flag;
    l_pdfv_rec.description           := p_pdfv_rec2.description;
    l_pdfv_rec.short_description     := p_pdfv_rec2.short_description;
    l_pdfv_rec.comments              := p_pdfv_rec2.comments;
    l_pdfv_rec.usage                 := p_pdfv_rec2.usage;
    l_pdfv_rec.name                  := p_pdfv_rec2.name;
    l_pdfv_rec.wf_name               := p_pdfv_rec2.wf_name;
    l_pdfv_rec.wf_process_name       := p_pdfv_rec2.wf_process_name;
    l_pdfv_rec.procedure_name        := p_pdfv_rec2.procedure_name;
    l_pdfv_rec.package_name          := p_pdfv_rec2.package_name;
    l_pdfv_rec.pdf_type              := p_pdfv_rec2.pdf_type;
    l_pdfv_rec.application_id        := p_pdfv_rec2.application_id;
    l_pdfv_rec.seeded_flag           := p_pdfv_rec2.seeded_flag;
    l_pdfv_rec.attribute_category    := p_pdfv_rec2.attribute_category;
    l_pdfv_rec.attribute1            := p_pdfv_rec2.attribute1;
    l_pdfv_rec.attribute2            := p_pdfv_rec2.attribute2;
    l_pdfv_rec.attribute3            := p_pdfv_rec2.attribute3;
    l_pdfv_rec.attribute4            := p_pdfv_rec2.attribute4;
    l_pdfv_rec.attribute5            := p_pdfv_rec2.attribute5;
    l_pdfv_rec.attribute6            := p_pdfv_rec2.attribute6;
    l_pdfv_rec.attribute7            := p_pdfv_rec2.attribute7;
    l_pdfv_rec.attribute8            := p_pdfv_rec2.attribute8;
    l_pdfv_rec.attribute9            := p_pdfv_rec2.attribute9;
    l_pdfv_rec.attribute10           := p_pdfv_rec2.attribute10;
    l_pdfv_rec.attribute11           := p_pdfv_rec2.attribute11;
    l_pdfv_rec.attribute12           := p_pdfv_rec2.attribute12;
    l_pdfv_rec.attribute13           := p_pdfv_rec2.attribute13;
    l_pdfv_rec.attribute14           := p_pdfv_rec2.attribute14;
    l_pdfv_rec.attribute15           := p_pdfv_rec2.attribute15;
    l_pdfv_rec.begin_date            := p_pdfv_rec2.begin_date;
    l_pdfv_rec.end_date              := p_pdfv_rec2.end_date;
    l_pdfv_rec.message_name          := p_pdfv_rec2.message_name;
    l_pdfv_rec.script_name           := p_pdfv_rec2.script_name;
    RETURN (l_pdfv_rec);
  END migrate_pdfv;

  FUNCTION migrate_pdpv(p_pdpv_rec1 IN pdpv_rec_type,
                        p_pdpv_rec2 IN pdpv_rec_type)
    RETURN pdpv_rec_type IS
    l_pdpv_rec pdpv_rec_type;
  BEGIN
    l_pdpv_rec.id                    := p_pdpv_rec1.id;
    l_pdpv_rec.pdf_id                := p_pdpv_rec1.pdf_id;
    l_pdpv_rec.object_version_number := p_pdpv_rec1.object_version_number;
    l_pdpv_rec.created_by            := p_pdpv_rec1.created_by;
    l_pdpv_rec.creation_date         := p_pdpv_rec1.creation_date;
    l_pdpv_rec.last_updated_by       := p_pdpv_rec1.last_updated_by;
    l_pdpv_rec.last_update_date      := p_pdpv_rec1.last_update_date;
    l_pdpv_rec.last_update_login     := p_pdpv_rec1.last_update_login;
    l_pdpv_rec.sfwt_flag             := p_pdpv_rec2.sfwt_flag;
    l_pdpv_rec.name                  := p_pdpv_rec2.name;
    l_pdpv_rec.user_name             := p_pdpv_rec2.user_name;
    l_pdpv_rec.data_type             := p_pdpv_rec2.data_type;
    l_pdpv_rec.default_value         := p_pdpv_rec2.default_value;
    l_pdpv_rec.required_yn           := p_pdpv_rec2.required_yn;
    l_pdpv_rec.description           := p_pdpv_rec2.description;
    l_pdpv_rec.application_id        := p_pdpv_rec2.application_id;
    l_pdpv_rec.seeded_flag           := p_pdpv_rec2.seeded_flag;
    l_pdpv_rec.jtot_object_code      := p_pdpv_rec2.jtot_object_code;
    l_pdpv_rec.NAME_COLUMN           := p_pdpv_rec2.NAME_COLUMN;
    l_pdpv_rec.description_column    := p_pdpv_rec2.description_column;
    RETURN (l_pdpv_rec);
  END migrate_pdpv;

  PROCEDURE add_language IS
  BEGIN
    okc_process_pvt.add_language;
  END;

  --Object type procedure for insert
  PROCEDURE create_process_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_rec		    IN pdfv_rec_type,
    p_pdpv_tbl              IN pdpv_tbl_type,
    x_pdfv_rec              OUT NOCOPY pdfv_rec_type,
    x_pdpv_tbl              OUT NOCOPY pdpv_tbl_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'create_process_def';
    l_return_status	    VARCHAR2(1);
  BEGIN
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
    okc_process_pvt.create_process_def(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pdfv_rec,
	    p_pdpv_tbl,
	    x_pdfv_rec,
	    x_pdpv_tbl);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
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
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OTHERS',
       x_msg_count,
       x_msg_data,
       '_PUB');
  END create_process_def;

  --Object type procedure for update
  PROCEDURE update_process_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_rec		    IN pdfv_rec_type,
    p_pdpv_tbl              IN pdpv_tbl_type,
    x_pdfv_rec              OUT NOCOPY pdfv_rec_type,
    x_pdpv_tbl              OUT NOCOPY pdpv_tbl_type) IS

    l_api_version           CONSTANT NUMBER := 1;
    l_api_name              CONSTANT VARCHAR2(30) := 'V_update_process_def';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
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
    okc_process_pvt.update_process_def(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pdfv_rec,
	    p_pdpv_tbl,
	    x_pdfv_rec,
	    x_pdpv_tbl);
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
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
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OTHERS',
       x_msg_count,
       x_msg_data,
       '_PUB');
  END update_process_def;

  --Object type procedure for validate
  PROCEDURE validate_process_def(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pdfv_rec		    IN pdfv_rec_type,
    p_pdpv_tbl              IN pdpv_tbl_type) IS

    l_api_version           CONSTANT NUMBER := 1;
    l_api_name              CONSTANT VARCHAR2(30) := 'V_validate_process_def';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					      p_init_msg_list,
					      '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okc_process_pvt.validate_process_def(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pdfv_rec,
	    p_pdpv_tbl);
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
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
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OTHERS',
       x_msg_count,
       x_msg_data,
       '_PUB');
  END validate_process_def;

  --Procedures for Process Definitions

  PROCEDURE create_proc_def(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_pdfv_rec		    IN pdfv_rec_type,
    			    x_pdfv_rec              OUT NOCOPY pdfv_rec_type) IS

 	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_proc_def';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_pdfv_rec      pdfv_rec_type := p_pdfv_rec;
  BEGIN
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
    	g_pdfv_rec := l_pdfv_rec;

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
	 l_pdfv_rec := migrate_pdfv(l_pdfv_rec, g_pdfv_rec);

        -- Call to procedure of complex API
	okc_process_pvt.create_proc_def(p_api_version   => p_api_version,
    				        p_init_msg_list => p_init_msg_list,
    				        x_return_status => x_return_status,
    				        x_msg_count     => x_msg_count,
    				   	x_msg_data      => x_msg_data,
    				   	p_pdfv_rec      => l_pdfv_rec,
    				   	x_pdfv_rec      => x_pdfv_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_ERROR;
     	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_pdfv_rec := x_pdfv_rec;

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
  END create_proc_def;

  PROCEDURE create_proc_def(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_pdfv_tbl		    IN pdfv_tbl_type,
    			    x_pdfv_tbl              OUT NOCOPY pdfv_tbl_type) IS

    	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_pdfv_tbl.COUNT > 0 THEN
      i := p_pdfv_tbl.FIRST;
      LOOP
        create_proc_def(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pdfv_tbl(i),
	    x_pdfv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pdfv_tbl.LAST);
        i := p_pdfv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
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
  END create_proc_def;

 PROCEDURE lock_proc_def(p_api_version	    	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_pdfv_rec		    IN pdfv_rec_type) IS

    	 l_api_name	 CONSTANT VARCHAR2(30) := 'lock_proc_def';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
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
	okc_process_pvt.lock_proc_def(p_api_version   => p_api_version,
    				    p_init_msg_list => p_init_msg_list,
    				    x_return_status => x_return_status,
    				    x_msg_count     => x_msg_count,
    				    x_msg_data      => x_msg_data,
				    p_pdfv_rec      => p_pdfv_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
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
        '_PUB'
      );

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
  end lock_proc_def;

  PROCEDURE lock_proc_def(p_api_version	   IN NUMBER,
    			  p_init_msg_list  IN VARCHAR2 ,
    			  x_return_status  OUT NOCOPY VARCHAR2,
    			  x_msg_count      OUT NOCOPY NUMBER,
    			  x_msg_data       OUT NOCOPY VARCHAR2,
    			  p_pdfv_tbl       IN pdfv_tbl_type) IS

    	    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	    i				   NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_pdfv_tbl.COUNT > 0 THEN
      i := p_pdfv_tbl.FIRST;
      LOOP
        lock_proc_def(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pdfv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pdfv_tbl.LAST);
        i := p_pdfv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
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
  END lock_proc_def;

  PROCEDURE update_proc_def(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_pdfv_rec		    IN pdfv_rec_type,
    			    x_pdfv_rec              OUT NOCOPY pdfv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'update_proc_def';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_pdfv_rec      pdfv_rec_type := p_pdfv_rec;
  BEGIN
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
	g_pdfv_rec := l_pdfv_rec;

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
	l_pdfv_rec := migrate_pdfv(l_pdfv_rec, g_pdfv_rec);

    	-- Call to procedure of complex API
	okc_process_pvt.update_proc_def(p_api_version   => p_api_version,
    				    p_init_msg_list => p_init_msg_list,
    				    x_return_status => x_return_status,
    				    x_msg_count     => x_msg_count,
    				    x_msg_data      => x_msg_data,
    				    p_pdfv_rec      => l_pdfv_rec,
    				    x_pdfv_rec      => x_pdfv_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

  	--USER HOOK CALL FOR AFTER, STARTS
	g_pdfv_rec := x_pdfv_rec;

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

  end update_proc_def;

  PROCEDURE update_proc_def(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
     			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_pdfv_tbl		    IN pdfv_tbl_type,
    			    x_pdfv_tbl              OUT NOCOPY pdfv_tbl_type) IS

        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i			       NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_pdfv_tbl.COUNT > 0 THEN
      i := p_pdfv_tbl.FIRST;
      LOOP
        update_proc_def(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pdfv_tbl(i),
	    x_pdfv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pdfv_tbl.LAST);
        i := p_pdfv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
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
  END update_proc_def;

  PROCEDURE delete_proc_def(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_pdfv_rec		    IN pdfv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_proc_def';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_pdfv_rec      pdfv_rec_type := p_pdfv_rec;
  BEGIN
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
    	g_pdfv_rec := l_pdfv_rec;

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
	l_pdfv_rec := migrate_pdfv(l_pdfv_rec, g_pdfv_rec);

    	-- Call to procedure of complex API
	okc_process_pvt.delete_proc_def(p_api_version   => p_api_version,
    				    p_init_msg_list => p_init_msg_list,
    				    x_return_status => x_return_status,
    				    x_msg_count     => x_msg_count,
    				    x_msg_data      => x_msg_data,
    				    p_pdfv_rec      => l_pdfv_rec);
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
  end delete_proc_def;

  PROCEDURE delete_proc_def(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_pdfv_tbl		    IN pdfv_tbl_type) IS

        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i			       NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_pdfv_tbl.COUNT > 0 THEN
      i := p_pdfv_tbl.FIRST;
      LOOP
        delete_proc_def(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pdfv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pdfv_tbl.LAST);
        i := p_pdfv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
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
  END delete_proc_def;

  PROCEDURE validate_proc_def(p_api_version	      IN NUMBER,
    			      p_init_msg_list         IN VARCHAR2 ,
    			      x_return_status         OUT NOCOPY VARCHAR2,
    			      x_msg_count             OUT NOCOPY NUMBER,
    			      x_msg_data              OUT NOCOPY VARCHAR2,
    			      p_pdfv_rec	      IN pdfv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'validate_proc_def';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_pdfv_rec      pdfv_rec_type := p_pdfv_rec;
  BEGIN
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
    	g_pdfv_rec := l_pdfv_rec;

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
	l_pdfv_rec := migrate_pdfv(l_pdfv_rec, g_pdfv_rec);

    	-- Call to procedure of complex API
	okc_process_pvt.validate_proc_def(p_api_version   => p_api_version,
    				      p_init_msg_list => p_init_msg_list,
    				      x_return_status => x_return_status,
    				      x_msg_count     => x_msg_count,
    				      x_msg_data      => x_msg_data,
    				      p_pdfv_rec      => l_pdfv_rec);
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
  END validate_proc_def;

  PROCEDURE validate_proc_def(p_api_version	      IN NUMBER,
    			      p_init_msg_list         IN VARCHAR2 ,
    			      x_return_status         OUT NOCOPY VARCHAR2,
    			      x_msg_count             OUT NOCOPY NUMBER,
    			      x_msg_data              OUT NOCOPY VARCHAR2,
    			      p_pdfv_tbl	      IN pdfv_tbl_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i				   NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_pdfv_tbl.COUNT > 0 THEN
      i := p_pdfv_tbl.FIRST;
      LOOP
        validate_proc_def(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pdfv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pdfv_tbl.LAST);
        i := p_pdfv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
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
  END validate_proc_def;

  --Procedures for Process Definition Parameters

  PROCEDURE create_proc_def_parms(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_pdpv_rec        IN  pdpv_rec_type,
    				  x_pdpv_rec        OUT NOCOPY pdpv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_proc_def_parms';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_pdpv_rec      pdpv_rec_type := p_pdpv_rec;
  BEGIN
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
    	g_pdpv_rec := l_pdpv_rec;

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
	l_pdpv_rec := migrate_pdpv(l_pdpv_rec, g_pdpv_rec);

    	-- Call to procedure of complex API
	okc_process_pvt.create_proc_def_parms(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_pdpv_rec      => l_pdpv_rec,
    				    	  x_pdpv_rec      => x_pdpv_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_pdpv_rec := x_pdpv_rec;

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
  end create_proc_def_parms;

  PROCEDURE create_proc_def_parms(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_pdpv_tbl	    IN  pdpv_tbl_type,
    				  x_pdpv_tbl        OUT NOCOPY pdpv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_pdpv_tbl.COUNT > 0 THEN
      i := p_pdpv_tbl.FIRST;
      LOOP
        create_proc_def_parms(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pdpv_tbl(i),
	    x_pdpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pdpv_tbl.LAST);
        i := p_pdpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
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
  END create_proc_def_parms;

  PROCEDURE lock_proc_def_parms(p_api_version	    IN  NUMBER,
    				p_init_msg_list     IN  VARCHAR2 ,
    				x_return_status     OUT NOCOPY VARCHAR2,
    				x_msg_count         OUT NOCOPY NUMBER,
    				x_msg_data          OUT NOCOPY VARCHAR2,
    				p_pdpv_rec	    IN  pdpv_rec_type) IS
  	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_proc_def_parms';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_pdpv_rec      pdpv_rec_type := p_pdpv_rec;
  BEGIN
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
	okc_process_pvt.lock_proc_def_parms(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_pdpv_rec      => l_pdpv_rec);

	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
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
        '_PUB'
      );

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
  end lock_proc_def_parms;

  PROCEDURE lock_proc_def_parms(p_api_version	    IN  NUMBER,
    				p_init_msg_list     IN  VARCHAR2 ,
    				x_return_status     OUT NOCOPY VARCHAR2,
    				x_msg_count         OUT NOCOPY NUMBER,
    				x_msg_data          OUT NOCOPY VARCHAR2,
    				p_pdpv_tbl	    IN  pdpv_tbl_type) IS
        l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i			NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_pdpv_tbl.COUNT > 0 THEN
      i := p_pdpv_tbl.FIRST;
      LOOP
        lock_proc_def_parms(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pdpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pdpv_tbl.LAST);
        i := p_pdpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
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
  End lock_proc_def_parms;

  PROCEDURE update_proc_def_parms(p_api_version	    IN NUMBER,
    				  p_init_msg_list   IN VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_pdpv_rec        IN pdpv_rec_type,
    				  x_pdpv_rec        OUT NOCOPY pdpv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'update_proc_def_parms';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_pdpv_rec      pdpv_rec_type := p_pdpv_rec;
  BEGIN
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
    	g_pdpv_rec := l_pdpv_rec;

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
	l_pdpv_rec := migrate_pdpv(l_pdpv_rec, g_pdpv_rec);

    	-- Call to procedure of complex API
	okc_process_pvt.update_proc_def_parms(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_pdpv_rec      => l_pdpv_rec,
    				    	  x_pdpv_rec      => x_pdpv_rec);

	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_pdpv_rec := x_pdpv_rec;

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
  END update_proc_def_parms;

  PROCEDURE update_proc_def_parms(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_pdpv_tbl	    IN  pdpv_tbl_type,
    				  x_pdpv_tbl        OUT NOCOPY pdpv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_pdpv_tbl.COUNT > 0 THEN
      i := p_pdpv_tbl.FIRST;
      LOOP
        update_proc_def_parms(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pdpv_tbl(i),
	    x_pdpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pdpv_tbl.LAST);
        i := p_pdpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
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
  END update_proc_def_parms;

  PROCEDURE delete_proc_def_parms(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_pdpv_rec	    IN  pdpv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_proc_def_parms';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_pdpv_rec      pdpv_rec_type := p_pdpv_rec;
  BEGIN
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
    	g_pdpv_rec := l_pdpv_rec;

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
	l_pdpv_rec := migrate_pdpv(l_pdpv_rec, g_pdpv_rec);

    	-- Call to procedure of complex API
	okc_process_pvt.delete_proc_def_parms(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_pdpv_rec      => l_pdpv_rec);
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
  END delete_proc_def_parms;

  PROCEDURE delete_proc_def_parms(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
     				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_pdpv_tbl	    IN  pdpv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_pdpv_tbl.COUNT > 0 THEN
       i := p_pdpv_tbl.FIRST;
      LOOP
        delete_proc_def_parms(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pdpv_tbl(i));
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;
        EXIT WHEN (i = p_pdpv_tbl.LAST);
        i := p_pdpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
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
  END delete_proc_def_parms;

  PROCEDURE validate_proc_def_parms(p_api_version	IN  NUMBER,
    				    p_init_msg_list     IN  VARCHAR2 ,
    				    x_return_status     OUT NOCOPY VARCHAR2,
    				    x_msg_count         OUT NOCOPY NUMBER,
    				    x_msg_data          OUT NOCOPY VARCHAR2,
   				    p_pdpv_rec		IN  pdpv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'validate_proc_def_parms';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_pdpv_rec      pdpv_rec_type := p_pdpv_rec;
  BEGIN
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
    	g_pdpv_rec := l_pdpv_rec;

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
	l_pdpv_rec := migrate_pdpv(l_pdpv_rec, g_pdpv_rec);

    	-- Call to procedure of complex API
	okc_process_pvt.validate_proc_def_parms(p_api_version   => p_api_version,
    			   		    p_init_msg_list => p_init_msg_list,
    				    	    x_return_status => x_return_status,
    				    	    x_msg_count     => x_msg_count,
    				    	    x_msg_data      => x_msg_data,
    				    	    p_pdpv_rec      => l_pdpv_rec);

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
  END validate_proc_def_parms;

  PROCEDURE validate_proc_def_parms(p_api_version	IN NUMBER,
    				    p_init_msg_list     IN VARCHAR2 ,
    				    x_return_status     OUT NOCOPY VARCHAR2,
    				    x_msg_count         OUT NOCOPY NUMBER,
    				    x_msg_data          OUT NOCOPY VARCHAR2,
    				    p_pdpv_tbl		IN pdpv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_pdpv_tbl.COUNT > 0 THEN
      i := p_pdpv_tbl.FIRST;
      LOOP
        validate_proc_def_parms(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_pdpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pdpv_tbl.LAST);
        i := p_pdpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
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
  END validate_proc_def_parms;

/* -----------------------------------------------------------------------------------------
   PROCEDURE:  validate_dbnames
   INPUT:      runtime wf or package names passed form OKCEXPRO.fmb
   PROCESSING: call the complex API OKC_PROCESS_PVT.validate_dbnames to validate that the
			workflow name/process or the package/procedure name exist
   OUTPUT:     error messages APP_EXCEPTION

   -----------------------------------------------------------------------------------------
*/

 PROCEDURE validate_dbnames(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_wf_proc                      IN  VARCHAR2,
    p_wf_name                      IN  VARCHAR2,
    p_package                      IN  VARCHAR2,
    p_procedure                    IN  VARCHAR2) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'Validate_dbnames';
    l_return_status	        VARCHAR2(1);
    l_pdfv_rec              pdfv_rec_type;

BEGIN
--  copy the input parms to the record structure passed to the complex API
--
    l_pdfv_rec.wf_process_name  := p_wf_proc;
    l_pdfv_rec.wf_name          := p_wf_name;
    l_pdfv_rec.package_name     := p_package;
    l_pdfv_rec.procedure_name   := p_procedure;

-- Call to Complex API procedure
--
    okc_process_pvt.validate_dbnames(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    l_pdfv_rec);

EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
                                 (l_api_name,
                                  G_PKG_NAME,
                                  'OKC_API.G_RET_STS_ERROR',
                                  x_msg_count,
                                  x_msg_data,
                                  '_PUB');
        APP_EXCEPTION.raise_exception;

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
                                (l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PUB');
		  APP_EXCEPTION.raise_exception;

    WHEN OTHERS THEN
		  APP_EXCEPTION.raise_exception;

END validate_dbnames;


END okc_process_pub;

/
