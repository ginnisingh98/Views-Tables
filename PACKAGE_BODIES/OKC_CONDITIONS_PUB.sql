--------------------------------------------------------
--  DDL for Package Body OKC_CONDITIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONDITIONS_PUB" as
/* $Header: OKCPCNHB.pls 120.0 2005/05/25 18:25:56 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  FUNCTION migrate_cnhv(p_cnhv_rec1 IN cnhv_rec_type,
                        p_cnhv_rec2 IN cnhv_rec_type)
    RETURN cnhv_rec_type IS
    l_cnhv_rec cnhv_rec_type;
  BEGIN
    l_cnhv_rec.id                    := p_cnhv_rec1.id;
    l_cnhv_rec.object_version_number := p_cnhv_rec1.object_version_number;
    l_cnhv_rec.created_by            := p_cnhv_rec1.created_by;
    l_cnhv_rec.creation_date         := p_cnhv_rec1.creation_date;
    l_cnhv_rec.last_updated_by       := p_cnhv_rec1.last_updated_by;
    l_cnhv_rec.last_update_date      := p_cnhv_rec1.last_update_date;
    l_cnhv_rec.last_update_login     := p_cnhv_rec1.last_update_login;
    l_cnhv_rec.sfwt_flag             := p_cnhv_rec2.sfwt_flag;
    l_cnhv_rec.seeded_flag           := p_cnhv_rec2.seeded_flag;
    l_cnhv_rec.application_id        := p_cnhv_rec2.application_id;
    l_cnhv_rec.last_rundate          := p_cnhv_rec2.last_rundate;
    l_cnhv_rec.description           := p_cnhv_rec2.description;
    l_cnhv_rec.short_description     := p_cnhv_rec2.short_description;
    l_cnhv_rec.comments              := p_cnhv_rec2.comments;
    l_cnhv_rec.acn_id                := p_cnhv_rec2.acn_id;
    l_cnhv_rec.counter_group_id      := p_cnhv_rec2.counter_group_id;
    l_cnhv_rec.name                  := p_cnhv_rec2.name;
    l_cnhv_rec.one_time_yn           := p_cnhv_rec2.one_time_yn;
    l_cnhv_rec.condition_valid_yn    := p_cnhv_rec2.condition_valid_yn;
    l_cnhv_rec.tracked_yn            := p_cnhv_rec2.tracked_yn;
    l_cnhv_rec.task_owner_id         := p_cnhv_rec2.task_owner_id;
    l_cnhv_rec.before_after          := p_cnhv_rec2.before_after;
    l_cnhv_rec.cnh_variance          := p_cnhv_rec2.cnh_variance;
    l_cnhv_rec.template_yn           := p_cnhv_rec2.template_yn;
    l_cnhv_rec.dnz_chr_id            := p_cnhv_rec2.dnz_chr_id;
    l_cnhv_rec.date_active           := p_cnhv_rec2.date_active;
    l_cnhv_rec.date_inactive         := p_cnhv_rec2.date_inactive;
    l_cnhv_rec.object_id             := p_cnhv_rec2.object_id;
    l_cnhv_rec.jtot_object_code      := p_cnhv_rec2.jtot_object_code;
    l_cnhv_rec.cnh_type              := p_cnhv_rec2.cnh_type;
    l_cnhv_rec.attribute_category    := p_cnhv_rec2.attribute_category;
    l_cnhv_rec.attribute1            := p_cnhv_rec2.attribute1;
    l_cnhv_rec.attribute2            := p_cnhv_rec2.attribute2;
    l_cnhv_rec.attribute3            := p_cnhv_rec2.attribute3;
    l_cnhv_rec.attribute4            := p_cnhv_rec2.attribute4;
    l_cnhv_rec.attribute5            := p_cnhv_rec2.attribute5;
    l_cnhv_rec.attribute6            := p_cnhv_rec2.attribute6;
    l_cnhv_rec.attribute7            := p_cnhv_rec2.attribute7;
    l_cnhv_rec.attribute8            := p_cnhv_rec2.attribute8;
    l_cnhv_rec.attribute9            := p_cnhv_rec2.attribute9;
    l_cnhv_rec.attribute10           := p_cnhv_rec2.attribute10;
    l_cnhv_rec.attribute11           := p_cnhv_rec2.attribute11;
    l_cnhv_rec.attribute12           := p_cnhv_rec2.attribute12;
    l_cnhv_rec.attribute13           := p_cnhv_rec2.attribute13;
    l_cnhv_rec.attribute14           := p_cnhv_rec2.attribute14;
    l_cnhv_rec.attribute15           := p_cnhv_rec2.attribute15;
    RETURN (l_cnhv_rec);
  END migrate_cnhv;

  FUNCTION migrate_cnlv(p_cnlv_rec1 IN cnlv_rec_type,
                        p_cnlv_rec2 IN cnlv_rec_type)
    RETURN cnlv_rec_type IS
    l_cnlv_rec cnlv_rec_type;
  BEGIN
    l_cnlv_rec.id                    := p_cnlv_rec1.id;
    l_cnlv_rec.object_version_number := p_cnlv_rec1.object_version_number;
    l_cnlv_rec.created_by            := p_cnlv_rec1.created_by;
    l_cnlv_rec.creation_date         := p_cnlv_rec1.creation_date;
    l_cnlv_rec.last_updated_by       := p_cnlv_rec1.last_updated_by;
    l_cnlv_rec.last_update_date      := p_cnlv_rec1.last_update_date;
    l_cnlv_rec.last_update_login     := p_cnlv_rec1.last_update_login;
    l_cnlv_rec.sfwt_flag             := p_cnlv_rec2.sfwt_flag;
    l_cnlv_rec.seeded_flag           := p_cnlv_rec2.seeded_flag;
    l_cnlv_rec.application_id        := p_cnlv_rec2.application_id;
    l_cnlv_rec.cnh_id                := p_cnlv_rec2.cnh_id;
    l_cnlv_rec.pdf_id                := p_cnlv_rec2.pdf_id;
    l_cnlv_rec.aae_id                := p_cnlv_rec2.aae_id;
    l_cnlv_rec.left_ctr_master_id    := p_cnlv_rec2.left_ctr_master_id;
    l_cnlv_rec.right_ctr_master_id   := p_cnlv_rec2.right_ctr_master_id;
    l_cnlv_rec.left_counter_id       := p_cnlv_rec2.left_counter_id;
    l_cnlv_rec.right_counter_id      := p_cnlv_rec2.right_counter_id;
    l_cnlv_rec.sortseq               := p_cnlv_rec2.sortseq;
    l_cnlv_rec.cnl_type              := p_cnlv_rec2.cnl_type;
    l_cnlv_rec.description           := p_cnlv_rec2.description;
    l_cnlv_rec.left_parenthesis      := p_cnlv_rec2.left_parenthesis;
    l_cnlv_rec.relational_operator   := p_cnlv_rec2.relational_operator;
    l_cnlv_rec.right_parenthesis     := p_cnlv_rec2.right_parenthesis;
    l_cnlv_rec.logical_operator      := p_cnlv_rec2.logical_operator;
    l_cnlv_rec.tolerance             := p_cnlv_rec2.tolerance;
    l_cnlv_rec.start_at              := p_cnlv_rec2.start_at;
    l_cnlv_rec.right_operand         := p_cnlv_rec2.right_operand;
    l_cnlv_rec.dnz_chr_id            := p_cnlv_rec2.dnz_chr_id;
    l_cnlv_rec.attribute_category    := p_cnlv_rec2.attribute_category;
    l_cnlv_rec.attribute1            := p_cnlv_rec2.attribute1;
    l_cnlv_rec.attribute2            := p_cnlv_rec2.attribute2;
    l_cnlv_rec.attribute3            := p_cnlv_rec2.attribute3;
    l_cnlv_rec.attribute4            := p_cnlv_rec2.attribute4;
    l_cnlv_rec.attribute5            := p_cnlv_rec2.attribute5;
    l_cnlv_rec.attribute6            := p_cnlv_rec2.attribute6;
    l_cnlv_rec.attribute7            := p_cnlv_rec2.attribute7;
    l_cnlv_rec.attribute8            := p_cnlv_rec2.attribute8;
    l_cnlv_rec.attribute9            := p_cnlv_rec2.attribute9;
    l_cnlv_rec.attribute10           := p_cnlv_rec2.attribute10;
    l_cnlv_rec.attribute11           := p_cnlv_rec2.attribute11;
    l_cnlv_rec.attribute12           := p_cnlv_rec2.attribute12;
    l_cnlv_rec.attribute13           := p_cnlv_rec2.attribute13;
    l_cnlv_rec.attribute14           := p_cnlv_rec2.attribute14;
    l_cnlv_rec.attribute15           := p_cnlv_rec2.attribute15;
    RETURN (l_cnlv_rec);
  END migrate_cnlv;

  FUNCTION migrate_coev(p_coev_rec1 IN coev_rec_type,
                        p_coev_rec2 IN coev_rec_type)
    RETURN coev_rec_type IS
    l_coev_rec coev_rec_type;
  BEGIN
    l_coev_rec.id                    := p_coev_rec1.id;
    l_coev_rec.object_version_number := p_coev_rec1.object_version_number;
    l_coev_rec.created_by            := p_coev_rec1.created_by;
    l_coev_rec.creation_date         := p_coev_rec1.creation_date;
    l_coev_rec.last_updated_by       := p_coev_rec1.last_updated_by;
    l_coev_rec.last_update_date      := p_coev_rec1.last_update_date;
    l_coev_rec.last_update_login     := p_coev_rec1.last_update_login;
    l_coev_rec.cnh_id                := p_coev_rec2.cnh_id;
    l_coev_rec.datetime              := p_coev_rec2.datetime;
    RETURN (l_coev_rec);
  END migrate_coev;

  FUNCTION migrate_aavv(p_aavv_rec1 IN aavv_rec_type,
                        p_aavv_rec2 IN aavv_rec_type)
    RETURN aavv_rec_type IS
    l_aavv_rec aavv_rec_type;
  BEGIN
    l_aavv_rec.object_version_number := p_aavv_rec1.object_version_number;
    l_aavv_rec.created_by            := p_aavv_rec1.created_by;
    l_aavv_rec.creation_date         := p_aavv_rec1.creation_date;
    l_aavv_rec.last_updated_by       := p_aavv_rec1.last_updated_by;
    l_aavv_rec.last_update_date      := p_aavv_rec1.last_update_date;
    l_aavv_rec.last_update_login     := p_aavv_rec1.last_update_login;
    l_aavv_rec.aae_id                := p_aavv_rec1.aae_id;
    l_aavv_rec.coe_id                := p_aavv_rec1.coe_id;
    l_aavv_rec.value                 := p_aavv_rec2.value;
    RETURN (l_aavv_rec);
  END migrate_aavv;

  FUNCTION migrate_aalv(p_aalv_rec1 IN aalv_rec_type,
                        p_aalv_rec2 IN aalv_rec_type)
    RETURN aalv_rec_type IS
    l_aalv_rec aalv_rec_type;
  BEGIN
    l_aalv_rec.object_version_number := p_aalv_rec1.object_version_number;
    l_aalv_rec.created_by            := p_aalv_rec1.created_by;
    l_aalv_rec.creation_date         := p_aalv_rec1.creation_date;
    l_aalv_rec.last_updated_by       := p_aalv_rec1.last_updated_by;
    l_aalv_rec.last_update_date      := p_aalv_rec1.last_update_date;
    l_aalv_rec.last_update_login     := p_aalv_rec1.last_update_login;
    l_aalv_rec.id                    := p_aalv_rec1.id;
    l_aalv_rec.object_name           := p_aalv_rec2.object_name;
    l_aalv_rec.column_name           := p_aalv_rec2.column_name;
    RETURN (l_aalv_rec);
  END migrate_aalv;

  FUNCTION migrate_fepv(p_fepv_rec1 IN fepv_rec_type,
                        p_fepv_rec2 IN fepv_rec_type)
    RETURN fepv_rec_type IS
    l_fepv_rec fepv_rec_type;
  BEGIN
    l_fepv_rec.object_version_number := p_fepv_rec1.object_version_number;
    l_fepv_rec.seeded_flag           := p_fepv_rec1.seeded_flag;
    l_fepv_rec.application_id        := p_fepv_rec1.application_id;
    l_fepv_rec.created_by            := p_fepv_rec1.created_by;
    l_fepv_rec.creation_date         := p_fepv_rec1.creation_date;
    l_fepv_rec.last_updated_by       := p_fepv_rec1.last_updated_by;
    l_fepv_rec.last_update_date      := p_fepv_rec1.last_update_date;
    l_fepv_rec.last_update_login     := p_fepv_rec1.last_update_login;
    l_fepv_rec.id                    := p_fepv_rec1.id;
    l_fepv_rec.cnl_id                := p_fepv_rec1.cnl_id;
    l_fepv_rec.pdp_id                := p_fepv_rec1.pdp_id;
    l_fepv_rec.aae_id                := p_fepv_rec1.aae_id;
    l_fepv_rec.dnz_chr_id            := p_fepv_rec1.dnz_chr_id;
    l_fepv_rec.value                 := p_fepv_rec2.value;
    RETURN (l_fepv_rec);
  END migrate_fepv;

  PROCEDURE add_language IS
  BEGIN
    okc_conditions_pvt.add_language;
  END;

  --Object type procedure for insert
  PROCEDURE create_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_rec		    IN cnhv_rec_type,
    p_cnlv_tbl              IN cnlv_tbl_type,
    x_cnhv_rec              OUT NOCOPY cnhv_rec_type,
    x_cnlv_tbl              OUT NOCOPY cnlv_tbl_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'create_cond_hdrs';
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
    okc_conditions_pvt.create_cond_hdrs(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cnhv_rec,
	    p_cnlv_tbl,
	    x_cnhv_rec,
	    x_cnlv_tbl);
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
  END create_cond_hdrs;

  --Object type procedure for update
  PROCEDURE update_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_rec		    IN cnhv_rec_type,
    p_cnlv_tbl              IN cnlv_tbl_type,
    x_cnhv_rec              OUT NOCOPY cnhv_rec_type,
    x_cnlv_tbl              OUT NOCOPY cnlv_tbl_type) IS

    l_api_version           CONSTANT NUMBER := 1;
    l_api_name              CONSTANT VARCHAR2(30) := 'V_update_cond_hdrs';
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
    okc_conditions_pvt.update_cond_hdrs(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cnhv_rec,
	    p_cnlv_tbl,
	    x_cnhv_rec,
	    x_cnlv_tbl);
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
  END update_cond_hdrs;

  --Object type procedure for validate
  PROCEDURE validate_cond_hdrs(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnhv_rec		    IN cnhv_rec_type,
    p_cnlv_tbl              IN cnlv_tbl_type) IS

    l_api_version           CONSTANT NUMBER := 1;
    l_api_name              CONSTANT VARCHAR2(30) := 'V_validate_cond_hdrs';
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

    okc_conditions_pvt.validate_cond_hdrs(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cnhv_rec,
	    p_cnlv_tbl);
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
  END validate_cond_hdrs;

  --Procedures for conditions headers

  PROCEDURE create_cond_hdrs(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_cnhv_rec		    IN cnhv_rec_type,
    			    x_cnhv_rec              OUT NOCOPY cnhv_rec_type) IS

 	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_cond_hdrs';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_cnhv_rec      cnhv_rec_type := p_cnhv_rec;
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
    	g_cnhv_rec := l_cnhv_rec;

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
	 l_cnhv_rec := migrate_cnhv(l_cnhv_rec, g_cnhv_rec);

        -- Call to procedure of complex API
	okc_conditions_pvt.create_cond_hdrs(p_api_version   => p_api_version,
    				        p_init_msg_list => p_init_msg_list,
    				        x_return_status => x_return_status,
    				        x_msg_count     => x_msg_count,
    				   	x_msg_data      => x_msg_data,
    				   	p_cnhv_rec      => l_cnhv_rec,
    				   	x_cnhv_rec      => x_cnhv_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_ERROR;
     	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_cnhv_rec := x_cnhv_rec;

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
  END create_cond_hdrs;

  PROCEDURE create_cond_hdrs(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_cnhv_tbl		    IN cnhv_tbl_type,
    			    x_cnhv_tbl              OUT NOCOPY cnhv_tbl_type) IS

    	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_cnhv_tbl.COUNT > 0 THEN
      i := p_cnhv_tbl.FIRST;
      LOOP
        create_cond_hdrs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cnhv_tbl(i),
	    x_cnhv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cnhv_tbl.LAST);
        i := p_cnhv_tbl.NEXT(i);
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
  END create_cond_hdrs;

 PROCEDURE lock_cond_hdrs(p_api_version	    	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_cnhv_rec		    IN cnhv_rec_type) IS

    	 l_api_name	 CONSTANT VARCHAR2(30) := 'lock_cond_hdrs';
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
	okc_conditions_pvt.lock_cond_hdrs(p_api_version   => p_api_version,
    				    p_init_msg_list => p_init_msg_list,
    				    x_return_status => x_return_status,
    				    x_msg_count     => x_msg_count,
    				    x_msg_data      => x_msg_data,
				    p_cnhv_rec      => p_cnhv_rec);
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
  end lock_cond_hdrs;

  PROCEDURE lock_cond_hdrs(p_api_version	   IN NUMBER,
    			  p_init_msg_list  IN VARCHAR2 ,
    			  x_return_status  OUT NOCOPY VARCHAR2,
    			  x_msg_count      OUT NOCOPY NUMBER,
    			  x_msg_data       OUT NOCOPY VARCHAR2,
    			  p_cnhv_tbl       IN cnhv_tbl_type) IS

    	    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	    i				   NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cnhv_tbl.COUNT > 0 THEN
      i := p_cnhv_tbl.FIRST;
      LOOP
        lock_cond_hdrs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cnhv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cnhv_tbl.LAST);
        i := p_cnhv_tbl.NEXT(i);
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
  END lock_cond_hdrs;

  PROCEDURE update_cond_hdrs(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_cnhv_rec		    IN cnhv_rec_type,
    			    x_cnhv_rec              OUT NOCOPY cnhv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'update_cond_hdrs';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_cnhv_rec      cnhv_rec_type := p_cnhv_rec;
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
	g_cnhv_rec := l_cnhv_rec;

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
	l_cnhv_rec := migrate_cnhv(l_cnhv_rec, g_cnhv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.update_cond_hdrs(p_api_version   => p_api_version,
    				    p_init_msg_list => p_init_msg_list,
    				    x_return_status => x_return_status,
    				    x_msg_count     => x_msg_count,
    				    x_msg_data      => x_msg_data,
    				    p_cnhv_rec      => l_cnhv_rec,
    				    x_cnhv_rec      => x_cnhv_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

  	--USER HOOK CALL FOR AFTER, STARTS
	g_cnhv_rec := x_cnhv_rec;

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

  end update_cond_hdrs;

  PROCEDURE update_cond_hdrs(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
     			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_cnhv_tbl		    IN cnhv_tbl_type,
    			    x_cnhv_tbl              OUT NOCOPY cnhv_tbl_type) IS

        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i			       NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cnhv_tbl.COUNT > 0 THEN
      i := p_cnhv_tbl.FIRST;
      LOOP
        update_cond_hdrs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cnhv_tbl(i),
	    x_cnhv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cnhv_tbl.LAST);
        i := p_cnhv_tbl.NEXT(i);
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
  END update_cond_hdrs;

  PROCEDURE delete_cond_hdrs(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_cnhv_rec		    IN cnhv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_cond_hdrs';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_cnhv_rec      cnhv_rec_type := p_cnhv_rec;
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
    	g_cnhv_rec := l_cnhv_rec;

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
	l_cnhv_rec := migrate_cnhv(l_cnhv_rec, g_cnhv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.delete_cond_hdrs(p_api_version   => p_api_version,
    				    p_init_msg_list => p_init_msg_list,
    				    x_return_status => x_return_status,
    				    x_msg_count     => x_msg_count,
    				    x_msg_data      => x_msg_data,
    				    p_cnhv_rec      => l_cnhv_rec);
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
  end delete_cond_hdrs;

  PROCEDURE delete_cond_hdrs(p_api_version	    IN NUMBER,
    			    p_init_msg_list         IN VARCHAR2 ,
    			    x_return_status         OUT NOCOPY VARCHAR2,
    			    x_msg_count             OUT NOCOPY NUMBER,
    			    x_msg_data              OUT NOCOPY VARCHAR2,
    			    p_cnhv_tbl		    IN cnhv_tbl_type) IS

        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i			       NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cnhv_tbl.COUNT > 0 THEN
      i := p_cnhv_tbl.FIRST;
      LOOP
        delete_cond_hdrs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cnhv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cnhv_tbl.LAST);
        i := p_cnhv_tbl.NEXT(i);
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
  END delete_cond_hdrs;

  PROCEDURE validate_cond_hdrs(p_api_version	      IN NUMBER,
    			      p_init_msg_list         IN VARCHAR2 ,
    			      x_return_status         OUT NOCOPY VARCHAR2,
    			      x_msg_count             OUT NOCOPY NUMBER,
    			      x_msg_data              OUT NOCOPY VARCHAR2,
    			      p_cnhv_rec	      IN cnhv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'validate_cond_hdrs';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_cnhv_rec      cnhv_rec_type := p_cnhv_rec;
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
    	g_cnhv_rec := l_cnhv_rec;

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
	l_cnhv_rec := migrate_cnhv(l_cnhv_rec, g_cnhv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.validate_cond_hdrs(p_api_version   => p_api_version,
    				      p_init_msg_list => p_init_msg_list,
    				      x_return_status => x_return_status,
    				      x_msg_count     => x_msg_count,
    				      x_msg_data      => x_msg_data,
    				      p_cnhv_rec      => l_cnhv_rec);
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
  END validate_cond_hdrs;

  PROCEDURE validate_cond_hdrs(p_api_version	      IN NUMBER,
    			      p_init_msg_list         IN VARCHAR2 ,
    			      x_return_status         OUT NOCOPY VARCHAR2,
    			      x_msg_count             OUT NOCOPY NUMBER,
    			      x_msg_data              OUT NOCOPY VARCHAR2,
    			      p_cnhv_tbl	      IN cnhv_tbl_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i				   NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cnhv_tbl.COUNT > 0 THEN
      i := p_cnhv_tbl.FIRST;
      LOOP
        validate_cond_hdrs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cnhv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cnhv_tbl.LAST);
        i := p_cnhv_tbl.NEXT(i);
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
  END validate_cond_hdrs;

  --Procedures for condition lines

  PROCEDURE create_cond_lines(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_cnlv_rec        IN  cnlv_rec_type,
    				  x_cnlv_rec        OUT NOCOPY cnlv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_cond_lines';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_cnlv_rec      cnlv_rec_type := p_cnlv_rec;
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
    	g_cnlv_rec := l_cnlv_rec;

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
	l_cnlv_rec := migrate_cnlv(l_cnlv_rec, g_cnlv_rec);
    	-- Call to procedure of complex API
	okc_conditions_pvt.create_cond_lines(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_cnlv_rec      => l_cnlv_rec,
    				    	  x_cnlv_rec      => x_cnlv_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_cnlv_rec := x_cnlv_rec;

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
  end create_cond_lines;

  PROCEDURE create_cond_lines(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_cnlv_tbl	    IN  cnlv_tbl_type,
    				  x_cnlv_tbl        OUT NOCOPY cnlv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_cnlv_tbl.COUNT > 0 THEN
      i := p_cnlv_tbl.FIRST;
      LOOP
        create_cond_lines(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cnlv_tbl(i),
	    x_cnlv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cnlv_tbl.LAST);
        i := p_cnlv_tbl.NEXT(i);
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
  END create_cond_lines;

  PROCEDURE lock_cond_lines(p_api_version	    IN  NUMBER,
    				p_init_msg_list     IN  VARCHAR2 ,
    				x_return_status     OUT NOCOPY VARCHAR2,
    				x_msg_count         OUT NOCOPY NUMBER,
    				x_msg_data          OUT NOCOPY VARCHAR2,
    				p_cnlv_rec	    IN  cnlv_rec_type) IS
  	 l_api_name	 CONSTANT VARCHAR2(30) := 'lock_cond_lines';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_cnlv_rec      cnlv_rec_type := p_cnlv_rec;
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
	okc_conditions_pvt.lock_cond_lines(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_cnlv_rec      => l_cnlv_rec);

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
  end lock_cond_lines;

  PROCEDURE lock_cond_lines(p_api_version	    IN  NUMBER,
    				p_init_msg_list     IN  VARCHAR2 ,
    				x_return_status     OUT NOCOPY VARCHAR2,
    				x_msg_count         OUT NOCOPY NUMBER,
    				x_msg_data          OUT NOCOPY VARCHAR2,
    				p_cnlv_tbl	    IN  cnlv_tbl_type) IS
        l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i			NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cnlv_tbl.COUNT > 0 THEN
      i := p_cnlv_tbl.FIRST;
      LOOP
        lock_cond_lines(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cnlv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cnlv_tbl.LAST);
        i := p_cnlv_tbl.NEXT(i);
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
  End lock_cond_lines;

  PROCEDURE update_cond_lines(p_api_version	    IN NUMBER,
    				  p_init_msg_list   IN VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_cnlv_rec        IN cnlv_rec_type,
    				  x_cnlv_rec        OUT NOCOPY cnlv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'update_cond_lines';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_cnlv_rec      cnlv_rec_type := p_cnlv_rec;
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
    	g_cnlv_rec := l_cnlv_rec;

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
	l_cnlv_rec := migrate_cnlv(l_cnlv_rec, g_cnlv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.update_cond_lines(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_cnlv_rec      => l_cnlv_rec,
    				    	  x_cnlv_rec      => x_cnlv_rec);

	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_cnlv_rec := x_cnlv_rec;

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
  END update_cond_lines;

  PROCEDURE update_cond_lines(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_cnlv_tbl	    IN  cnlv_tbl_type,
    				  x_cnlv_tbl        OUT NOCOPY cnlv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_cnlv_tbl.COUNT > 0 THEN
      i := p_cnlv_tbl.FIRST;
      LOOP
        update_cond_lines(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cnlv_tbl(i),
	    x_cnlv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cnlv_tbl.LAST);
        i := p_cnlv_tbl.NEXT(i);
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
  END update_cond_lines;

  PROCEDURE delete_cond_lines(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_cnlv_rec	    IN  cnlv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_cond_lines';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_cnlv_rec      cnlv_rec_type := p_cnlv_rec;
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
    	g_cnlv_rec := l_cnlv_rec;

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
	l_cnlv_rec := migrate_cnlv(l_cnlv_rec, g_cnlv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.delete_cond_lines(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_cnlv_rec      => l_cnlv_rec);
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
  END delete_cond_lines;

  PROCEDURE delete_cond_lines(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
     				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_cnlv_tbl	    IN  cnlv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_cnlv_tbl.COUNT > 0 THEN
       i := p_cnlv_tbl.FIRST;
      LOOP
        delete_cond_lines(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cnlv_tbl(i));
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
       		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;
        EXIT WHEN (i = p_cnlv_tbl.LAST);
        i := p_cnlv_tbl.NEXT(i);
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
  END delete_cond_lines;

  PROCEDURE validate_cond_lines(p_api_version	IN  NUMBER,
    			    p_init_msg_list     IN  VARCHAR2 ,
    				    x_return_status     OUT NOCOPY VARCHAR2,
    				    x_msg_count         OUT NOCOPY NUMBER,
    				    x_msg_data          OUT NOCOPY VARCHAR2,
   				    p_cnlv_rec		IN  cnlv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'validate_cond_lines';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_cnlv_rec      cnlv_rec_type := p_cnlv_rec;
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
    	g_cnlv_rec := l_cnlv_rec;

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
	l_cnlv_rec := migrate_cnlv(l_cnlv_rec, g_cnlv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.validate_cond_lines(p_api_version   => p_api_version,
    			   		    p_init_msg_list => p_init_msg_list,
    				    	    x_return_status => x_return_status,
    				    	    x_msg_count     => x_msg_count,
    				    	    x_msg_data      => x_msg_data,
    				    	    p_cnlv_rec      => l_cnlv_rec);

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
  END validate_cond_lines;

  PROCEDURE validate_cond_lines(p_api_version	IN NUMBER,
    				    p_init_msg_list     IN VARCHAR2 ,
    				    x_return_status     OUT NOCOPY VARCHAR2,
    				    x_msg_count         OUT NOCOPY NUMBER,
    				    x_msg_data          OUT NOCOPY VARCHAR2,
    				    p_cnlv_tbl		IN cnlv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_cnlv_tbl.COUNT > 0 THEN
      i := p_cnlv_tbl.FIRST;
      LOOP
        validate_cond_lines(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cnlv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cnlv_tbl.LAST);
        i := p_cnlv_tbl.NEXT(i);
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
  END validate_cond_lines;

  --Procedures for condition occurs

  PROCEDURE create_cond_occurs(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_coev_rec        IN  coev_rec_type,
    				  x_coev_rec        OUT NOCOPY coev_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_cond_occurs';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_coev_rec      coev_rec_type := p_coev_rec;
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
    	g_coev_rec := l_coev_rec;

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
	l_coev_rec := migrate_coev(l_coev_rec, g_coev_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.create_cond_occurs(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_coev_rec      => l_coev_rec,
    				    	  x_coev_rec      => x_coev_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_coev_rec := x_coev_rec;

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
  end create_cond_occurs;

  PROCEDURE create_cond_occurs(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_coev_tbl	    IN  coev_tbl_type,
    				  x_coev_tbl        OUT NOCOPY coev_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_coev_tbl.COUNT > 0 THEN
      i := p_coev_tbl.FIRST;
      LOOP
        create_cond_occurs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_coev_tbl(i),
	    x_coev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_coev_tbl.LAST);
        i := p_coev_tbl.NEXT(i);
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
  END create_cond_occurs;


  PROCEDURE delete_cond_occurs(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_coev_rec	    IN  coev_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_cond_occurs';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_coev_rec      coev_rec_type := p_coev_rec;
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
    	g_coev_rec := l_coev_rec;

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
	l_coev_rec := migrate_coev(l_coev_rec, g_coev_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.delete_cond_occurs(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_coev_rec      => l_coev_rec);
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
  END delete_cond_occurs;

  PROCEDURE delete_cond_occurs(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
     				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_coev_tbl	    IN  coev_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_coev_tbl.COUNT > 0 THEN
       i := p_coev_tbl.FIRST;
      LOOP
        delete_cond_occurs(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_coev_tbl(i));
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
       		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;
        EXIT WHEN (i = p_coev_tbl.LAST);
        i := p_coev_tbl.NEXT(i);
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
  END delete_cond_occurs;

  PROCEDURE validate_cond_occurs(p_api_version	IN  NUMBER,
    				 p_init_msg_list     IN  VARCHAR2 ,
    		        	    x_return_status     OUT NOCOPY VARCHAR2,
    				    x_msg_count         OUT NOCOPY NUMBER,
    				    x_msg_data          OUT NOCOPY VARCHAR2,
   				    p_coev_rec		IN  coev_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'validate_cond_occurs';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_coev_rec      coev_rec_type := p_coev_rec;
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
    	g_coev_rec := l_coev_rec;

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
	l_coev_rec := migrate_coev(l_coev_rec, g_coev_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.validate_cond_occurs(p_api_version   => p_api_version,
    			   		    p_init_msg_list => p_init_msg_list,
    				    	    x_return_status => x_return_status,
    				    	    x_msg_count     => x_msg_count,
    				    	    x_msg_data      => x_msg_data,
    				    	    p_coev_rec      => l_coev_rec);

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
  END validate_cond_occurs;

  PROCEDURE validate_cond_occurs(p_api_version	IN NUMBER,
    				    p_init_msg_list     IN VARCHAR2 ,
    				    x_return_status     OUT NOCOPY VARCHAR2,
    				    x_msg_count         OUT NOCOPY NUMBER,
    				    x_msg_data          OUT NOCOPY VARCHAR2,
    				    p_coev_tbl		IN coev_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_coev_tbl.COUNT > 0 THEN
      i := p_coev_tbl.FIRST;
      LOOP
        validate_cond_occurs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_coev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_coev_tbl.LAST);
        i := p_coev_tbl.NEXT(i);
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
  END validate_cond_occurs;

  --Procedures for action attribute values

  PROCEDURE create_act_att_vals(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_aavv_rec        IN  aavv_rec_type,
    				  x_aavv_rec        OUT NOCOPY aavv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_act_att_vals';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aavv_rec      aavv_rec_type := p_aavv_rec;
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
    	g_aavv_rec := l_aavv_rec;

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
	l_aavv_rec := migrate_aavv(l_aavv_rec, g_aavv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.create_act_att_vals(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_aavv_rec      => l_aavv_rec,
    				    	  x_aavv_rec      => x_aavv_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_aavv_rec := x_aavv_rec;

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
  end create_act_att_vals;

  PROCEDURE create_act_att_vals(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_aavv_tbl	    IN  aavv_tbl_type,
    				  x_aavv_tbl        OUT NOCOPY aavv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_aavv_tbl.COUNT > 0 THEN
      i := p_aavv_tbl.FIRST;
      LOOP
        create_act_att_vals(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aavv_tbl(i),
	    x_aavv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aavv_tbl.LAST);
        i := p_aavv_tbl.NEXT(i);
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
  END create_act_att_vals;


  PROCEDURE delete_act_att_vals(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_aavv_rec	    IN  aavv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_act_att_vals';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aavv_rec      aavv_rec_type := p_aavv_rec;
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
    	g_aavv_rec := l_aavv_rec;

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
	l_aavv_rec := migrate_aavv(l_aavv_rec, g_aavv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.delete_act_att_vals(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_aavv_rec      => l_aavv_rec);
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
  END delete_act_att_vals;

  PROCEDURE delete_act_att_vals(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
     				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_aavv_tbl	    IN  aavv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_aavv_tbl.COUNT > 0 THEN
       i := p_aavv_tbl.FIRST;
      LOOP
        delete_act_att_vals(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aavv_tbl(i));
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
       		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;
        EXIT WHEN (i = p_aavv_tbl.LAST);
        i := p_aavv_tbl.NEXT(i);
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
  END delete_act_att_vals;

  PROCEDURE validate_act_att_vals(p_api_version	IN  NUMBER,
    				 p_init_msg_list     IN  VARCHAR2 ,
    		        	    x_return_status     OUT NOCOPY VARCHAR2,
    				    x_msg_count         OUT NOCOPY NUMBER,
    				    x_msg_data          OUT NOCOPY VARCHAR2,
   				    p_aavv_rec		IN  aavv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'validate_act_att_vals';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aavv_rec      aavv_rec_type := p_aavv_rec;
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
    	g_aavv_rec := l_aavv_rec;

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
	l_aavv_rec := migrate_aavv(l_aavv_rec, g_aavv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.validate_act_att_vals(p_api_version   => p_api_version,
    			   		    p_init_msg_list => p_init_msg_list,
    				    	    x_return_status => x_return_status,
    				    	    x_msg_count     => x_msg_count,
    				    	    x_msg_data      => x_msg_data,
    				    	    p_aavv_rec      => l_aavv_rec);

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
  END validate_act_att_vals;

  PROCEDURE validate_act_att_vals(p_api_version	IN NUMBER,
    				    p_init_msg_list     IN VARCHAR2 ,
    				    x_return_status     OUT NOCOPY VARCHAR2,
    				    x_msg_count         OUT NOCOPY NUMBER,
    				    x_msg_data          OUT NOCOPY VARCHAR2,
    				    p_aavv_tbl		IN aavv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_aavv_tbl.COUNT > 0 THEN
      i := p_aavv_tbl.FIRST;
      LOOP
        validate_act_att_vals(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aavv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aavv_tbl.LAST);
        i := p_aavv_tbl.NEXT(i);
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
  END validate_act_att_vals;

  --Procedures for Action Attribute Lookups

  PROCEDURE create_act_att_lkps(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_aalv_rec        IN  aalv_rec_type,
    				  x_aalv_rec        OUT NOCOPY aalv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_act_att_lkps';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aalv_rec      aalv_rec_type := p_aalv_rec;
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
    	g_aalv_rec := l_aalv_rec;

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
	l_aalv_rec := migrate_aalv(l_aalv_rec, g_aalv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.create_act_att_lkps(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_aalv_rec      => l_aalv_rec,
    				    	  x_aalv_rec      => x_aalv_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_aalv_rec := x_aalv_rec;

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
  end create_act_att_lkps;

  PROCEDURE create_act_att_lkps(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_aalv_tbl	    IN  aalv_tbl_type,
    				  x_aalv_tbl        OUT NOCOPY aalv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_aalv_tbl.COUNT > 0 THEN
      i := p_aalv_tbl.FIRST;
      LOOP
        create_act_att_lkps(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aalv_tbl(i),
	    x_aalv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aalv_tbl.LAST);
        i := p_aalv_tbl.NEXT(i);
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
  END create_act_att_lkps;

  PROCEDURE lock_act_att_lkps(p_api_version	    IN  NUMBER,
    				p_init_msg_list     IN  VARCHAR2 ,
    				x_return_status     OUT NOCOPY VARCHAR2,
    				x_msg_count         OUT NOCOPY NUMBER,
    				x_msg_data          OUT NOCOPY VARCHAR2,
    				p_aalv_rec	    IN  aalv_rec_type) IS
  	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_act_att_lkps';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aalv_rec      aalv_rec_type := p_aalv_rec;
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
	okc_conditions_pvt.lock_act_att_lkps(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_aalv_rec      => l_aalv_rec);

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
  end lock_act_att_lkps;

  PROCEDURE lock_act_att_lkps(p_api_version	    IN  NUMBER,
    				p_init_msg_list     IN  VARCHAR2 ,
    				x_return_status     OUT NOCOPY VARCHAR2,
    				x_msg_count         OUT NOCOPY NUMBER,
    				x_msg_data          OUT NOCOPY VARCHAR2,
    				p_aalv_tbl	    IN  aalv_tbl_type) IS
        l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i			NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_aalv_tbl.COUNT > 0 THEN
      i := p_aalv_tbl.FIRST;
      LOOP
        lock_act_att_lkps(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aalv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aalv_tbl.LAST);
        i := p_aalv_tbl.NEXT(i);
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
  End lock_act_att_lkps;

  PROCEDURE update_act_att_lkps(p_api_version	    IN NUMBER,
    				  p_init_msg_list   IN VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_aalv_rec        IN aalv_rec_type,
    				  x_aalv_rec        OUT NOCOPY aalv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'update_act_att_lkps';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aalv_rec      aalv_rec_type := p_aalv_rec;
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
    	g_aalv_rec := l_aalv_rec;

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
	l_aalv_rec := migrate_aalv(l_aalv_rec, g_aalv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.update_act_att_lkps(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_aalv_rec      => l_aalv_rec,
    				    	  x_aalv_rec      => x_aalv_rec);

	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_aalv_rec := x_aalv_rec;

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
  END update_act_att_lkps;

  PROCEDURE update_act_att_lkps(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_aalv_tbl	    IN  aalv_tbl_type,
    				  x_aalv_tbl        OUT NOCOPY aalv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_aalv_tbl.COUNT > 0 THEN
      i := p_aalv_tbl.FIRST;
      LOOP
        update_act_att_lkps(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aalv_tbl(i),
	    x_aalv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aalv_tbl.LAST);
        i := p_aalv_tbl.NEXT(i);
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
  END update_act_att_lkps;

  PROCEDURE delete_act_att_lkps(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_aalv_rec	    IN  aalv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_act_att_lkps';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aalv_rec      aalv_rec_type := p_aalv_rec;
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
    	g_aalv_rec := l_aalv_rec;

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
	l_aalv_rec := migrate_aalv(l_aalv_rec, g_aalv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.delete_act_att_lkps(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_aalv_rec      => l_aalv_rec);
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
  END delete_act_att_lkps;

  PROCEDURE delete_act_att_lkps(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
     				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_aalv_tbl	    IN  aalv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_aalv_tbl.COUNT > 0 THEN
       i := p_aalv_tbl.FIRST;
      LOOP
        delete_act_att_lkps(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aalv_tbl(i));
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
       		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;
        EXIT WHEN (i = p_aalv_tbl.LAST);
        i := p_aalv_tbl.NEXT(i);
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
  END delete_act_att_lkps;

  PROCEDURE validate_act_att_lkps(p_api_version	IN  NUMBER,
    			    p_init_msg_list     IN  VARCHAR2 ,
    				    x_return_status     OUT NOCOPY VARCHAR2,
    				    x_msg_count         OUT NOCOPY NUMBER,
    				    x_msg_data          OUT NOCOPY VARCHAR2,
   				    p_aalv_rec		IN  aalv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'validate_act_att_lkps';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_aalv_rec      aalv_rec_type := p_aalv_rec;
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
    	g_aalv_rec := l_aalv_rec;

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
	l_aalv_rec := migrate_aalv(l_aalv_rec, g_aalv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.validate_act_att_lkps(p_api_version   => p_api_version,
    			   		    p_init_msg_list => p_init_msg_list,
    				    	    x_return_status => x_return_status,
    				    	    x_msg_count     => x_msg_count,
    				    	    x_msg_data      => x_msg_data,
    				    	    p_aalv_rec      => l_aalv_rec);

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
  END validate_act_att_lkps;

  PROCEDURE validate_act_att_lkps(p_api_version	IN NUMBER,
    				    p_init_msg_list     IN VARCHAR2 ,
    				    x_return_status     OUT NOCOPY VARCHAR2,
    				    x_msg_count         OUT NOCOPY NUMBER,
    				    x_msg_data          OUT NOCOPY VARCHAR2,
    				    p_aalv_tbl		IN aalv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_aalv_tbl.COUNT > 0 THEN
      i := p_aalv_tbl.FIRST;
      LOOP
        validate_act_att_lkps(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_aalv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_aalv_tbl.LAST);
        i := p_aalv_tbl.NEXT(i);
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
  END validate_act_att_lkps;

  --Procedures for Function Expression Parameters

  PROCEDURE create_func_exprs(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_fepv_rec        IN  fepv_rec_type,
    				  x_fepv_rec        OUT NOCOPY fepv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_func_exprs';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_fepv_rec      fepv_rec_type := p_fepv_rec;
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
    	g_fepv_rec := l_fepv_rec;

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
	l_fepv_rec := migrate_fepv(l_fepv_rec, g_fepv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.create_func_exprs(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_fepv_rec      => l_fepv_rec,
    				    	  x_fepv_rec      => x_fepv_rec);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_fepv_rec := x_fepv_rec;

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
  end create_func_exprs;

  PROCEDURE create_func_exprs(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_fepv_tbl	    IN  fepv_tbl_type,
    				  x_fepv_tbl        OUT NOCOPY fepv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_fepv_tbl.COUNT > 0 THEN
      i := p_fepv_tbl.FIRST;
      LOOP
        create_func_exprs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_fepv_tbl(i),
	    x_fepv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_fepv_tbl.LAST);
        i := p_fepv_tbl.NEXT(i);
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
  END create_func_exprs;

  PROCEDURE lock_func_exprs(p_api_version	    IN  NUMBER,
    				p_init_msg_list     IN  VARCHAR2 ,
    				x_return_status     OUT NOCOPY VARCHAR2,
    				x_msg_count         OUT NOCOPY NUMBER,
    				x_msg_data          OUT NOCOPY VARCHAR2,
    				p_fepv_rec	    IN  fepv_rec_type) IS
  	 l_api_name	 CONSTANT VARCHAR2(30) := 'lock_func_exprs';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_fepv_rec      fepv_rec_type := p_fepv_rec;
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
	okc_conditions_pvt.lock_func_exprs(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_fepv_rec      => l_fepv_rec);

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
  end lock_func_exprs;

  PROCEDURE lock_func_exprs(p_api_version	    IN  NUMBER,
    				p_init_msg_list     IN  VARCHAR2 ,
    				x_return_status     OUT NOCOPY VARCHAR2,
    				x_msg_count         OUT NOCOPY NUMBER,
    				x_msg_data          OUT NOCOPY VARCHAR2,
    				p_fepv_tbl	    IN  fepv_tbl_type) IS
        l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i			NUMBER := 0;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_fepv_tbl.COUNT > 0 THEN
      i := p_fepv_tbl.FIRST;
      LOOP
        lock_func_exprs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_fepv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_fepv_tbl.LAST);
        i := p_fepv_tbl.NEXT(i);
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
  End lock_func_exprs;

  PROCEDURE update_func_exprs(p_api_version	    IN NUMBER,
    				  p_init_msg_list   IN VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_fepv_rec        IN fepv_rec_type,
    				  x_fepv_rec        OUT NOCOPY fepv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'update_func_exprs';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_fepv_rec      fepv_rec_type := p_fepv_rec;
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
    	g_fepv_rec := l_fepv_rec;

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
	l_fepv_rec := migrate_fepv(l_fepv_rec, g_fepv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.update_func_exprs(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_fepv_rec      => l_fepv_rec,
    				    	  x_fepv_rec      => x_fepv_rec);

	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--USER HOOK CALL FOR AFTER, STARTS
	g_fepv_rec := x_fepv_rec;

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
  END update_func_exprs;

  PROCEDURE update_func_exprs(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_fepv_tbl	    IN  fepv_tbl_type,
    				  x_fepv_tbl        OUT NOCOPY fepv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_fepv_tbl.COUNT > 0 THEN
      i := p_fepv_tbl.FIRST;
      LOOP
        update_func_exprs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_fepv_tbl(i),
	    x_fepv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_fepv_tbl.LAST);
        i := p_fepv_tbl.NEXT(i);
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
  END update_func_exprs;

  PROCEDURE delete_func_exprs(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
    				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_fepv_rec	    IN  fepv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_func_exprs';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_fepv_rec      fepv_rec_type := p_fepv_rec;
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
    	g_fepv_rec := l_fepv_rec;

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
	l_fepv_rec := migrate_fepv(l_fepv_rec, g_fepv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.delete_func_exprs(p_api_version   => p_api_version,
    			   		  p_init_msg_list => p_init_msg_list,
    				    	  x_return_status => x_return_status,
    				    	  x_msg_count     => x_msg_count,
    				    	  x_msg_data      => x_msg_data,
    				    	  p_fepv_rec      => l_fepv_rec);
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
  END delete_func_exprs;

  PROCEDURE delete_func_exprs(p_api_version	    IN  NUMBER,
    				  p_init_msg_list   IN  VARCHAR2 ,
    				  x_return_status   OUT NOCOPY VARCHAR2,
    				  x_msg_count       OUT NOCOPY NUMBER,
     				  x_msg_data        OUT NOCOPY VARCHAR2,
    				  p_fepv_tbl	    IN  fepv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_fepv_tbl.COUNT > 0 THEN
       i := p_fepv_tbl.FIRST;
      LOOP
        delete_func_exprs(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_fepv_tbl(i));
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
       		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;
        EXIT WHEN (i = p_fepv_tbl.LAST);
        i := p_fepv_tbl.NEXT(i);
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
  END delete_func_exprs;

  PROCEDURE validate_func_exprs(p_api_version	IN  NUMBER,
    			    p_init_msg_list     IN  VARCHAR2 ,
    				    x_return_status     OUT NOCOPY VARCHAR2,
    				    x_msg_count         OUT NOCOPY NUMBER,
    				    x_msg_data          OUT NOCOPY VARCHAR2,
   				    p_fepv_rec		IN  fepv_rec_type) IS

	 l_api_name	 CONSTANT VARCHAR2(30) := 'validate_func_exprs';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_fepv_rec      fepv_rec_type := p_fepv_rec;
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
    	g_fepv_rec := l_fepv_rec;

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
	l_fepv_rec := migrate_fepv(l_fepv_rec, g_fepv_rec);

    	-- Call to procedure of complex API
	okc_conditions_pvt.validate_func_exprs(p_api_version   => p_api_version,
    			   		    p_init_msg_list => p_init_msg_list,
    				    	    x_return_status => x_return_status,
    				    	    x_msg_count     => x_msg_count,
    				    	    x_msg_data      => x_msg_data,
    				    	    p_fepv_rec      => l_fepv_rec);

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
  END validate_func_exprs;

  PROCEDURE validate_func_exprs(p_api_version	IN NUMBER,
    				    p_init_msg_list     IN VARCHAR2 ,
    				    x_return_status     OUT NOCOPY VARCHAR2,
    				    x_msg_count         OUT NOCOPY NUMBER,
    				    x_msg_data          OUT NOCOPY VARCHAR2,
    				    p_fepv_tbl		IN fepv_tbl_type) IS

	l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	i		 NUMBER := 0;
  BEGIN
    --Initialize the return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_fepv_tbl.COUNT > 0 THEN
      i := p_fepv_tbl.FIRST;
      LOOP
        validate_func_exprs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_fepv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_fepv_tbl.LAST);
        i := p_fepv_tbl.NEXT(i);
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
  END validate_func_exprs;

  PROCEDURE valid_condition_lines(
	p_cnh_id            IN okc_condition_headers_b.id%TYPE,
	x_string            OUT NOCOPY VARCHAR2,
	x_valid_flag        OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- Check the condition lines, call complex api
    okc_conditions_pvt.valid_condition_lines(
	p_cnh_id          => p_cnh_id,
	x_string          => x_string,
	x_valid_flag      => x_valid_flag);

  END valid_condition_lines;

END okc_conditions_pub;

/
