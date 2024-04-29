--------------------------------------------------------
--  DDL for Package Body OKC_SUBCLASS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SUBCLASS_PUB" AS
/* $Header: OKCPSCSB.pls 120.0 2005/05/25 18:21:04 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  PROCEDURE add_language IS
  BEGIN
    okc_subclass_pvt.add_language;
  END;
  FUNCTION migrate_scsv(p_scsv_rec1 IN scsv_rec_type,
                        p_scsv_rec2 IN scsv_rec_type)
    RETURN scsv_rec_type IS
    l_scsv_rec scsv_rec_type;
  BEGIN
    l_scsv_rec.code                  := p_scsv_rec1.code;
    l_scsv_rec.object_version_number := p_scsv_rec1.object_version_number;
    l_scsv_rec.sfwt_flag             := p_scsv_rec1.sfwt_flag;
    l_scsv_rec.cls_code              := p_scsv_rec1.cls_code;
    l_scsv_rec.created_by            := p_scsv_rec1.created_by;
    l_scsv_rec.creation_date         := p_scsv_rec1.creation_date;
    l_scsv_rec.last_updated_by       := p_scsv_rec1.last_updated_by;
    l_scsv_rec.last_update_date      := p_scsv_rec1.last_update_date;
    l_scsv_rec.last_update_login     := p_scsv_rec1.last_update_login;
    l_scsv_rec.meaning               := p_scsv_rec2.meaning;
    l_scsv_rec.description           := p_scsv_rec2.description;
    l_scsv_rec.start_date            := p_scsv_rec2.start_date;
    l_scsv_rec.end_date              := p_scsv_rec2.end_date;
    l_scsv_rec.create_opp_yn         := p_scsv_rec2.create_opp_yn;
    l_scsv_rec.access_level          := p_scsv_rec2.access_level;
    RETURN (l_scsv_rec);
  END migrate_scsv;

  FUNCTION migrate_srev(p_srev_rec1 IN srev_rec_type,
                        p_srev_rec2 IN srev_rec_type)
    RETURN srev_rec_type IS
    l_srev_rec srev_rec_type;
  BEGIN
    l_srev_rec.id                    := p_srev_rec1.id;
    l_srev_rec.object_version_number := p_srev_rec1.object_version_number;
    l_srev_rec.rle_code              := p_srev_rec1.rle_code;
    l_srev_rec.scs_code              := p_srev_rec1.scs_code;
    l_srev_rec.created_by            := p_srev_rec1.created_by;
    l_srev_rec.creation_date         := p_srev_rec1.creation_date;
    l_srev_rec.last_updated_by       := p_srev_rec1.last_updated_by;
    l_srev_rec.last_update_date      := p_srev_rec1.last_update_date;
    l_srev_rec.last_update_login     := p_srev_rec1.last_update_login;
    l_srev_rec.start_date            := p_srev_rec2.start_date;
    l_srev_rec.end_date              := p_srev_rec2.end_date;
    l_srev_rec.access_level          := p_srev_rec2.access_level;
    RETURN (l_srev_rec);
  END migrate_srev;

  FUNCTION migrate_srdv(p_srdv_rec1 IN srdv_rec_type,
                        p_srdv_rec2 IN srdv_rec_type)
    RETURN srdv_rec_type IS
    l_srdv_rec srdv_rec_type;
  BEGIN
    l_srdv_rec.id                    := p_srdv_rec1.id;
    l_srdv_rec.object_version_number := p_srdv_rec1.object_version_number;
    l_srdv_rec.rgd_code              := p_srdv_rec1.rgd_code;
    l_srdv_rec.scs_code              := p_srdv_rec1.scs_code;
    l_srdv_rec.created_by            := p_srdv_rec1.created_by;
    l_srdv_rec.creation_date         := p_srdv_rec1.creation_date;
    l_srdv_rec.last_updated_by       := p_srdv_rec1.last_updated_by;
    l_srdv_rec.last_update_date      := p_srdv_rec1.last_update_date;
    l_srdv_rec.last_update_login     := p_srdv_rec1.last_update_login;
    l_srdv_rec.start_date            := p_srdv_rec2.start_date;
    l_srdv_rec.end_date              := p_srdv_rec2.end_date;
    l_srdv_rec.access_level          := p_srdv_rec2.access_level;
    RETURN (l_srdv_rec);
  END migrate_srdv;

  FUNCTION migrate_rrdv(p_rrdv_rec1 IN rrdv_rec_type,
                        p_rrdv_rec2 IN rrdv_rec_type)
    RETURN rrdv_rec_type IS
    l_rrdv_rec rrdv_rec_type;
  BEGIN
    l_rrdv_rec.id                    := p_rrdv_rec1.id;
    l_rrdv_rec.object_version_number := p_rrdv_rec1.object_version_number;
    l_rrdv_rec.srd_id                := p_rrdv_rec1.srd_id;
    l_rrdv_rec.sre_id                := p_rrdv_rec1.sre_id;
    l_rrdv_rec.created_by            := p_rrdv_rec1.created_by;
    l_rrdv_rec.creation_date         := p_rrdv_rec1.creation_date;
    l_rrdv_rec.last_updated_by       := p_rrdv_rec1.last_updated_by;
    l_rrdv_rec.last_update_date      := p_rrdv_rec1.last_update_date;
    l_rrdv_rec.last_update_login     := p_rrdv_rec1.last_update_login;
    l_rrdv_rec.optional_yn           := p_rrdv_rec2.optional_yn;
    l_rrdv_rec.subject_object_flag   := p_rrdv_rec2.subject_object_flag;
    l_rrdv_rec.attribute_category    := p_rrdv_rec2.attribute_category;
    l_rrdv_rec.attribute1            := p_rrdv_rec2.attribute1;
    l_rrdv_rec.attribute2            := p_rrdv_rec2.attribute2;
    l_rrdv_rec.attribute3            := p_rrdv_rec2.attribute3;
    l_rrdv_rec.attribute4            := p_rrdv_rec2.attribute4;
    l_rrdv_rec.attribute5            := p_rrdv_rec2.attribute5;
    l_rrdv_rec.attribute6            := p_rrdv_rec2.attribute6;
    l_rrdv_rec.attribute7            := p_rrdv_rec2.attribute7;
    l_rrdv_rec.attribute8            := p_rrdv_rec2.attribute8;
    l_rrdv_rec.attribute9            := p_rrdv_rec2.attribute9;
    l_rrdv_rec.attribute10           := p_rrdv_rec2.attribute10;
    l_rrdv_rec.attribute11           := p_rrdv_rec2.attribute11;
    l_rrdv_rec.attribute12           := p_rrdv_rec2.attribute12;
    l_rrdv_rec.attribute13           := p_rrdv_rec2.attribute13;
    l_rrdv_rec.attribute14           := p_rrdv_rec2.attribute14;
    l_rrdv_rec.attribute15           := p_rrdv_rec2.attribute15;
    l_rrdv_rec.access_level          := p_rrdv_rec2.access_level;
    RETURN (l_rrdv_rec);
  END migrate_rrdv;

  FUNCTION migrate_stlv(p_stlv_rec1 IN stlv_rec_type,
                        p_stlv_rec2 IN stlv_rec_type)
    RETURN stlv_rec_type IS
    l_stlv_rec stlv_rec_type;
  BEGIN
    l_stlv_rec.lse_id                := p_stlv_rec1.lse_id;
    l_stlv_rec.scs_code              := p_stlv_rec1.scs_code;
    l_stlv_rec.object_version_number := p_stlv_rec1.object_version_number;
    l_stlv_rec.created_by            := p_stlv_rec1.created_by;
    l_stlv_rec.creation_date         := p_stlv_rec1.creation_date;
    l_stlv_rec.last_updated_by       := p_stlv_rec1.last_updated_by;
    l_stlv_rec.last_update_date      := p_stlv_rec1.last_update_date;
    l_stlv_rec.last_update_login     := p_stlv_rec1.last_update_login;
    l_stlv_rec.start_date            := p_stlv_rec2.start_date;
    l_stlv_rec.end_date              := p_stlv_rec2.end_date;
    l_stlv_rec.access_level          := p_stlv_rec2.access_level;
    RETURN (l_stlv_rec);
  END migrate_stlv;

  FUNCTION migrate_lsrv(p_lsrv_rec1 IN lsrv_rec_type,
                        p_lsrv_rec2 IN lsrv_rec_type)
    RETURN lsrv_rec_type IS
    l_lsrv_rec lsrv_rec_type;
  BEGIN
    l_lsrv_rec.lse_id                := p_lsrv_rec1.lse_id;
    l_lsrv_rec.sre_id                := p_lsrv_rec1.sre_id;
    l_lsrv_rec.object_version_number := p_lsrv_rec1.object_version_number;
    l_lsrv_rec.created_by            := p_lsrv_rec1.created_by;
    l_lsrv_rec.creation_date         := p_lsrv_rec1.creation_date;
    l_lsrv_rec.last_updated_by       := p_lsrv_rec1.last_updated_by;
    l_lsrv_rec.last_update_date      := p_lsrv_rec1.last_update_date;
    l_lsrv_rec.last_update_login     := p_lsrv_rec1.last_update_login;
    l_lsrv_rec.access_level          := p_lsrv_rec1.access_level;
    RETURN (l_lsrv_rec);
  END migrate_lsrv;

  FUNCTION migrate_lrgv(p_lrgv_rec1 IN lrgv_rec_type,
                        p_lrgv_rec2 IN lrgv_rec_type)
    RETURN lrgv_rec_type IS
    l_lrgv_rec lrgv_rec_type;
  BEGIN
    l_lrgv_rec.lse_id                := p_lrgv_rec1.lse_id;
    l_lrgv_rec.srd_id                := p_lrgv_rec1.srd_id;
    l_lrgv_rec.object_version_number := p_lrgv_rec1.object_version_number;
    l_lrgv_rec.created_by            := p_lrgv_rec1.created_by;
    l_lrgv_rec.creation_date         := p_lrgv_rec1.creation_date;
    l_lrgv_rec.last_updated_by       := p_lrgv_rec1.last_updated_by;
    l_lrgv_rec.last_update_date      := p_lrgv_rec1.last_update_date;
    l_lrgv_rec.last_update_login     := p_lrgv_rec1.last_update_login;
    l_lrgv_rec.access_level          := p_lrgv_rec1.access_level;
    RETURN (l_lrgv_rec);
  END migrate_lrgv;

  FUNCTION migrate_srav(p_srav_rec1 IN srav_rec_type,
                        p_srav_rec2 IN srav_rec_type)
    RETURN srav_rec_type IS
    l_srav_rec srav_rec_type;
  BEGIN
    l_srav_rec.scs_code              := p_srav_rec1.scs_code;
    l_srav_rec.resp_id               := p_srav_rec1.resp_id;
    l_srav_rec.access_level          := p_srav_rec1.access_level;
    l_srav_rec.created_by            := p_srav_rec1.created_by;
    l_srav_rec.creation_date         := p_srav_rec1.creation_date;
    l_srav_rec.last_updated_by       := p_srav_rec1.last_updated_by;
    l_srav_rec.last_update_date      := p_srav_rec1.last_update_date;
    l_srav_rec.last_update_login     := p_srav_rec1.last_update_login;
    l_srav_rec.start_date            := p_srav_rec2.start_date;
    l_srav_rec.end_date              := p_srav_rec2.end_date;
    RETURN (l_srav_rec);
  END migrate_srav;

 PROCEDURE create_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type,
    x_scsv_rec                     OUT NOCOPY scsv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_subclass';
    l_return_status		   VARCHAR2(1);
    l_scsv_rec                     scsv_rec_type := p_scsv_rec;
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
    -- Call user hook for BEFORE
    g_scsv_rec := l_scsv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_scsv_rec := migrate_scsv(l_scsv_rec, g_scsv_rec);

    okc_subclass_pvt.create_subclass(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_scsv_rec,
                x_scsv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_scsv_rec := x_scsv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END create_subclass;

 PROCEDURE create_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type,
    x_scsv_tbl                     OUT NOCOPY scsv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_scsv_tbl.COUNT > 0 THEN
      i := p_scsv_tbl.FIRST;
      LOOP
        create_subclass(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_tbl(i),
                x_scsv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_scsv_tbl.LAST);
        i := p_scsv_tbl.NEXT(i);
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
 END create_subclass;


 PROCEDURE update_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type,
    x_scsv_rec                     OUT NOCOPY scsv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_subclass';
    l_return_status		   VARCHAR2(1);
    l_scsv_rec                     scsv_rec_type := p_scsv_rec;
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
    -- Call user hook for BEFORE
    g_scsv_rec := l_scsv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_scsv_rec := migrate_scsv(l_scsv_rec, g_scsv_rec);

    okc_subclass_pvt.update_subclass(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_scsv_rec,
                x_scsv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_scsv_rec := x_scsv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END update_subclass;


 PROCEDURE update_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type,
    x_scsv_tbl                     OUT NOCOPY scsv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_scsv_tbl.COUNT > 0 THEN
      i := p_scsv_tbl.FIRST;
      LOOP
        update_subclass(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_tbl(i),
                x_scsv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_scsv_tbl.LAST);
        i := p_scsv_tbl.NEXT(i);
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
 END update_subclass;

 PROCEDURE delete_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_subclass';
    l_return_status		   VARCHAR2(1);
    l_scsv_rec                     scsv_rec_type := p_scsv_rec;
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
    -- Call user hook for BEFORE
    g_scsv_rec := l_scsv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okc_subclass_pvt.delete_subclass(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END delete_subclass;

 PROCEDURE delete_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_scsv_tbl.COUNT > 0 THEN
      i := p_scsv_tbl.FIRST;
      LOOP
        delete_subclass(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_scsv_tbl.LAST);
        i := p_scsv_tbl.NEXT(i);
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
 END delete_subclass;

 PROCEDURE lock_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type) IS
 BEGIN
    okc_subclass_pvt.lock_subclass(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_rec);
 END lock_subclass;

 PROCEDURE lock_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type) IS
 BEGIN
    okc_subclass_pvt.lock_subclass(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_tbl);
 END lock_subclass;

 PROCEDURE validate_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type) IS
 BEGIN
    okc_subclass_pvt.validate_subclass(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_rec);
 END validate_subclass;

 PROCEDURE validate_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type) IS
 BEGIN
    okc_subclass_pvt.validate_subclass(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_tbl);
 END validate_subclass;

 PROCEDURE create_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type,
    x_srev_rec                     OUT NOCOPY srev_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_subclass_roles';
    l_return_status		   VARCHAR2(1);
    l_srev_rec                     srev_rec_type := p_srev_rec;
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
    -- Call user hook for BEFORE
    g_srev_rec := l_srev_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_srev_rec := migrate_srev(l_srev_rec, g_srev_rec);

    okc_subclass_pvt.create_subclass_roles(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_srev_rec,
                x_srev_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_srev_rec := x_srev_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END create_subclass_roles;

 PROCEDURE create_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type,
    x_srev_tbl                     OUT NOCOPY srev_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_srev_tbl.COUNT > 0 THEN
      i := p_srev_tbl.FIRST;
      LOOP
        create_subclass_roles(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_tbl(i),
                x_srev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_srev_tbl.LAST);
        i := p_srev_tbl.NEXT(i);
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
 END create_subclass_roles;

 PROCEDURE update_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type,
    x_srev_rec                     OUT NOCOPY srev_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_subclass_roles';
    l_return_status		   VARCHAR2(1);
    l_srev_rec                     srev_rec_type := p_srev_rec;
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
    -- Call user hook for BEFORE
    g_srev_rec := l_srev_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_srev_rec := migrate_srev(l_srev_rec, g_srev_rec);

    okc_subclass_pvt.update_subclass_roles(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_srev_rec,
                x_srev_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_srev_rec := x_srev_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END update_subclass_roles;

 PROCEDURE update_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type,
    x_srev_tbl                     OUT NOCOPY srev_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_srev_tbl.COUNT > 0 THEN
      i := p_srev_tbl.FIRST;
      LOOP
        update_subclass_roles(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_tbl(i),
                x_srev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_srev_tbl.LAST);
        i := p_srev_tbl.NEXT(i);
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
 END update_subclass_roles;

 PROCEDURE delete_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_subclass_roles';
    l_return_status		   VARCHAR2(1);
    l_srev_rec                     srev_rec_type := p_srev_rec;
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
    -- Call user hook for BEFORE
    g_srev_rec := l_srev_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okc_subclass_pvt.delete_subclass_roles(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END delete_subclass_roles;

 PROCEDURE delete_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_srev_tbl.COUNT > 0 THEN
      i := p_srev_tbl.FIRST;
      LOOP
        delete_subclass_roles(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_srev_tbl.LAST);
        i := p_srev_tbl.NEXT(i);
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
 END delete_subclass_roles;

 PROCEDURE lock_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type) IS
 BEGIN
    okc_subclass_pvt.lock_subclass_roles(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_rec);
 END lock_subclass_roles;

 PROCEDURE lock_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type) IS
 BEGIN
    okc_subclass_pvt.lock_subclass_roles(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_tbl);
 END lock_subclass_roles;

 PROCEDURE validate_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type) IS
 BEGIN
    okc_subclass_pvt.validate_subclass_roles(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_rec);
 END validate_subclass_roles;

 PROCEDURE validate_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type) IS
 BEGIN
    okc_subclass_pvt.validate_subclass_roles(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_tbl);
 END validate_subclass_roles;

 PROCEDURE create_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type,
    x_srdv_rec                     OUT NOCOPY srdv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_subclass_rg_defs';
    l_return_status		   VARCHAR2(1);
    l_srdv_rec                     srdv_rec_type := p_srdv_rec;
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
    -- Call user hook for BEFORE
    g_srdv_rec := l_srdv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_srdv_rec := migrate_srdv(l_srdv_rec, g_srdv_rec);

    okc_subclass_pvt.create_subclass_rg_defs(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_srdv_rec,
                x_srdv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_srdv_rec := x_srdv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END create_subclass_rg_defs;

 PROCEDURE create_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type,
    x_srdv_tbl                     OUT NOCOPY srdv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_srdv_tbl.COUNT > 0 THEN
      i := p_srdv_tbl.FIRST;
      LOOP
        create_subclass_rg_defs(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_tbl(i),
                x_srdv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_srdv_tbl.LAST);
        i := p_srdv_tbl.NEXT(i);
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
 END create_subclass_rg_defs;

 PROCEDURE update_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type,
    x_srdv_rec                     OUT NOCOPY srdv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_subclass_rg_defs';
    l_return_status		   VARCHAR2(1);
    l_srdv_rec                     srdv_rec_type := p_srdv_rec;
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
    -- Call user hook for BEFORE
    g_srdv_rec := l_srdv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_srdv_rec := migrate_srdv(l_srdv_rec, g_srdv_rec);

    okc_subclass_pvt.update_subclass_rg_defs(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_srdv_rec,
                x_srdv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_srdv_rec := x_srdv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END update_subclass_rg_defs;

 PROCEDURE update_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type,
    x_srdv_tbl                     OUT NOCOPY srdv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_srdv_tbl.COUNT > 0 THEN
      i := p_srdv_tbl.FIRST;
      LOOP
        update_subclass_rg_defs(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_tbl(i),
                x_srdv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_srdv_tbl.LAST);
        i := p_srdv_tbl.NEXT(i);
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
 END update_subclass_rg_defs;

 PROCEDURE delete_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_subclass_rg_defs';
    l_return_status		   VARCHAR2(1);
    l_srdv_rec                     srdv_rec_type := p_srdv_rec;
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
    -- Call user hook for BEFORE
    g_srdv_rec := l_srdv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okc_subclass_pvt.delete_subclass_rg_defs(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END delete_subclass_rg_defs;

 PROCEDURE delete_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_srdv_tbl.COUNT > 0 THEN
      i := p_srdv_tbl.FIRST;
      LOOP
        delete_subclass_rg_defs(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_srdv_tbl.LAST);
        i := p_srdv_tbl.NEXT(i);
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
 END delete_subclass_rg_defs;

 PROCEDURE lock_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type) IS
 BEGIN
    okc_subclass_pvt.lock_subclass_rg_defs(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_rec);
 END lock_subclass_rg_defs;

 PROCEDURE lock_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type) IS
 BEGIN
    okc_subclass_pvt.lock_subclass_rg_defs(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_tbl);
 END lock_subclass_rg_defs;

 PROCEDURE validate_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type) IS
 BEGIN
    okc_subclass_pvt.validate_subclass_rg_defs(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_rec);
 END validate_subclass_rg_defs;

 PROCEDURE validate_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type) IS
 BEGIN
    okc_subclass_pvt.validate_subclass_rg_defs(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_tbl);
 END validate_subclass_rg_defs;

 PROCEDURE create_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type,
    x_rrdv_rec                     OUT NOCOPY rrdv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_rg_role_defs';
    l_return_status		   VARCHAR2(1);
    l_rrdv_rec                     rrdv_rec_type := p_rrdv_rec;
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
    -- Call user hook for BEFORE
    g_rrdv_rec := l_rrdv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rrdv_rec := migrate_rrdv(l_rrdv_rec, g_rrdv_rec);

    okc_subclass_pvt.create_rg_role_defs(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_rrdv_rec,
                x_rrdv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_rrdv_rec := x_rrdv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END create_rg_role_defs;

 PROCEDURE create_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type,
    x_rrdv_tbl                     OUT NOCOPY rrdv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rrdv_tbl.COUNT > 0 THEN
      i := p_rrdv_tbl.FIRST;
      LOOP
        create_rg_role_defs(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_tbl(i),
                x_rrdv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rrdv_tbl.LAST);
        i := p_rrdv_tbl.NEXT(i);
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
 END create_rg_role_defs;

 PROCEDURE update_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type,
    x_rrdv_rec                     OUT NOCOPY rrdv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_rg_role_defs';
    l_return_status		   VARCHAR2(1);
    l_rrdv_rec                     rrdv_rec_type := p_rrdv_rec;
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
    -- Call user hook for BEFORE
    g_rrdv_rec := l_rrdv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rrdv_rec := migrate_rrdv(l_rrdv_rec, g_rrdv_rec);

    okc_subclass_pvt.update_rg_role_defs(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_rrdv_rec,
                x_rrdv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_rrdv_rec := x_rrdv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END update_rg_role_defs;

 PROCEDURE update_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type,
    x_rrdv_tbl                     OUT NOCOPY rrdv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rrdv_tbl.COUNT > 0 THEN
      i := p_rrdv_tbl.FIRST;
      LOOP
        update_rg_role_defs(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_tbl(i),
                x_rrdv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rrdv_tbl.LAST);
        i := p_rrdv_tbl.NEXT(i);
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
 END update_rg_role_defs;

 PROCEDURE delete_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_rg_role_defs';
    l_return_status		   VARCHAR2(1);
    l_rrdv_rec                     rrdv_rec_type := p_rrdv_rec;
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
    -- Call user hook for BEFORE
    g_rrdv_rec := l_rrdv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okc_subclass_pvt.delete_rg_role_defs(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END delete_rg_role_defs;

 PROCEDURE delete_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rrdv_tbl.COUNT > 0 THEN
      i := p_rrdv_tbl.FIRST;
      LOOP
        delete_rg_role_defs(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rrdv_tbl.LAST);
        i := p_rrdv_tbl.NEXT(i);
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
 END delete_rg_role_defs;

 PROCEDURE lock_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type) IS
 BEGIN
    okc_subclass_pvt.lock_rg_role_defs(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_rec);
 END lock_rg_role_defs;

 PROCEDURE lock_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type) IS
 BEGIN
    okc_subclass_pvt.lock_rg_role_defs(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_tbl);
 END lock_rg_role_defs;

 PROCEDURE validate_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type) IS
 BEGIN
    okc_subclass_pvt.validate_rg_role_defs(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_rec);
 END validate_rg_role_defs;

 PROCEDURE validate_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type) IS
 BEGIN
    okc_subclass_pvt.validate_rg_role_defs(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_tbl);
 END validate_rg_role_defs;

 PROCEDURE create_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type,
    x_stlv_rec                     OUT NOCOPY stlv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_subclass_top_line';
    l_return_status		   VARCHAR2(1);
    l_stlv_rec                     stlv_rec_type := p_stlv_rec;
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
    -- Call user hook for BEFORE
    g_stlv_rec := l_stlv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_stlv_rec := migrate_stlv(l_stlv_rec, g_stlv_rec);

    okc_subclass_pvt.create_subclass_top_line(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_stlv_rec,
                x_stlv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_stlv_rec := x_stlv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END create_subclass_top_line;

 PROCEDURE create_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type,
    x_stlv_tbl                     OUT NOCOPY stlv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_stlv_tbl.COUNT > 0 THEN
      i := p_stlv_tbl.FIRST;
      LOOP
        create_subclass_top_line(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_tbl(i),
                x_stlv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_stlv_tbl.LAST);
        i := p_stlv_tbl.NEXT(i);
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
 END create_subclass_top_line;

 PROCEDURE update_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type,
    x_stlv_rec                     OUT NOCOPY stlv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_subclass_top_line';
    l_return_status		   VARCHAR2(1);
    l_stlv_rec                     stlv_rec_type := p_stlv_rec;
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
    -- Call user hook for BEFORE
    g_stlv_rec := l_stlv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_stlv_rec := migrate_stlv(l_stlv_rec, g_stlv_rec);

    okc_subclass_pvt.update_subclass_top_line(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_stlv_rec,
                x_stlv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_stlv_rec := x_stlv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END update_subclass_top_line;

 PROCEDURE update_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type,
    x_stlv_tbl                     OUT NOCOPY stlv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_stlv_tbl.COUNT > 0 THEN
      i := p_stlv_tbl.FIRST;
      LOOP
        update_subclass_top_line(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_tbl(i),
                x_stlv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_stlv_tbl.LAST);
        i := p_stlv_tbl.NEXT(i);
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
 END update_subclass_top_line;

 PROCEDURE delete_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_subclass_top_line';
    l_return_status		   VARCHAR2(1);
    l_stlv_rec                     stlv_rec_type := p_stlv_rec;
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
    -- Call user hook for BEFORE
    g_stlv_rec := l_stlv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okc_subclass_pvt.delete_subclass_top_line(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END delete_subclass_top_line;

 PROCEDURE delete_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_stlv_tbl.COUNT > 0 THEN
      i := p_stlv_tbl.FIRST;
      LOOP
        delete_subclass_top_line(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_stlv_tbl.LAST);
        i := p_stlv_tbl.NEXT(i);
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
 END delete_subclass_top_line;

 PROCEDURE lock_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type) IS
 BEGIN
    okc_subclass_pvt.lock_subclass_top_line(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_rec);
 END lock_subclass_top_line;

 PROCEDURE lock_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type) IS
 BEGIN
    okc_subclass_pvt.lock_subclass_top_line(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_tbl);
 END lock_subclass_top_line;

 PROCEDURE validate_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type) IS
 BEGIN
    okc_subclass_pvt.validate_subclass_top_line(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_rec);
 END validate_subclass_top_line;

 PROCEDURE validate_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type) IS
 BEGIN
    okc_subclass_pvt.validate_subclass_top_line(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_tbl);
 END validate_subclass_top_line;

 PROCEDURE create_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type,
    x_lsrv_rec                     OUT NOCOPY lsrv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_line_style_roles';
    l_return_status		   VARCHAR2(1);
    l_lsrv_rec                     lsrv_rec_type := p_lsrv_rec;
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
    -- Call user hook for BEFORE
    g_lsrv_rec := l_lsrv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_lsrv_rec := migrate_lsrv(l_lsrv_rec, g_lsrv_rec);

    okc_subclass_pvt.create_line_style_roles(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_lsrv_rec,
                x_lsrv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_lsrv_rec := x_lsrv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END create_line_style_roles;

 PROCEDURE create_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type,
    x_lsrv_tbl                     OUT NOCOPY lsrv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lsrv_tbl.COUNT > 0 THEN
      i := p_lsrv_tbl.FIRST;
      LOOP
        create_line_style_roles(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_tbl(i),
                x_lsrv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lsrv_tbl.LAST);
        i := p_lsrv_tbl.NEXT(i);
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
 END create_line_style_roles;

 PROCEDURE update_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type,
    x_lsrv_rec                     OUT NOCOPY lsrv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_line_style_roles';
    l_return_status		   VARCHAR2(1);
    l_lsrv_rec                     lsrv_rec_type := p_lsrv_rec;
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
    -- Call user hook for BEFORE
    g_lsrv_rec := l_lsrv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_lsrv_rec := migrate_lsrv(l_lsrv_rec, g_lsrv_rec);

    okc_subclass_pvt.update_line_style_roles(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_lsrv_rec,
                x_lsrv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_lsrv_rec := x_lsrv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END update_line_style_roles;

 PROCEDURE update_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type,
    x_lsrv_tbl                     OUT NOCOPY lsrv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lsrv_tbl.COUNT > 0 THEN
      i := p_lsrv_tbl.FIRST;
      LOOP
        update_line_style_roles(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_tbl(i),
                x_lsrv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lsrv_tbl.LAST);
        i := p_lsrv_tbl.NEXT(i);
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
 END update_line_style_roles;

 PROCEDURE delete_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_line_style_roles';
    l_return_status		   VARCHAR2(1);
    l_lsrv_rec                     lsrv_rec_type := p_lsrv_rec;
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
    -- Call user hook for BEFORE
    g_lsrv_rec := l_lsrv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okc_subclass_pvt.delete_line_style_roles(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END delete_line_style_roles;

 PROCEDURE delete_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lsrv_tbl.COUNT > 0 THEN
      i := p_lsrv_tbl.FIRST;
      LOOP
        delete_line_style_roles(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lsrv_tbl.LAST);
        i := p_lsrv_tbl.NEXT(i);
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
 END delete_line_style_roles;

 PROCEDURE lock_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type) IS
 BEGIN
    okc_subclass_pvt.lock_line_style_roles(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_rec);
 END lock_line_style_roles;

 PROCEDURE lock_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type) IS
 BEGIN
    okc_subclass_pvt.lock_line_style_roles(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_tbl);
 END lock_line_style_roles;

 PROCEDURE validate_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type) IS
 BEGIN
    okc_subclass_pvt.validate_line_style_roles(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_rec);
 END validate_line_style_roles;

 PROCEDURE validate_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type) IS
 BEGIN
    okc_subclass_pvt.validate_line_style_roles(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_tbl);
 END validate_line_style_roles;

 PROCEDURE create_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type,
    x_lrgv_rec                     OUT NOCOPY lrgv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_lse_rule_groups';
    l_return_status		   VARCHAR2(1);
    l_lrgv_rec                     lrgv_rec_type := p_lrgv_rec;
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
    -- Call user hook for BEFORE
    g_lrgv_rec := l_lrgv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_lrgv_rec := migrate_lrgv(l_lrgv_rec, g_lrgv_rec);

    okc_subclass_pvt.create_lse_rule_groups(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_lrgv_rec,
                x_lrgv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_lrgv_rec := x_lrgv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END create_lse_rule_groups;

 PROCEDURE create_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type,
    x_lrgv_tbl                     OUT NOCOPY lrgv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lrgv_tbl.COUNT > 0 THEN
      i := p_lrgv_tbl.FIRST;
      LOOP
        create_lse_rule_groups(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_tbl(i),
                x_lrgv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lrgv_tbl.LAST);
        i := p_lrgv_tbl.NEXT(i);
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
 END create_lse_rule_groups;

 PROCEDURE update_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type,
    x_lrgv_rec                     OUT NOCOPY lrgv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_lse_rule_groups';
    l_return_status		   VARCHAR2(1);
    l_lrgv_rec                     lrgv_rec_type := p_lrgv_rec;
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
    -- Call user hook for BEFORE
    g_lrgv_rec := l_lrgv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_lrgv_rec := migrate_lrgv(l_lrgv_rec, g_lrgv_rec);

    okc_subclass_pvt.update_lse_rule_groups(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_lrgv_rec,
                x_lrgv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_lrgv_rec := x_lrgv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END update_lse_rule_groups;

 PROCEDURE update_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type,
    x_lrgv_tbl                     OUT NOCOPY lrgv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lrgv_tbl.COUNT > 0 THEN
      i := p_lrgv_tbl.FIRST;
      LOOP
        update_lse_rule_groups(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_tbl(i),
                x_lrgv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lrgv_tbl.LAST);
        i := p_lrgv_tbl.NEXT(i);
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
 END update_lse_rule_groups;

 PROCEDURE delete_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_lse_rule_groups';
    l_return_status		   VARCHAR2(1);
    l_lrgv_rec                     lrgv_rec_type := p_lrgv_rec;
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
    -- Call user hook for BEFORE
    g_lrgv_rec := l_lrgv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okc_subclass_pvt.delete_lse_rule_groups(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END delete_lse_rule_groups;

 PROCEDURE delete_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lrgv_tbl.COUNT > 0 THEN
      i := p_lrgv_tbl.FIRST;
      LOOP
        delete_lse_rule_groups(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lrgv_tbl.LAST);
        i := p_lrgv_tbl.NEXT(i);
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
 END delete_lse_rule_groups;

 PROCEDURE lock_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type) IS
 BEGIN
    okc_subclass_pvt.lock_lse_rule_groups(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_rec);
 END lock_lse_rule_groups;

 PROCEDURE lock_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type) IS
 BEGIN
    okc_subclass_pvt.lock_lse_rule_groups(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_tbl);
 END lock_lse_rule_groups;

 PROCEDURE validate_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type) IS
 BEGIN
    okc_subclass_pvt.validate_lse_rule_groups(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_rec);
 END validate_lse_rule_groups;

 PROCEDURE validate_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type) IS
 BEGIN
    okc_subclass_pvt.validate_lse_rule_groups(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_tbl);
 END validate_lse_rule_groups;

 PROCEDURE create_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type,
    x_srav_rec                     OUT NOCOPY srav_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_subclass_resps';
    l_return_status		   VARCHAR2(1);
    l_srav_rec                     srav_rec_type := p_srav_rec;
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
    -- Call user hook for BEFORE
    g_srav_rec := l_srav_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_srav_rec := migrate_srav(l_srav_rec, g_srav_rec);

    okc_subclass_pvt.create_subclass_resps(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_srav_rec,
                x_srav_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_srav_rec := x_srav_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END create_subclass_resps;

 PROCEDURE create_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type,
    x_srav_tbl                     OUT NOCOPY srav_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_srav_tbl.COUNT > 0 THEN
      i := p_srav_tbl.FIRST;
      LOOP
        create_subclass_resps(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_tbl(i),
                x_srav_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_srav_tbl.LAST);
        i := p_srav_tbl.NEXT(i);
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
 END create_subclass_resps;

 PROCEDURE update_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type,
    x_srav_rec                     OUT NOCOPY srav_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_subclass_resps';
    l_return_status		   VARCHAR2(1);
    l_srav_rec                     srav_rec_type := p_srav_rec;
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
    -- Call user hook for BEFORE
    g_srav_rec := l_srav_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_srav_rec := migrate_srav(l_srav_rec, g_srav_rec);

    okc_subclass_pvt.update_subclass_resps(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_srav_rec,
                x_srav_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_srav_rec := x_srav_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END update_subclass_resps;

 PROCEDURE update_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type,
    x_srav_tbl                     OUT NOCOPY srav_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_srav_tbl.COUNT > 0 THEN
      i := p_srav_tbl.FIRST;
      LOOP
        update_subclass_resps(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_tbl(i),
                x_srav_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_srav_tbl.LAST);
        i := p_srav_tbl.NEXT(i);
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
 END update_subclass_resps;

 PROCEDURE delete_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_subclass_resps';
    l_return_status		   VARCHAR2(1);
    l_srav_rec                     srav_rec_type := p_srav_rec;
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
    -- Call user hook for BEFORE
    g_srav_rec := l_srav_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okc_subclass_pvt.delete_subclass_resps(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
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
 END delete_subclass_resps;

 PROCEDURE delete_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_srav_tbl.COUNT > 0 THEN
      i := p_srav_tbl.FIRST;
      LOOP
        delete_subclass_resps(
                p_api_version,
                p_init_msg_list,
                l_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_srav_tbl.LAST);
        i := p_srav_tbl.NEXT(i);
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
 END delete_subclass_resps;

 PROCEDURE lock_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type) IS
 BEGIN
    okc_subclass_pvt.lock_subclass_resps(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_rec);
 END lock_subclass_resps;

 PROCEDURE lock_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type) IS
 BEGIN
    okc_subclass_pvt.lock_subclass_resps(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_tbl);
 END lock_subclass_resps;

 PROCEDURE validate_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type) IS
 BEGIN
    okc_subclass_pvt.validate_subclass_resps(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_rec);
 END validate_subclass_resps;

 PROCEDURE validate_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type) IS
 BEGIN
    okc_subclass_pvt.validate_subclass_resps(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_tbl);
 END validate_subclass_resps;

PROCEDURE copy_category(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copy_from_scs_code           IN VARCHAR2,
    p_new_scs_name                 IN VARCHAR2,
    p_new_scs_desc                 IN VARCHAR2,
    x_scsv_rec                     OUT NOCOPY scsv_rec_type ) IS

    l_api_name                     CONSTANT VARCHAR2(30) := 'copy_category';
    l_return_status		   VARCHAR2(1);

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

    -- Call user hook for BEFORE

    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;


    okc_subclass_pvt.copy_category(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_copy_from_scs_code,
                p_new_scs_name,
                p_new_scs_desc,
                x_scsv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER

    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');

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
 END copy_category;
END okc_subclass_pub;

/
