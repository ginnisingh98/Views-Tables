--------------------------------------------------------
--  DDL for Package Body OKC_AQERRMSG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_AQERRMSG_PUB" as
/* $Header: OKCPAQEB.pls 120.0 2005/05/26 09:43:31 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  FUNCTION migrate_aqev(p_aqev_rec1 IN aqev_rec_type,
                        p_aqev_rec2 IN aqev_rec_type)
    RETURN aqev_rec_type IS
    l_aqev_rec aqev_rec_type;
  BEGIN
    l_aqev_rec.id                    := p_aqev_rec1.id;
    l_aqev_rec.source_name 	     := p_aqev_rec1.source_name;
    l_aqev_rec.datetime              := p_aqev_rec1.datetime;
    l_aqev_rec.q_name                := p_aqev_rec1.q_name;
    l_aqev_rec.msgid                 := p_aqev_rec1.msgid;
    l_aqev_rec.retry_count           := p_aqev_rec1.retry_count;
    l_aqev_rec.queue_contents        := p_aqev_rec1.queue_contents;
    l_aqev_rec.created_by            := p_aqev_rec1.created_by;
    l_aqev_rec.creation_date         := p_aqev_rec1.creation_date;
    l_aqev_rec.last_updated_by       := p_aqev_rec1.last_updated_by;
    l_aqev_rec.last_update_date      := p_aqev_rec1.last_update_date;
    l_aqev_rec.last_update_login     := p_aqev_rec1.last_update_login;
     RETURN (l_aqev_rec);
  END migrate_aqev;

  FUNCTION migrate_aqmv(p_aqmv_rec1 IN aqmv_rec_type,
                        p_aqmv_rec2 IN aqmv_rec_type)
    RETURN aqmv_rec_type IS
    l_aqmv_rec aqmv_rec_type;
  BEGIN
    l_aqmv_rec.aqe_id                 := p_aqmv_rec1.aqe_id;
    l_aqmv_rec.msg_seq_no            := p_aqmv_rec1.msg_seq_no;
    l_aqmv_rec.message_name          := p_aqmv_rec1.message_name;
    l_aqmv_rec.message_number        := p_aqmv_rec1.message_number;
    l_aqmv_rec.message_text          := p_aqmv_rec1.message_text;
    l_aqmv_rec.created_by            := p_aqmv_rec1.created_by;
    l_aqmv_rec.creation_date         := p_aqmv_rec1.creation_date;
    l_aqmv_rec.last_updated_by       := p_aqmv_rec1.last_updated_by;
    l_aqmv_rec.last_update_date      := p_aqmv_rec1.last_update_date;
    l_aqmv_rec.last_update_login     := p_aqmv_rec1.last_update_login;
    RETURN (l_aqmv_rec);
  END migrate_aqmv;

  --Object type procedure for insert
  PROCEDURE create_err_msg(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aqev_rec		    IN aqev_rec_type,
    p_aqmv_tbl              IN aqmv_tbl_type,
    x_aqev_rec              OUT NOCOPY aqev_rec_type,
    x_aqmv_tbl              OUT NOCOPY aqmv_tbl_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'create_err_msg';
    l_return_status	    VARCHAR2(1);
    l_aqev_rec              aqev_rec_type;
    l_aqmv_tbl              aqmv_tbl_type := p_aqmv_tbl;
    i			    NUMBER;
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

    --Call to simple API
    okc_aqe_pvt.insert_row(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
    	x_msg_count,
    	x_msg_data,
    	p_aqev_rec,
    	x_aqev_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

    -- Populate the foreign key for the detail
    IF (l_aqmv_tbl.COUNT > 0) THEN
       i := l_aqmv_tbl.FIRST;
       LOOP
          l_aqmv_tbl(i).aqe_id := x_aqev_rec.id;
          EXIT WHEN (i = l_aqmv_tbl.LAST);
          i := l_aqmv_tbl.NEXT(i);
       END LOOP;
    END IF;

    --Populate the detail
    okc_aqm_pvt.insert_row(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
   	x_msg_count,
    	x_msg_data,
    	l_aqmv_tbl,
    	x_aqmv_tbl);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
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
  END create_err_msg;

  --Object type procedure for update
  PROCEDURE update_err_msg(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aqev_rec		    IN aqev_rec_type,
    p_aqmv_tbl              IN aqmv_tbl_type,
    x_aqev_rec              OUT NOCOPY aqev_rec_type,
    x_aqmv_tbl              OUT NOCOPY aqmv_tbl_type) IS

    l_api_version           CONSTANT NUMBER := 1;
    l_api_name              CONSTANT VARCHAR2(30) := 'update_err_msg';
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

   --Update the Master
    okc_aqe_pvt.update_row(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
    	x_msg_count,
    	x_msg_data,
    	p_aqev_rec,
    	x_aqev_rec);
  	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

    --Update the detail
    okc_aqm_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aqmv_tbl,
    x_aqmv_tbl);
    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
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
  END update_err_msg;

  --Object type procedure for validate
  PROCEDURE validate_err_msg(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aqev_rec		    IN aqev_rec_type,
    p_aqmv_tbl              IN aqmv_tbl_type) IS

    l_api_version           CONSTANT NUMBER := 1;
    l_api_name              CONSTANT VARCHAR2(30) := 'validate_err_msg';
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

     --Validate the Master
    okc_aqe_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aqev_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

    --Validate the Detail
    okc_aqm_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aqmv_tbl);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
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
  END validate_err_msg;

  --Procedures for Errors
  PROCEDURE create_err(p_api_version	    IN NUMBER,
    		       p_init_msg_list      IN VARCHAR2 ,
    		       x_return_status      OUT NOCOPY VARCHAR2,
    		       x_msg_count          OUT NOCOPY NUMBER,
    		       x_msg_data           OUT NOCOPY VARCHAR2,
    		       p_aqev_rec	    IN aqev_rec_type,
    		       x_aqev_rec           OUT NOCOPY aqev_rec_type) IS

 	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_err';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aqev_rec      aqev_rec_type := p_aqev_rec;
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
    	g_aqev_rec := l_aqev_rec;

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
	 l_aqev_rec := migrate_aqev(l_aqev_rec, g_aqev_rec);

        -- Call to procedure of Simple API
	okc_aqe_pvt.insert_row(p_api_version   => p_api_version,
    			       p_init_msg_list => p_init_msg_list,
    			       x_return_status => x_return_status,
    			       x_msg_count     => x_msg_count,
    			       x_msg_data      => x_msg_data,
    			       p_aqev_rec      => l_aqev_rec,
    			       x_aqev_rec      => x_aqev_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_ERROR;
     	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_aqev_rec := x_aqev_rec;

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
  END create_err;

 PROCEDURE create_err(p_api_version	    IN NUMBER,
    		       p_init_msg_list      IN VARCHAR2 ,
    		       x_return_status      OUT NOCOPY VARCHAR2,
    		       x_msg_count          OUT NOCOPY NUMBER,
    		       x_msg_data           OUT NOCOPY VARCHAR2,
    		       p_aqev_tbl	    IN aqev_tbl_type,
    		       x_aqev_tbl           OUT NOCOPY aqev_tbl_type) IS

    	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_aqev_tbl.COUNT > 0 THEN
      i := p_aqev_tbl.FIRST;
      LOOP
        create_err(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aqev_tbl(i),
	    x_aqev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aqev_tbl.LAST);
        i := p_aqev_tbl.NEXT(i);
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
  END create_err;

 PROCEDURE lock_err(p_api_version    IN NUMBER,
    		     p_init_msg_list  IN VARCHAR2 ,
    		     x_return_status  OUT NOCOPY VARCHAR2,
    		     x_msg_count      OUT NOCOPY NUMBER,
    		     x_msg_data       OUT NOCOPY VARCHAR2,
    		     p_aqev_rec       IN aqev_rec_type) IS
    	 l_api_name	 CONSTANT VARCHAR2(30) := 'lock_err';
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

    	-- Call to procedure of Simple API
	okc_aqe_pvt.lock_row(p_api_version   => p_api_version,
    			     p_init_msg_list => p_init_msg_list,
    			     x_return_status => x_return_status,
    			     x_msg_count     => x_msg_count,
    			     x_msg_data      => x_msg_data,
			     p_aqev_rec      => p_aqev_rec);
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
  end lock_err;

  PROCEDURE lock_err(p_api_version    IN NUMBER,
    		     p_init_msg_list  IN VARCHAR2 ,
    		     x_return_status  OUT NOCOPY VARCHAR2,
    		     x_msg_count      OUT NOCOPY NUMBER,
    		     x_msg_data       OUT NOCOPY VARCHAR2,
    		     p_aqev_tbl       IN aqev_tbl_type) IS

    	    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	    i				   NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_aqev_tbl.COUNT > 0 THEN
      i := p_aqev_tbl.FIRST;
      LOOP
        lock_err(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aqev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aqev_tbl.LAST);
        i := p_aqev_tbl.NEXT(i);
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
  END lock_err;

  PROCEDURE update_err(p_api_version	       IN NUMBER,
    		       p_init_msg_list         IN VARCHAR2 ,
    		       x_return_status         OUT NOCOPY VARCHAR2,
    		       x_msg_count             OUT NOCOPY NUMBER,
    		       x_msg_data              OUT NOCOPY VARCHAR2,
    		       p_aqev_rec	       IN aqev_rec_type,
    		       x_aqev_rec              OUT NOCOPY aqev_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'update_err';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aqev_rec      aqev_rec_type := p_aqev_rec;
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
	g_aqev_rec := l_aqev_rec;

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
	l_aqev_rec := migrate_aqev(l_aqev_rec, g_aqev_rec);

    	-- Call to procedure of Simple API
	okc_aqe_pvt.update_row(p_api_version   => p_api_version,
    			       p_init_msg_list => p_init_msg_list,
    			       x_return_status => x_return_status,
    		               x_msg_count     => x_msg_count,
    			       x_msg_data      => x_msg_data,
    			       p_aqev_rec      => l_aqev_rec,
    			       x_aqev_rec      => x_aqev_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

  	--USER HOOK CALL FOR AFTER, STARTS
	g_aqev_rec := x_aqev_rec;

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
  end update_err;

 PROCEDURE update_err(p_api_version	       IN NUMBER,
    		       p_init_msg_list         IN VARCHAR2 ,
    		       x_return_status         OUT NOCOPY VARCHAR2,
    		       x_msg_count             OUT NOCOPY NUMBER,
    		       x_msg_data              OUT NOCOPY VARCHAR2,
    		       p_aqev_tbl	       IN aqev_tbl_type,
    		       x_aqev_tbl              OUT NOCOPY aqev_tbl_type) IS

        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i			       NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_aqev_tbl.COUNT > 0 THEN
      i := p_aqev_tbl.FIRST;
      LOOP
        update_err(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aqev_tbl(i),
	    x_aqev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aqev_tbl.LAST);
        i := p_aqev_tbl.NEXT(i);
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
  END update_err;

  PROCEDURE delete_err(p_api_version	    IN NUMBER,
    		       p_init_msg_list      IN VARCHAR2 ,
    		       x_return_status      OUT NOCOPY VARCHAR2,
    		       x_msg_count          OUT NOCOPY NUMBER,
    		       x_msg_data           OUT NOCOPY VARCHAR2,
    		       p_aqev_rec	    IN aqev_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_err';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aqev_rec      aqev_rec_type := p_aqev_rec;
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
    	g_aqev_rec := l_aqev_rec;

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
	l_aqev_rec := migrate_aqev(l_aqev_rec, g_aqev_rec);

    	-- Call to procedure of Simple API
	okc_aqe_pvt.delete_row(p_api_version   => p_api_version,
    			       p_init_msg_list => p_init_msg_list,
    			       x_return_status => x_return_status,
    			       x_msg_count     => x_msg_count,
    			       x_msg_data      => x_msg_data,
    			       p_aqev_rec      => l_aqev_rec);
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
  end delete_err;

   PROCEDURE delete_err(p_api_version	    IN NUMBER,
    		       p_init_msg_list      IN VARCHAR2 ,
    		       x_return_status      OUT NOCOPY VARCHAR2,
    		       x_msg_count          OUT NOCOPY NUMBER,
    		       x_msg_data           OUT NOCOPY VARCHAR2,
    		       p_aqev_tbl	    IN aqev_tbl_type) IS

        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i			       NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_aqev_tbl.COUNT > 0 THEN
      i := p_aqev_tbl.FIRST;
      LOOP
        delete_err(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aqev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aqev_tbl.LAST);
        i := p_aqev_tbl.NEXT(i);
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
  END delete_err;

  PROCEDURE validate_err(p_api_version	      IN NUMBER,
    			  p_init_msg_list     IN VARCHAR2 ,
    			  x_return_status     OUT NOCOPY VARCHAR2,
    			  x_msg_count         OUT NOCOPY NUMBER,
    			  x_msg_data          OUT NOCOPY VARCHAR2,
    			  p_aqev_rec	      IN aqev_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'validate_err';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aqev_rec      aqev_rec_type := p_aqev_rec;
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
    	g_aqev_rec := l_aqev_rec;

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
	l_aqev_rec := migrate_aqev(l_aqev_rec, g_aqev_rec);

    	-- Call to procedure of Simple API
	okc_aqe_pvt.validate_row(p_api_version   => p_api_version,
    				 p_init_msg_list => p_init_msg_list,
    				 x_return_status => x_return_status,
    				 x_msg_count     => x_msg_count,
    				 x_msg_data      => x_msg_data,
    				 p_aqev_rec      => l_aqev_rec);
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
  END validate_err;

   PROCEDURE validate_err(p_api_version	    IN NUMBER,
    		       p_init_msg_list      IN VARCHAR2 ,
    		       x_return_status      OUT NOCOPY VARCHAR2,
    		       x_msg_count          OUT NOCOPY NUMBER,
    		       x_msg_data           OUT NOCOPY VARCHAR2,
    		       p_aqev_tbl	    IN aqev_tbl_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i				   NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_aqev_tbl.COUNT > 0 THEN
      i := p_aqev_tbl.FIRST;
      LOOP
        validate_err(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aqev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aqev_tbl.LAST);
        i := p_aqev_tbl.NEXT(i);
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
  END validate_err;

  --Procedures for Messages
  PROCEDURE create_msg(p_api_version	 IN  NUMBER,
   		       p_init_msg_list   IN  VARCHAR2 ,
    		       x_return_status   OUT NOCOPY VARCHAR2,
    		       x_msg_count       OUT NOCOPY NUMBER,
    		       x_msg_data        OUT NOCOPY VARCHAR2,
   		       p_aqmv_rec        IN  aqmv_rec_type,
    		       x_aqmv_rec        OUT NOCOPY aqmv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_msg';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aqmv_rec      aqmv_rec_type := p_aqmv_rec;
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
    	g_aqmv_rec := l_aqmv_rec;

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
	l_aqmv_rec := migrate_aqmv(l_aqmv_rec, g_aqmv_rec);

    	-- Call to procedure of Simple API
	okc_aqm_pvt.insert_row(p_api_version   => p_api_version,
    			       p_init_msg_list => p_init_msg_list,
    			       x_return_status => x_return_status,
    			       x_msg_count     => x_msg_count,
    			       x_msg_data      => x_msg_data,
    			       p_aqmv_rec      => l_aqmv_rec,
    			       x_aqmv_rec      => x_aqmv_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_aqmv_rec := x_aqmv_rec;

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
  end create_msg;

   PROCEDURE create_msg(p_api_version	 IN  NUMBER,
   		       p_init_msg_list   IN  VARCHAR2 ,
    		       x_return_status   OUT NOCOPY VARCHAR2,
    		       x_msg_count       OUT NOCOPY NUMBER,
    		       x_msg_data        OUT NOCOPY VARCHAR2,
   		       p_aqmv_tbl        IN  aqmv_tbl_type,
    		       x_aqmv_tbl        OUT NOCOPY aqmv_tbl_type) IS
	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_aqmv_tbl.COUNT > 0 THEN
      i := p_aqmv_tbl.FIRST;
      LOOP
        create_msg(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aqmv_tbl(i),
	    x_aqmv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aqmv_tbl.LAST);
        i := p_aqmv_tbl.NEXT(i);
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
  END create_msg;

  PROCEDURE lock_msg(p_api_version	 IN  NUMBER,
    		     p_init_msg_list     IN  VARCHAR2 ,
    		     x_return_status     OUT NOCOPY VARCHAR2,
    		     x_msg_count         OUT NOCOPY NUMBER,
    		     x_msg_data          OUT NOCOPY VARCHAR2,
    		     p_aqmv_rec	    	 IN  aqmv_rec_type) IS
  	 l_api_name	 CONSTANT VARCHAR2(30) := 'lock_msg';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aqmv_rec      aqmv_rec_type := p_aqmv_rec;
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

    	-- Call to procedure of Simple API
	okc_aqm_pvt.lock_row(p_api_version   => p_api_version,
    			     p_init_msg_list => p_init_msg_list,
    			     x_return_status => x_return_status,
    			     x_msg_count     => x_msg_count,
    			     x_msg_data      => x_msg_data,
    			     p_aqmv_rec      => l_aqmv_rec);

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
  end lock_msg;

   PROCEDURE lock_msg(p_api_version	 IN  NUMBER,
    		     p_init_msg_list     IN  VARCHAR2 ,
    		     x_return_status     OUT NOCOPY VARCHAR2,
    		     x_msg_count         OUT NOCOPY NUMBER,
    		     x_msg_data          OUT NOCOPY VARCHAR2,
    		     p_aqmv_tbl	    	 IN  aqmv_tbl_type) IS
        l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i			NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_aqmv_tbl.COUNT > 0 THEN
      i := p_aqmv_tbl.FIRST;
      LOOP
        lock_msg(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aqmv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aqmv_tbl.LAST);
        i := p_aqmv_tbl.NEXT(i);
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
  End lock_msg;

  PROCEDURE update_msg(p_api_version	 IN NUMBER,
    		       p_init_msg_list   IN VARCHAR2 ,
    		       x_return_status   OUT NOCOPY VARCHAR2,
    		       x_msg_count       OUT NOCOPY NUMBER,
    		       x_msg_data        OUT NOCOPY VARCHAR2,
    		       p_aqmv_rec        IN aqmv_rec_type,
    		       x_aqmv_rec        OUT NOCOPY aqmv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'update_msg';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aqmv_rec      aqmv_rec_type := p_aqmv_rec;
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
    	g_aqmv_rec := l_aqmv_rec;

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
	l_aqmv_rec := migrate_aqmv(l_aqmv_rec, g_aqmv_rec);

    	-- Call to procedure of Simple API
	okc_aqm_pvt.update_row(p_api_version   => p_api_version,
    			        p_init_msg_list => p_init_msg_list,
    			        x_return_status => x_return_status,
    				x_msg_count     => x_msg_count,
    				x_msg_data      => x_msg_data,
    				p_aqmv_rec      => l_aqmv_rec,
    				x_aqmv_rec      => x_aqmv_rec);

	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_aqmv_rec := x_aqmv_rec;

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
  END update_msg;

  PROCEDURE update_msg(p_api_version	 IN NUMBER,
    		       p_init_msg_list   IN VARCHAR2 ,
    		       x_return_status   OUT NOCOPY VARCHAR2,
    		       x_msg_count       OUT NOCOPY NUMBER,
    		       x_msg_data        OUT NOCOPY VARCHAR2,
    		       p_aqmv_tbl        IN aqmv_tbl_type,
    		       x_aqmv_tbl        OUT NOCOPY aqmv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_aqmv_tbl.COUNT > 0 THEN
      i := p_aqmv_tbl.FIRST;
      LOOP
        update_msg(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aqmv_tbl(i),
	    x_aqmv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aqmv_tbl.LAST);
        i := p_aqmv_tbl.NEXT(i);
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
  END update_msg;

  PROCEDURE delete_msg(p_api_version	 IN  NUMBER,
    		       p_init_msg_list   IN  VARCHAR2 ,
    		       x_return_status   OUT NOCOPY VARCHAR2,
    		       x_msg_count       OUT NOCOPY NUMBER,
    		       x_msg_data        OUT NOCOPY VARCHAR2,
    		       p_aqmv_rec	 IN  aqmv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_msg';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aqmv_rec      aqmv_rec_type := p_aqmv_rec;
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
    	g_aqmv_rec := l_aqmv_rec;

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
	l_aqmv_rec := migrate_aqmv(l_aqmv_rec, g_aqmv_rec);

    	-- Call to procedure of Simple API
	okc_aqm_pvt.delete_row(p_api_version   => p_api_version,
    			       p_init_msg_list => p_init_msg_list,
    			       x_return_status => x_return_status,
    			       x_msg_count     => x_msg_count,
    			       x_msg_data      => x_msg_data,
    			       p_aqmv_rec      => l_aqmv_rec);
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
  END delete_msg;

  PROCEDURE delete_msg(p_api_version	 IN  NUMBER,
    		       p_init_msg_list   IN  VARCHAR2 ,
    		       x_return_status   OUT NOCOPY VARCHAR2,
    		       x_msg_count       OUT NOCOPY NUMBER,
    		       x_msg_data        OUT NOCOPY VARCHAR2,
    		       p_aqmv_tbl	 IN  aqmv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_aqmv_tbl.COUNT > 0 THEN
       i := p_aqmv_tbl.FIRST;
      LOOP
        delete_msg(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aqmv_tbl(i));
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;
        EXIT WHEN (i = p_aqmv_tbl.LAST);
        i := p_aqmv_tbl.NEXT(i);
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
  END delete_msg;

  PROCEDURE validate_msg(p_api_version	 IN  NUMBER,
    		         p_init_msg_list IN  VARCHAR2 ,
    		         x_return_status OUT NOCOPY VARCHAR2,
    		         x_msg_count     OUT NOCOPY NUMBER,
    		         x_msg_data      OUT NOCOPY VARCHAR2,
   			 p_aqmv_rec      IN  aqmv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'validate_msg';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aqmv_rec      aqmv_rec_type := p_aqmv_rec;
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
    	g_aqmv_rec := l_aqmv_rec;

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
	l_aqmv_rec := migrate_aqmv(l_aqmv_rec, g_aqmv_rec);

    	-- Call to procedure of complex API
	okc_aqm_pvt.validate_row(p_api_version   => p_api_version,
    			   	 p_init_msg_list => p_init_msg_list,
    				 x_return_status => x_return_status,
    				 x_msg_count     => x_msg_count,
    				 x_msg_data      => x_msg_data,
    				 p_aqmv_rec      => l_aqmv_rec);

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
  END validate_msg;

 PROCEDURE validate_msg(p_api_version	 IN  NUMBER,
    		         p_init_msg_list IN  VARCHAR2 ,
    		         x_return_status OUT NOCOPY VARCHAR2,
    		         x_msg_count     OUT NOCOPY NUMBER,
    		         x_msg_data      OUT NOCOPY VARCHAR2,
   			 p_aqmv_tbl      IN  aqmv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_aqmv_tbl.COUNT > 0 THEN
      i := p_aqmv_tbl.FIRST;
      LOOP
        validate_msg(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aqmv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aqmv_tbl.LAST);
        i := p_aqmv_tbl.NEXT(i);
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
  END validate_msg;

END okc_aqerrmsg_pub;

/
