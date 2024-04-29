--------------------------------------------------------
--  DDL for Package Body OKC_TIME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TIME_PUB" AS
/* $Header: OKCPTVEB.pls 120.0 2005/05/25 18:46:39 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPA_RELTV
 --------------------------------------------------------------------------

  PROCEDURE ADD_LANGUAGE IS
  BEGIN
    OKC_TIME_PVT.ADD_LANGUAGE;
  END ADD_LANGUAGE;

  PROCEDURE DELETE_TIMEVALUES_N_TASKS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_chr_id            IN NUMBER  ,
    p_tve_id                IN NUMBER) IS
   BEGIN
     OKC_TIME_PVT.DELETE_TIMEVALUES_N_TASKS(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_chr_id,
       p_tve_id);
  END DELETE_TIMEVALUES_N_TASKS;

  FUNCTION migrate_talv(p_talv_rec1 IN talv_rec_type,
                        p_talv_rec2 IN talv_rec_type)
    RETURN talv_rec_type IS
    l_talv_rec talv_rec_type;
  BEGIN
    l_talv_rec.id                    := p_talv_rec1.id;
    l_talv_rec.object_version_number := p_talv_rec1.object_version_number;
    l_talv_rec.created_by            := p_talv_rec1.created_by;
    l_talv_rec.creation_date         := p_talv_rec1.creation_date;
    l_talv_rec.last_updated_by       := p_talv_rec1.last_updated_by;
    l_talv_rec.last_update_date      := p_talv_rec1.last_update_date;
    l_talv_rec.last_update_login     := p_talv_rec1.last_update_login;
    l_talv_rec.sfwt_flag             := p_talv_rec2.sfwt_flag;
    l_talv_rec.tve_id_limited         := p_talv_rec2.tve_id_limited;
    l_talv_rec.dnz_chr_id         := p_talv_rec2.dnz_chr_id;
    l_talv_rec.tve_id_offset         := p_talv_rec2.tve_id_offset;
    l_talv_rec.operator              := p_talv_rec2.operator;
    l_talv_rec.before_after          := p_talv_rec2.before_after;
    l_talv_rec.duration              := p_talv_rec2.duration;
    l_talv_rec.uom_code   := p_talv_rec2.uom_code;
    l_talv_rec.tze_id   := p_talv_rec2.tze_id;
    l_talv_rec.spn_id                := p_talv_rec2.spn_id;
    l_talv_rec.short_description     := p_talv_rec2.short_description;
    l_talv_rec.description           := p_talv_rec2.description;
    l_talv_rec.comments              := p_talv_rec2.comments;
    l_talv_rec.attribute_category    := p_talv_rec2.attribute_category;
    l_talv_rec.attribute1            := p_talv_rec2.attribute1;
    l_talv_rec.attribute2            := p_talv_rec2.attribute2;
    l_talv_rec.attribute3            := p_talv_rec2.attribute3;
    l_talv_rec.attribute4            := p_talv_rec2.attribute4;
    l_talv_rec.attribute5            := p_talv_rec2.attribute5;
    l_talv_rec.attribute6            := p_talv_rec2.attribute6;
    l_talv_rec.attribute7            := p_talv_rec2.attribute7;
    l_talv_rec.attribute8            := p_talv_rec2.attribute8;
    l_talv_rec.attribute9            := p_talv_rec2.attribute9;
    l_talv_rec.attribute10           := p_talv_rec2.attribute10;
    l_talv_rec.attribute11           := p_talv_rec2.attribute11;
    l_talv_rec.attribute12           := p_talv_rec2.attribute12;
    l_talv_rec.attribute13           := p_talv_rec2.attribute13;
    l_talv_rec.attribute14           := p_talv_rec2.attribute14;
    l_talv_rec.attribute15           := p_talv_rec2.attribute15;
    RETURN (l_talv_rec);
  END migrate_talv;

  FUNCTION migrate_talv(p_talv_tbl1 IN talv_tbl_type,
    p_talv_tbl2 IN talv_tbl_type)
    RETURN talv_tbl_type IS
    l_talv_tbl talv_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_talv_tbl1.COUNT <> p_talv_tbl2.COUNT THEN
      l_talv_tbl := p_talv_tbl1;
    ELSE
      IF (p_talv_tbl1.COUNT > 0) THEN
        i := p_talv_tbl1.FIRST;
        j := p_talv_tbl2.FIRST;
        LOOP
          l_talv_tbl(i) := migrate_talv(p_talv_tbl1(i), p_talv_tbl2(j));
          EXIT WHEN (i = p_talv_tbl1.LAST);
          i := p_talv_tbl1.NEXT(i);
          j := p_talv_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_talv_tbl);
  END migrate_talv;

  PROCEDURE CREATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	            IN talv_rec_type,
    x_talv_rec              OUT NOCOPY talv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_TPA_RELTV';
    l_return_status	  VARCHAR2(1);
    l_talv_rec     talv_rec_type := p_talv_rec;
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
    g_talv_rec := l_talv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_talv_rec := migrate_talv(l_talv_rec, g_talv_rec);
    OKC_TIME_PVT.CREATE_TPA_RELTV(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_talv_rec,
       x_talv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_talv_rec := x_talv_rec;
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
  END CREATE_TPA_RELTV;

  PROCEDURE CREATE_TPA_RELTV(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type,
    x_talv_tbl                     OUT NOCOPY talv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_talv_tbl.COUNT > 0 THEN
      i := p_talv_tbl.FIRST;
      LOOP
        CREATE_TPA_RELTV(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_talv_tbl(i),
	    x_talv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
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
  END CREATE_TPA_RELTV;

  PROCEDURE UPDATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	            IN talv_rec_type,
    x_talv_rec              OUT NOCOPY talv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_TPA_RELTV';
    l_return_status	  VARCHAR2(1);
    l_talv_rec     talv_rec_type := p_talv_rec;
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
    g_talv_rec := l_talv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_talv_rec := migrate_talv(l_talv_rec, g_talv_rec);
    OKC_TIME_PVT.UPDATE_TPA_RELTV(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_talv_rec,
       x_talv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_talv_rec := x_talv_rec;
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
  END UPDATE_TPA_RELTV;

  PROCEDURE UPDATE_TPA_RELTV(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type,
    x_talv_tbl                     OUT NOCOPY talv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_talv_tbl.COUNT > 0 THEN
      i := p_talv_tbl.FIRST;
      LOOP
        UPDATE_TPA_RELTV(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_talv_tbl(i),
	    x_talv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
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
  END UPDATE_TPA_RELTV;

  PROCEDURE DELETE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec              IN talv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_TPA_RELTV';
    l_return_status	  VARCHAR2(1);
    l_talv_rec     talv_rec_type := p_talv_rec;
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
    g_talv_rec := l_talv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_PVT.DELETE_TPA_RELTV(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_talv_rec);
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
  END DELETE_TPA_RELTV;

  PROCEDURE DELETE_TPA_RELTV(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_talv_tbl.COUNT > 0 THEN
      i := p_talv_tbl.FIRST;
      LOOP
        DELETE_TPA_RELTV(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_talv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
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
  END DELETE_TPA_RELTV;

  PROCEDURE LOCK_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec		    IN talv_rec_type) IS
  BEGIN
    OKC_TIME_PVT.LOCK_TPA_RELTV(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_talv_rec);
  END LOCK_TPA_RELTV;

  PROCEDURE LOCK_TPA_RELTV(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_talv_tbl.COUNT > 0 THEN
      i := p_talv_tbl.FIRST;
      LOOP
        LOCK_TPA_RELTV(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_talv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
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
  END LOCK_TPA_RELTV;

  PROCEDURE VALID_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec		    IN talv_rec_type) IS
  BEGIN
    OKC_TIME_PVT.VALID_TPA_RELTV(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_talv_rec);
  END VALID_TPA_RELTV;

  PROCEDURE VALID_TPA_RELTV(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_talv_tbl.COUNT > 0 THEN
      i := p_talv_tbl.FIRST;
      LOOP
        VALID_TPA_RELTV(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_talv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
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
  END VALID_TPA_RELTV;

  FUNCTION migrate_talv(p_talv_evt_rec1 IN talv_evt_rec_type,
                        p_talv_evt_rec2 IN talv_evt_rec_type)
    RETURN talv_evt_rec_type IS
    l_talv_evt_rec talv_evt_rec_type;
  BEGIN
    l_talv_evt_rec.id                    := p_talv_evt_rec1.id;
    l_talv_evt_rec.object_version_number := p_talv_evt_rec1.object_version_number;
    l_talv_evt_rec.created_by            := p_talv_evt_rec1.created_by;
    l_talv_evt_rec.creation_date         := p_talv_evt_rec1.creation_date;
    l_talv_evt_rec.last_updated_by       := p_talv_evt_rec1.last_updated_by;
    l_talv_evt_rec.last_update_date      := p_talv_evt_rec1.last_update_date;
    l_talv_evt_rec.last_update_login     := p_talv_evt_rec1.last_update_login;
    l_talv_evt_rec.sfwt_flag             := p_talv_evt_rec2.sfwt_flag;
    l_talv_evt_rec.tve_id_limited         := p_talv_evt_rec2.tve_id_limited;
    l_talv_evt_rec.dnz_chr_id         := p_talv_evt_rec2.dnz_chr_id;
    l_talv_evt_rec.tve_id_offset         := p_talv_evt_rec2.tve_id_offset;
    l_talv_evt_rec.operator              := p_talv_evt_rec2.operator;
    l_talv_evt_rec.before_after          := p_talv_evt_rec2.before_after;
    l_talv_evt_rec.duration              := p_talv_evt_rec2.duration;
    l_talv_evt_rec.uom_code   := p_talv_evt_rec2.uom_code;
    l_talv_evt_rec.tze_id   := p_talv_evt_rec2.tze_id;
    l_talv_evt_rec.cnh_id                := p_talv_evt_rec2.cnh_id;
    l_talv_evt_rec.spn_id                := p_talv_evt_rec2.spn_id;
    l_talv_evt_rec.short_description     := p_talv_evt_rec2.short_description;
    l_talv_evt_rec.description           := p_talv_evt_rec2.description;
    l_talv_evt_rec.comments              := p_talv_evt_rec2.comments;
    l_talv_evt_rec.attribute_category    := p_talv_evt_rec2.attribute_category;
    l_talv_evt_rec.attribute1            := p_talv_evt_rec2.attribute1;
    l_talv_evt_rec.attribute2            := p_talv_evt_rec2.attribute2;
    l_talv_evt_rec.attribute3            := p_talv_evt_rec2.attribute3;
    l_talv_evt_rec.attribute4            := p_talv_evt_rec2.attribute4;
    l_talv_evt_rec.attribute5            := p_talv_evt_rec2.attribute5;
    l_talv_evt_rec.attribute6            := p_talv_evt_rec2.attribute6;
    l_talv_evt_rec.attribute7            := p_talv_evt_rec2.attribute7;
    l_talv_evt_rec.attribute8            := p_talv_evt_rec2.attribute8;
    l_talv_evt_rec.attribute9            := p_talv_evt_rec2.attribute9;
    l_talv_evt_rec.attribute10           := p_talv_evt_rec2.attribute10;
    l_talv_evt_rec.attribute11           := p_talv_evt_rec2.attribute11;
    l_talv_evt_rec.attribute12           := p_talv_evt_rec2.attribute12;
    l_talv_evt_rec.attribute13           := p_talv_evt_rec2.attribute13;
    l_talv_evt_rec.attribute14           := p_talv_evt_rec2.attribute14;
    l_talv_evt_rec.attribute15           := p_talv_evt_rec2.attribute15;
    RETURN (l_talv_evt_rec);
  END migrate_talv;

  FUNCTION migrate_talv(p_talv_evt_tbl1 IN talv_evt_tbl_type,
    p_talv_evt_tbl2 IN talv_evt_tbl_type)
    RETURN talv_evt_tbl_type IS
    l_talv_evt_tbl talv_evt_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_talv_evt_tbl1.COUNT <> p_talv_evt_tbl2.COUNT THEN
      l_talv_evt_tbl := p_talv_evt_tbl1;
    ELSE
      IF (p_talv_evt_tbl1.COUNT > 0) THEN
        i := p_talv_evt_tbl1.FIRST;
        j := p_talv_evt_tbl2.FIRST;
        LOOP
          l_talv_evt_tbl(i) := migrate_talv(p_talv_evt_tbl1(i), p_talv_evt_tbl2(j));
          EXIT WHEN (i = p_talv_evt_tbl1.LAST);
          i := p_talv_evt_tbl1.NEXT(i);
          j := p_talv_evt_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_talv_evt_tbl);
  END migrate_talv;

  PROCEDURE CREATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	            IN talv_evt_rec_type,
    x_talv_evt_rec              OUT NOCOPY talv_evt_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_TPA_RELTV';
    l_return_status	  VARCHAR2(1);
    l_talv_evt_rec     talv_evt_rec_type := p_talv_evt_rec;
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
    g_talv_evt_rec := l_talv_evt_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_talv_evt_rec := migrate_talv(l_talv_evt_rec, g_talv_evt_rec);
    OKC_TIME_PVT.CREATE_TPA_RELTV(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_talv_evt_rec,
       x_talv_evt_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_talv_evt_rec := x_talv_evt_rec;
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
  END CREATE_TPA_RELTV;

  PROCEDURE CREATE_TPA_RELTV(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_evt_tbl                     IN talv_evt_tbl_type,
    x_talv_evt_tbl                     OUT NOCOPY talv_evt_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_talv_evt_tbl.COUNT > 0 THEN
      i := p_talv_evt_tbl.FIRST;
      LOOP
        CREATE_TPA_RELTV(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_talv_evt_tbl(i),
	    x_talv_evt_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_talv_evt_tbl.LAST);
        i := p_talv_evt_tbl.NEXT(i);
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
  END CREATE_TPA_RELTV;

  PROCEDURE UPDATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	            IN talv_evt_rec_type,
    x_talv_evt_rec              OUT NOCOPY talv_evt_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_TPA_RELTV';
    l_return_status	  VARCHAR2(1);
    l_talv_evt_rec     talv_evt_rec_type := p_talv_evt_rec;
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
    g_talv_evt_rec := l_talv_evt_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_talv_evt_rec := migrate_talv(l_talv_evt_rec, g_talv_evt_rec);
    OKC_TIME_PVT.UPDATE_TPA_RELTV(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_talv_evt_rec,
       x_talv_evt_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_talv_evt_rec := x_talv_evt_rec;
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
  END UPDATE_TPA_RELTV;

  PROCEDURE UPDATE_TPA_RELTV(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_evt_tbl                     IN talv_evt_tbl_type,
    x_talv_evt_tbl                     OUT NOCOPY talv_evt_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_talv_evt_tbl.COUNT > 0 THEN
      i := p_talv_evt_tbl.FIRST;
      LOOP
        UPDATE_TPA_RELTV(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_talv_evt_tbl(i),
	    x_talv_evt_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_talv_evt_tbl.LAST);
        i := p_talv_evt_tbl.NEXT(i);
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
  END UPDATE_TPA_RELTV;

  PROCEDURE DELETE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec              IN talv_evt_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_TPA_RELTV';
    l_return_status	  VARCHAR2(1);
    l_talv_evt_rec     talv_evt_rec_type := p_talv_evt_rec;
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
    g_talv_evt_rec := l_talv_evt_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_PVT.DELETE_TPA_RELTV(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_talv_evt_rec);
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
  END DELETE_TPA_RELTV;

  PROCEDURE DELETE_TPA_RELTV(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_evt_tbl                     IN talv_evt_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_talv_evt_tbl.COUNT > 0 THEN
      i := p_talv_evt_tbl.FIRST;
      LOOP
        DELETE_TPA_RELTV(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_talv_evt_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_talv_evt_tbl.LAST);
        i := p_talv_evt_tbl.NEXT(i);
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
  END DELETE_TPA_RELTV;

  PROCEDURE LOCK_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec		    IN talv_evt_rec_type) IS
  BEGIN
    OKC_TIME_PVT.LOCK_TPA_RELTV(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_talv_evt_rec);
  END LOCK_TPA_RELTV;

  PROCEDURE LOCK_TPA_RELTV(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_evt_tbl                     IN talv_evt_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_talv_evt_tbl.COUNT > 0 THEN
      i := p_talv_evt_tbl.FIRST;
      LOOP
        LOCK_TPA_RELTV(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_talv_evt_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_talv_evt_tbl.LAST);
        i := p_talv_evt_tbl.NEXT(i);
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
  END LOCK_TPA_RELTV;

  PROCEDURE VALID_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec		    IN talv_evt_rec_type) IS
  BEGIN
    OKC_TIME_PVT.VALID_TPA_RELTV(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_talv_evt_rec);
  END VALID_TPA_RELTV;

  PROCEDURE VALID_TPA_RELTV(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_evt_tbl                     IN talv_evt_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_talv_evt_tbl.COUNT > 0 THEN
      i := p_talv_evt_tbl.FIRST;
      LOOP
        VALID_TPA_RELTV(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_talv_evt_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_talv_evt_tbl.LAST);
        i := p_talv_evt_tbl.NEXT(i);
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
  END VALID_TPA_RELTV;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPA_VALUE
 --------------------------------------------------------------------------

  FUNCTION migrate_tavv(p_tavv_rec1 IN tavv_rec_type,
                        p_tavv_rec2 IN tavv_rec_type)
    RETURN tavv_rec_type IS
    l_tavv_rec tavv_rec_type;
  BEGIN
    l_tavv_rec.id                    := p_tavv_rec1.id;
    l_tavv_rec.object_version_number := p_tavv_rec1.object_version_number;
    l_tavv_rec.created_by            := p_tavv_rec1.created_by;
    l_tavv_rec.creation_date         := p_tavv_rec1.creation_date;
    l_tavv_rec.last_updated_by       := p_tavv_rec1.last_updated_by;
    l_tavv_rec.last_update_date      := p_tavv_rec1.last_update_date;
    l_tavv_rec.last_update_login     := p_tavv_rec1.last_update_login;
    l_tavv_rec.tze_id   := p_tavv_rec2.tze_id;
    l_tavv_rec.sfwt_flag             := p_tavv_rec2.sfwt_flag;
    l_tavv_rec.tve_id_generated_by   := p_tavv_rec2.tve_id_generated_by;
    l_tavv_rec.tve_id_limited        := p_tavv_rec2.tve_id_limited;
    l_tavv_rec.dnz_chr_id         := p_tavv_rec2.dnz_chr_id;
    l_tavv_rec.datetime              := p_tavv_rec2.datetime;
    l_tavv_rec.spn_id                := p_tavv_rec2.spn_id;
    l_tavv_rec.short_description     := p_tavv_rec2.short_description;
    l_tavv_rec.description           := p_tavv_rec2.description;
    l_tavv_rec.comments              := p_tavv_rec2.comments;
    l_tavv_rec.attribute_category    := p_tavv_rec2.attribute_category;
    l_tavv_rec.attribute1            := p_tavv_rec2.attribute1;
    l_tavv_rec.attribute2            := p_tavv_rec2.attribute2;
    l_tavv_rec.attribute3            := p_tavv_rec2.attribute3;
    l_tavv_rec.attribute4            := p_tavv_rec2.attribute4;
    l_tavv_rec.attribute5            := p_tavv_rec2.attribute5;
    l_tavv_rec.attribute6            := p_tavv_rec2.attribute6;
    l_tavv_rec.attribute7            := p_tavv_rec2.attribute7;
    l_tavv_rec.attribute8            := p_tavv_rec2.attribute8;
    l_tavv_rec.attribute9            := p_tavv_rec2.attribute9;
    l_tavv_rec.attribute10           := p_tavv_rec2.attribute10;
    l_tavv_rec.attribute11           := p_tavv_rec2.attribute11;
    l_tavv_rec.attribute12           := p_tavv_rec2.attribute12;
    l_tavv_rec.attribute13           := p_tavv_rec2.attribute13;
    l_tavv_rec.attribute14           := p_tavv_rec2.attribute14;
    l_tavv_rec.attribute15           := p_tavv_rec2.attribute15;
    RETURN (l_tavv_rec);
  END migrate_tavv;

  FUNCTION migrate_tavv(p_tavv_tbl1 IN tavv_tbl_type,
    p_tavv_tbl2 IN tavv_tbl_type)
    RETURN tavv_tbl_type IS
    l_tavv_tbl tavv_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_tavv_tbl1.COUNT <> p_tavv_tbl2.COUNT THEN
      l_tavv_tbl := p_tavv_tbl1;
    ELSE
      IF (p_tavv_tbl1.COUNT > 0) THEN
        i := p_tavv_tbl1.FIRST;
        j := p_tavv_tbl2.FIRST;
        LOOP
          l_tavv_tbl(i) := migrate_tavv(p_tavv_tbl1(i), p_tavv_tbl2(j));
          EXIT WHEN (i = p_tavv_tbl1.LAST);
          i := p_tavv_tbl1.NEXT(i);
          j := p_tavv_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_tavv_tbl);
  END migrate_tavv;

  PROCEDURE CREATE_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	            IN tavv_rec_type,
    x_tavv_rec              OUT NOCOPY tavv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_TPA_VALUE';
    l_return_status	  VARCHAR2(1);
    l_tavv_rec     tavv_rec_type := p_tavv_rec;
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
    g_tavv_rec := l_tavv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_tavv_rec := migrate_tavv(l_tavv_rec, g_tavv_rec);
    OKC_TIME_PVT.CREATE_TPA_VALUE(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_tavv_rec,
       x_tavv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_tavv_rec := x_tavv_rec;
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
  END CREATE_TPA_VALUE;

  PROCEDURE CREATE_TPA_VALUE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tavv_tbl                     IN tavv_tbl_type,
    x_tavv_tbl                     OUT NOCOPY tavv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tavv_tbl.COUNT > 0 THEN
      i := p_tavv_tbl.FIRST;
      LOOP
        CREATE_TPA_VALUE(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tavv_tbl(i),
	    x_tavv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tavv_tbl.LAST);
        i := p_tavv_tbl.NEXT(i);
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
  END CREATE_TPA_VALUE;

  PROCEDURE UPDATE_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	            IN tavv_rec_type,
    x_tavv_rec              OUT NOCOPY tavv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_TPA_VALUE';
    l_return_status	  VARCHAR2(1);
    l_tavv_rec     tavv_rec_type := p_tavv_rec;
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
    g_tavv_rec := l_tavv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_tavv_rec := migrate_tavv(l_tavv_rec, g_tavv_rec);
    OKC_TIME_PVT.UPDATE_TPA_VALUE(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_tavv_rec,
       x_tavv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_tavv_rec := x_tavv_rec;
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
  END UPDATE_TPA_VALUE;

  PROCEDURE UPDATE_TPA_VALUE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tavv_tbl                     IN tavv_tbl_type,
    x_tavv_tbl                     OUT NOCOPY tavv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tavv_tbl.COUNT > 0 THEN
      i := p_tavv_tbl.FIRST;
      LOOP
        UPDATE_TPA_VALUE(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tavv_tbl(i),
	    x_tavv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tavv_tbl.LAST);
        i := p_tavv_tbl.NEXT(i);
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
  END UPDATE_TPA_VALUE;

  PROCEDURE DELETE_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec              IN tavv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_TPA_VALUE';
    l_return_status	  VARCHAR2(1);
    l_tavv_rec     tavv_rec_type := p_tavv_rec;
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
    g_tavv_rec := l_tavv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_PVT.DELETE_TPA_VALUE(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_tavv_rec);
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
  END DELETE_TPA_VALUE;

  PROCEDURE DELETE_TPA_VALUE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tavv_tbl                     IN tavv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tavv_tbl.COUNT > 0 THEN
      i := p_tavv_tbl.FIRST;
      LOOP
        DELETE_TPA_VALUE(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tavv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tavv_tbl.LAST);
        i := p_tavv_tbl.NEXT(i);
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
  END DELETE_TPA_VALUE;

  PROCEDURE LOCK_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec		    IN tavv_rec_type) IS
  BEGIN
    OKC_TIME_PVT.LOCK_TPA_VALUE(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_tavv_rec);
  END LOCK_TPA_VALUE;

  PROCEDURE LOCK_TPA_VALUE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tavv_tbl                     IN tavv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tavv_tbl.COUNT > 0 THEN
      i := p_tavv_tbl.FIRST;
      LOOP
        LOCK_TPA_VALUE(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tavv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tavv_tbl.LAST);
        i := p_tavv_tbl.NEXT(i);
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
  END LOCK_TPA_VALUE;

  PROCEDURE VALID_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec		    IN tavv_rec_type) IS
  BEGIN
    OKC_TIME_PVT.VALID_TPA_VALUE(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_tavv_rec);
  END VALID_TPA_VALUE;

  PROCEDURE VALID_TPA_VALUE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tavv_tbl                     IN tavv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tavv_tbl.COUNT > 0 THEN
      i := p_tavv_tbl.FIRST;
      LOOP
        VALID_TPA_VALUE(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tavv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tavv_tbl.LAST);
        i := p_tavv_tbl.NEXT(i);
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
  END VALID_TPA_VALUE;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPG_DELIMITED
 --------------------------------------------------------------------------

  FUNCTION migrate_tgdv(p_tgdv_ext_rec1 IN tgdv_ext_rec_type,
                        p_tgdv_ext_rec2 IN tgdv_ext_rec_type)
    RETURN tgdv_ext_rec_type IS
    l_tgdv_ext_rec tgdv_ext_rec_type;
  BEGIN
    l_tgdv_ext_rec.id                    := p_tgdv_ext_rec1.id;
    l_tgdv_ext_rec.object_version_number := p_tgdv_ext_rec1.object_version_number;
    l_tgdv_ext_rec.created_by            := p_tgdv_ext_rec1.created_by;
    l_tgdv_ext_rec.creation_date         := p_tgdv_ext_rec1.creation_date;
    l_tgdv_ext_rec.last_updated_by       := p_tgdv_ext_rec1.last_updated_by;
    l_tgdv_ext_rec.last_update_date      := p_tgdv_ext_rec1.last_update_date;
    l_tgdv_ext_rec.last_update_login     := p_tgdv_ext_rec1.last_update_login;
    l_tgdv_ext_rec.sfwt_flag             := p_tgdv_ext_rec2.sfwt_flag;
    l_tgdv_ext_rec.tve_id_limited        := p_tgdv_ext_rec2.tve_id_limited;
    l_tgdv_ext_rec.limited_start_date        := p_tgdv_ext_rec2.limited_start_date;
    l_tgdv_ext_rec.limited_end_date        := p_tgdv_ext_rec2.limited_end_date;
    l_tgdv_ext_rec.tze_id := p_tgdv_ext_rec2.tze_id;
    l_tgdv_ext_rec.dnz_chr_id         := p_tgdv_ext_rec2.dnz_chr_id;
    l_tgdv_ext_rec.month                 := p_tgdv_ext_rec2.month;
    l_tgdv_ext_rec.day                   := p_tgdv_ext_rec2.day;
    l_tgdv_ext_rec.day_of_week           := p_tgdv_ext_rec2.day_of_week;
    l_tgdv_ext_rec.minute                := p_tgdv_ext_rec2.minute;
    l_tgdv_ext_rec.hour                  := p_tgdv_ext_rec2.hour;
    l_tgdv_ext_rec.second                := p_tgdv_ext_rec2.second;
    l_tgdv_ext_rec.nth                := p_tgdv_ext_rec2.nth;
    l_tgdv_ext_rec.short_description     := p_tgdv_ext_rec2.short_description;
    l_tgdv_ext_rec.description           := p_tgdv_ext_rec2.description;
    l_tgdv_ext_rec.comments              := p_tgdv_ext_rec2.comments;
    l_tgdv_ext_rec.attribute_category    := p_tgdv_ext_rec2.attribute_category;
    l_tgdv_ext_rec.attribute1            := p_tgdv_ext_rec2.attribute1;
    l_tgdv_ext_rec.attribute2            := p_tgdv_ext_rec2.attribute2;
    l_tgdv_ext_rec.attribute3            := p_tgdv_ext_rec2.attribute3;
    l_tgdv_ext_rec.attribute4            := p_tgdv_ext_rec2.attribute4;
    l_tgdv_ext_rec.attribute5            := p_tgdv_ext_rec2.attribute5;
    l_tgdv_ext_rec.attribute6            := p_tgdv_ext_rec2.attribute6;
    l_tgdv_ext_rec.attribute7            := p_tgdv_ext_rec2.attribute7;
    l_tgdv_ext_rec.attribute8            := p_tgdv_ext_rec2.attribute8;
    l_tgdv_ext_rec.attribute9            := p_tgdv_ext_rec2.attribute9;
    l_tgdv_ext_rec.attribute10           := p_tgdv_ext_rec2.attribute10;
    l_tgdv_ext_rec.attribute11           := p_tgdv_ext_rec2.attribute11;
    l_tgdv_ext_rec.attribute12           := p_tgdv_ext_rec2.attribute12;
    l_tgdv_ext_rec.attribute13           := p_tgdv_ext_rec2.attribute13;
    l_tgdv_ext_rec.attribute14           := p_tgdv_ext_rec2.attribute14;
    l_tgdv_ext_rec.attribute15           := p_tgdv_ext_rec2.attribute15;
    RETURN (l_tgdv_ext_rec);
  END migrate_tgdv;

  FUNCTION migrate_tgdv(p_tgdv_ext_tbl1 IN tgdv_ext_tbl_type,
    p_tgdv_ext_tbl2 IN tgdv_ext_tbl_type)
    RETURN tgdv_ext_tbl_type IS
    l_tgdv_ext_tbl tgdv_ext_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_tgdv_ext_tbl1.COUNT <> p_tgdv_ext_tbl2.COUNT THEN
      l_tgdv_ext_tbl := p_tgdv_ext_tbl1;
    ELSE
      IF (p_tgdv_ext_tbl1.COUNT > 0) THEN
        i := p_tgdv_ext_tbl1.FIRST;
        j := p_tgdv_ext_tbl2.FIRST;
        LOOP
          l_tgdv_ext_tbl(i) := migrate_tgdv(p_tgdv_ext_tbl1(i), p_tgdv_ext_tbl2(j));
          EXIT WHEN (i = p_tgdv_ext_tbl1.LAST);
          i := p_tgdv_ext_tbl1.NEXT(i);
          j := p_tgdv_ext_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_tgdv_ext_tbl);
  END migrate_tgdv;

  PROCEDURE CREATE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	            IN tgdv_ext_rec_type,
    x_tgdv_ext_rec              OUT NOCOPY tgdv_ext_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_TPG_DELIMITED';
    l_return_status	  VARCHAR2(1);
    l_tgdv_ext_rec     tgdv_ext_rec_type := p_tgdv_ext_rec;
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
    g_tgdv_ext_rec := l_tgdv_ext_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_tgdv_ext_rec := migrate_tgdv(l_tgdv_ext_rec, g_tgdv_ext_rec);
    OKC_TIME_PVT.CREATE_TPG_DELIMITED(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_tgdv_ext_rec,
       x_tgdv_ext_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_tgdv_ext_rec := x_tgdv_ext_rec;
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
  END CREATE_TPG_DELIMITED;

  PROCEDURE CREATE_TPG_DELIMITED(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tgdv_ext_tbl                     IN tgdv_ext_tbl_type,
    x_tgdv_ext_tbl                     OUT NOCOPY tgdv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tgdv_ext_tbl.COUNT > 0 THEN
      i := p_tgdv_ext_tbl.FIRST;
      LOOP
        CREATE_TPG_DELIMITED(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tgdv_ext_tbl(i),
	    x_tgdv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tgdv_ext_tbl.LAST);
        i := p_tgdv_ext_tbl.NEXT(i);
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
  END CREATE_TPG_DELIMITED;

  PROCEDURE UPDATE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	            IN tgdv_ext_rec_type,
    x_tgdv_ext_rec              OUT NOCOPY tgdv_ext_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_TPG_DELIMITED';
    l_return_status	  VARCHAR2(1);
    l_tgdv_ext_rec     tgdv_ext_rec_type := p_tgdv_ext_rec;
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
    g_tgdv_ext_rec := l_tgdv_ext_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_tgdv_ext_rec := migrate_tgdv(l_tgdv_ext_rec, g_tgdv_ext_rec);
    OKC_TIME_PVT.UPDATE_TPG_DELIMITED(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_tgdv_ext_rec,
       x_tgdv_ext_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_tgdv_ext_rec := x_tgdv_ext_rec;
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
  END UPDATE_TPG_DELIMITED;

  PROCEDURE UPDATE_TPG_DELIMITED(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tgdv_ext_tbl                     IN tgdv_ext_tbl_type,
    x_tgdv_ext_tbl                     OUT NOCOPY tgdv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tgdv_ext_tbl.COUNT > 0 THEN
      i := p_tgdv_ext_tbl.FIRST;
      LOOP
        UPDATE_TPG_DELIMITED(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tgdv_ext_tbl(i),
	    x_tgdv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tgdv_ext_tbl.LAST);
        i := p_tgdv_ext_tbl.NEXT(i);
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
  END UPDATE_TPG_DELIMITED;

  PROCEDURE DELETE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec              IN tgdv_ext_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_TPG_DELIMITED';
    l_return_status	  VARCHAR2(1);
    l_tgdv_ext_rec     tgdv_ext_rec_type := p_tgdv_ext_rec;
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
    g_tgdv_ext_rec := l_tgdv_ext_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_PVT.DELETE_TPG_DELIMITED(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_tgdv_ext_rec);
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
  END DELETE_TPG_DELIMITED;

  PROCEDURE DELETE_TPG_DELIMITED(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tgdv_ext_tbl                     IN tgdv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tgdv_ext_tbl.COUNT > 0 THEN
      i := p_tgdv_ext_tbl.FIRST;
      LOOP
        DELETE_TPG_DELIMITED(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tgdv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tgdv_ext_tbl.LAST);
        i := p_tgdv_ext_tbl.NEXT(i);
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
  END DELETE_TPG_DELIMITED;

  PROCEDURE LOCK_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec		    IN tgdv_ext_rec_type) IS
  BEGIN
    OKC_TIME_PVT.LOCK_TPG_DELIMITED(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_tgdv_ext_rec);
  END LOCK_TPG_DELIMITED;

  PROCEDURE LOCK_TPG_DELIMITED(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tgdv_ext_tbl                     IN tgdv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tgdv_ext_tbl.COUNT > 0 THEN
      i := p_tgdv_ext_tbl.FIRST;
      LOOP
        LOCK_TPG_DELIMITED(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tgdv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tgdv_ext_tbl.LAST);
        i := p_tgdv_ext_tbl.NEXT(i);
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
  END LOCK_TPG_DELIMITED;

  PROCEDURE VALID_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec		    IN tgdv_ext_rec_type) IS
  BEGIN
    OKC_TIME_PVT.VALID_TPG_DELIMITED(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_tgdv_ext_rec);
  END VALID_TPG_DELIMITED;

  PROCEDURE VALID_TPG_DELIMITED(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tgdv_ext_tbl                     IN tgdv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tgdv_ext_tbl.COUNT > 0 THEN
      i := p_tgdv_ext_tbl.FIRST;
      LOOP
        VALID_TPG_DELIMITED(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tgdv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tgdv_ext_tbl.LAST);
        i := p_tgdv_ext_tbl.NEXT(i);
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
  END VALID_TPG_DELIMITED;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPG_NAMED
 --------------------------------------------------------------------------

  FUNCTION migrate_tgnv(p_tgnv_rec1 IN tgnv_rec_type,
                        p_tgnv_rec2 IN tgnv_rec_type)
    RETURN tgnv_rec_type IS
    l_tgnv_rec tgnv_rec_type;
  BEGIN
    l_tgnv_rec.id                    := p_tgnv_rec1.id;
    l_tgnv_rec.object_version_number := p_tgnv_rec1.object_version_number;
    l_tgnv_rec.created_by            := p_tgnv_rec1.created_by;
    l_tgnv_rec.creation_date         := p_tgnv_rec1.creation_date;
    l_tgnv_rec.last_updated_by       := p_tgnv_rec1.last_updated_by;
    l_tgnv_rec.last_update_date      := p_tgnv_rec1.last_update_date;
    l_tgnv_rec.last_update_login     := p_tgnv_rec1.last_update_login;
    l_tgnv_rec.tze_id := p_tgnv_rec2.tze_id;
    l_tgnv_rec.sfwt_flag             := p_tgnv_rec2.sfwt_flag;
    l_tgnv_rec.tve_id_limited        := p_tgnv_rec2.tve_id_limited;
    l_tgnv_rec.dnz_chr_id         := p_tgnv_rec2.dnz_chr_id;
    l_tgnv_rec.cnh_id                := p_tgnv_rec2.cnh_id;
    l_tgnv_rec.short_description     := p_tgnv_rec2.short_description;
    l_tgnv_rec.description           := p_tgnv_rec2.description;
    l_tgnv_rec.comments              := p_tgnv_rec2.comments;
    l_tgnv_rec.attribute_category    := p_tgnv_rec2.attribute_category;
    l_tgnv_rec.attribute1            := p_tgnv_rec2.attribute1;
    l_tgnv_rec.attribute2            := p_tgnv_rec2.attribute2;
    l_tgnv_rec.attribute3            := p_tgnv_rec2.attribute3;
    l_tgnv_rec.attribute4            := p_tgnv_rec2.attribute4;
    l_tgnv_rec.attribute5            := p_tgnv_rec2.attribute5;
    l_tgnv_rec.attribute6            := p_tgnv_rec2.attribute6;
    l_tgnv_rec.attribute7            := p_tgnv_rec2.attribute7;
    l_tgnv_rec.attribute8            := p_tgnv_rec2.attribute8;
    l_tgnv_rec.attribute9            := p_tgnv_rec2.attribute9;
    l_tgnv_rec.attribute10           := p_tgnv_rec2.attribute10;
    l_tgnv_rec.attribute11           := p_tgnv_rec2.attribute11;
    l_tgnv_rec.attribute12           := p_tgnv_rec2.attribute12;
    l_tgnv_rec.attribute13           := p_tgnv_rec2.attribute13;
    l_tgnv_rec.attribute14           := p_tgnv_rec2.attribute14;
    l_tgnv_rec.attribute15           := p_tgnv_rec2.attribute15;
    RETURN (l_tgnv_rec);
  END migrate_tgnv;

  FUNCTION migrate_tgnv(p_tgnv_tbl1 IN tgnv_tbl_type,
    p_tgnv_tbl2 IN tgnv_tbl_type)
    RETURN tgnv_tbl_type IS
    l_tgnv_tbl tgnv_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_tgnv_tbl1.COUNT <> p_tgnv_tbl2.COUNT THEN
      l_tgnv_tbl := p_tgnv_tbl1;
    ELSE
      IF (p_tgnv_tbl1.COUNT > 0) THEN
        i := p_tgnv_tbl1.FIRST;
        j := p_tgnv_tbl2.FIRST;
        LOOP
          l_tgnv_tbl(i) := migrate_tgnv(p_tgnv_tbl1(i), p_tgnv_tbl2(j));
          EXIT WHEN (i = p_tgnv_tbl1.LAST);
          i := p_tgnv_tbl1.NEXT(i);
          j := p_tgnv_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_tgnv_tbl);
  END migrate_tgnv;

  PROCEDURE CREATE_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	            IN tgnv_rec_type,
    x_tgnv_rec              OUT NOCOPY tgnv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_TPG_NAMED';
    l_return_status	  VARCHAR2(1);
    l_tgnv_rec     tgnv_rec_type := p_tgnv_rec;
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
    g_tgnv_rec := l_tgnv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_tgnv_rec := migrate_tgnv(l_tgnv_rec, g_tgnv_rec);
    OKC_TIME_PVT.CREATE_TPG_NAMED(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_tgnv_rec,
       x_tgnv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_tgnv_rec := x_tgnv_rec;
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
  END CREATE_TPG_NAMED;

  PROCEDURE CREATE_TPG_NAMED(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tgnv_tbl                     IN tgnv_tbl_type,
    x_tgnv_tbl                     OUT NOCOPY tgnv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tgnv_tbl.COUNT > 0 THEN
      i := p_tgnv_tbl.FIRST;
      LOOP
        CREATE_TPG_NAMED(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tgnv_tbl(i),
	    x_tgnv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tgnv_tbl.LAST);
        i := p_tgnv_tbl.NEXT(i);
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
  END CREATE_TPG_NAMED;

  PROCEDURE UPDATE_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	            IN tgnv_rec_type,
    x_tgnv_rec              OUT NOCOPY tgnv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_TPG_NAMED';
    l_return_status	  VARCHAR2(1);
    l_tgnv_rec     tgnv_rec_type := p_tgnv_rec;
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
    g_tgnv_rec := l_tgnv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_tgnv_rec := migrate_tgnv(l_tgnv_rec, g_tgnv_rec);
    OKC_TIME_PVT.UPDATE_TPG_NAMED(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_tgnv_rec,
       x_tgnv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_tgnv_rec := x_tgnv_rec;
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
  END UPDATE_TPG_NAMED;

  PROCEDURE UPDATE_TPG_NAMED(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tgnv_tbl                     IN tgnv_tbl_type,
    x_tgnv_tbl                     OUT NOCOPY tgnv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tgnv_tbl.COUNT > 0 THEN
      i := p_tgnv_tbl.FIRST;
      LOOP
        UPDATE_TPG_NAMED(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tgnv_tbl(i),
	    x_tgnv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tgnv_tbl.LAST);
        i := p_tgnv_tbl.NEXT(i);
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
  END UPDATE_TPG_NAMED;

  PROCEDURE DELETE_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec              IN tgnv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_TPG_NAMED';
    l_return_status	  VARCHAR2(1);
    l_tgnv_rec     tgnv_rec_type := p_tgnv_rec;
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
    g_tgnv_rec := l_tgnv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_PVT.DELETE_TPG_NAMED(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_tgnv_rec);
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
  END DELETE_TPG_NAMED;

  PROCEDURE DELETE_TPG_NAMED(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tgnv_tbl                     IN tgnv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tgnv_tbl.COUNT > 0 THEN
      i := p_tgnv_tbl.FIRST;
      LOOP
        DELETE_TPG_NAMED(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tgnv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tgnv_tbl.LAST);
        i := p_tgnv_tbl.NEXT(i);
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
  END DELETE_TPG_NAMED;

  PROCEDURE LOCK_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	    IN tgnv_rec_type) IS
  BEGIN
    OKC_TIME_PVT.LOCK_TPG_NAMED(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_tgnv_rec);
  END LOCK_TPG_NAMED;

  PROCEDURE LOCK_TPG_NAMED(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tgnv_tbl                     IN tgnv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tgnv_tbl.COUNT > 0 THEN
      i := p_tgnv_tbl.FIRST;
      LOOP
        LOCK_TPG_NAMED(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tgnv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tgnv_tbl.LAST);
        i := p_tgnv_tbl.NEXT(i);
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
  END LOCK_TPG_NAMED;

  PROCEDURE VALID_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec		    IN tgnv_rec_type) IS
  BEGIN
    OKC_TIME_PVT.VALID_TPG_NAMED(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_tgnv_rec);
  END VALID_TPG_NAMED;

  PROCEDURE VALID_TPG_NAMED(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tgnv_tbl                     IN tgnv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tgnv_tbl.COUNT > 0 THEN
      i := p_tgnv_tbl.FIRST;
      LOOP
        VALID_TPG_NAMED(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tgnv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tgnv_tbl.LAST);
        i := p_tgnv_tbl.NEXT(i);
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
  END VALID_TPG_NAMED;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_IA_STARTEND
 --------------------------------------------------------------------------

  FUNCTION migrate_isev(p_isev_ext_rec1 IN isev_ext_rec_type,
                        p_isev_ext_rec2 IN isev_ext_rec_type)
    RETURN isev_ext_rec_type IS
    l_isev_ext_rec isev_ext_rec_type;
  BEGIN
    l_isev_ext_rec.id                    := p_isev_ext_rec1.id;
    l_isev_ext_rec.object_version_number := p_isev_ext_rec1.object_version_number;
    l_isev_ext_rec.created_by            := p_isev_ext_rec1.created_by;
    l_isev_ext_rec.creation_date         := p_isev_ext_rec1.creation_date;
    l_isev_ext_rec.last_updated_by       := p_isev_ext_rec1.last_updated_by;
    l_isev_ext_rec.last_update_date      := p_isev_ext_rec1.last_update_date;
    l_isev_ext_rec.last_update_login     := p_isev_ext_rec1.last_update_login;
    l_isev_ext_rec.tze_id := p_isev_ext_rec2.tze_id;
    l_isev_ext_rec.sfwt_flag             := p_isev_ext_rec2.sfwt_flag;
    l_isev_ext_rec.tve_id_limited        := p_isev_ext_rec2.tve_id_limited;
    l_isev_ext_rec.dnz_chr_id         := p_isev_ext_rec2.dnz_chr_id;
    l_isev_ext_rec.tve_id_started        := p_isev_ext_rec2.tve_id_started;
    l_isev_ext_rec.tve_id_ended          := p_isev_ext_rec2.tve_id_ended;
    l_isev_ext_rec.duration              := p_isev_ext_rec2.duration;
    l_isev_ext_rec.uom_code       := p_isev_ext_rec2.uom_code;
    l_isev_ext_rec.before_after       := p_isev_ext_rec2.before_after;
    l_isev_ext_rec.operator              := p_isev_ext_rec2.operator;
    l_isev_ext_rec.spn_id                := p_isev_ext_rec2.spn_id;
    l_isev_ext_rec.short_description     := p_isev_ext_rec2.short_description;
    l_isev_ext_rec.description           := p_isev_ext_rec2.description;
    l_isev_ext_rec.comments              := p_isev_ext_rec2.comments;
    l_isev_ext_rec.attribute_category    := p_isev_ext_rec2.attribute_category;
    l_isev_ext_rec.attribute1            := p_isev_ext_rec2.attribute1;
    l_isev_ext_rec.attribute2            := p_isev_ext_rec2.attribute2;
    l_isev_ext_rec.attribute3            := p_isev_ext_rec2.attribute3;
    l_isev_ext_rec.attribute4            := p_isev_ext_rec2.attribute4;
    l_isev_ext_rec.attribute5            := p_isev_ext_rec2.attribute5;
    l_isev_ext_rec.attribute6            := p_isev_ext_rec2.attribute6;
    l_isev_ext_rec.attribute7            := p_isev_ext_rec2.attribute7;
    l_isev_ext_rec.attribute8            := p_isev_ext_rec2.attribute8;
    l_isev_ext_rec.attribute9            := p_isev_ext_rec2.attribute9;
    l_isev_ext_rec.attribute10           := p_isev_ext_rec2.attribute10;
    l_isev_ext_rec.attribute11           := p_isev_ext_rec2.attribute11;
    l_isev_ext_rec.attribute12           := p_isev_ext_rec2.attribute12;
    l_isev_ext_rec.attribute13           := p_isev_ext_rec2.attribute13;
    l_isev_ext_rec.attribute14           := p_isev_ext_rec2.attribute14;
    l_isev_ext_rec.attribute15           := p_isev_ext_rec2.attribute15;
    RETURN (l_isev_ext_rec);
  END migrate_isev;

  FUNCTION migrate_isev(p_isev_ext_tbl1 IN isev_ext_tbl_type,
    p_isev_ext_tbl2 IN isev_ext_tbl_type)
    RETURN isev_ext_tbl_type IS
    l_isev_ext_tbl isev_ext_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_isev_ext_tbl1.COUNT <> p_isev_ext_tbl2.COUNT THEN
      l_isev_ext_tbl := p_isev_ext_tbl1;
    ELSE
      IF (p_isev_ext_tbl1.COUNT > 0) THEN
        i := p_isev_ext_tbl1.FIRST;
        j := p_isev_ext_tbl2.FIRST;
        LOOP
          l_isev_ext_tbl(i) := migrate_isev(p_isev_ext_tbl1(i), p_isev_ext_tbl2(j));
          EXIT WHEN (i = p_isev_ext_tbl1.LAST);
          i := p_isev_ext_tbl1.NEXT(i);
          j := p_isev_ext_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_isev_ext_tbl);
  END migrate_isev;

  FUNCTION migrate_isev(p_isev_rel_rec1 IN isev_rel_rec_type,
                        p_isev_rel_rec2 IN isev_rel_rec_type)
    RETURN isev_rel_rec_type IS
    l_isev_rel_rec isev_rel_rec_type;
  BEGIN
    l_isev_rel_rec.id                    := p_isev_rel_rec1.id;
    l_isev_rel_rec.object_version_number := p_isev_rel_rec1.object_version_number;
    l_isev_rel_rec.created_by            := p_isev_rel_rec1.created_by;
    l_isev_rel_rec.creation_date         := p_isev_rel_rec1.creation_date;
    l_isev_rel_rec.last_updated_by       := p_isev_rel_rec1.last_updated_by;
    l_isev_rel_rec.last_update_date      := p_isev_rel_rec1.last_update_date;
    l_isev_rel_rec.last_update_login     := p_isev_rel_rec1.last_update_login;
    l_isev_rel_rec.tze_id := p_isev_rel_rec2.tze_id;
    l_isev_rel_rec.sfwt_flag             := p_isev_rel_rec2.sfwt_flag;
    l_isev_rel_rec.dnz_chr_id         := p_isev_rel_rec2.dnz_chr_id;
    l_isev_rel_rec.tve_id_limited        := p_isev_rel_rec2.tve_id_limited;
    l_isev_rel_rec.tve_id_started        := p_isev_rel_rec2.tve_id_started;
    l_isev_rel_rec.tve_id_ended          := p_isev_rel_rec2.tve_id_ended;
    l_isev_rel_rec.duration              := p_isev_rel_rec2.duration;
    l_isev_rel_rec.uom_code       := p_isev_rel_rec2.uom_code;
    l_isev_rel_rec.before_after       := p_isev_rel_rec2.before_after;
    l_isev_rel_rec.operator              := p_isev_rel_rec2.operator;
    l_isev_rel_rec.spn_id                := p_isev_rel_rec2.spn_id;
    l_isev_rel_rec.short_description     := p_isev_rel_rec2.short_description;
    l_isev_rel_rec.description           := p_isev_rel_rec2.description;
    l_isev_rel_rec.comments              := p_isev_rel_rec2.comments;
    l_isev_rel_rec.attribute_category    := p_isev_rel_rec2.attribute_category;
    l_isev_rel_rec.attribute1            := p_isev_rel_rec2.attribute1;
    l_isev_rel_rec.attribute2            := p_isev_rel_rec2.attribute2;
    l_isev_rel_rec.attribute3            := p_isev_rel_rec2.attribute3;
    l_isev_rel_rec.attribute4            := p_isev_rel_rec2.attribute4;
    l_isev_rel_rec.attribute5            := p_isev_rel_rec2.attribute5;
    l_isev_rel_rec.attribute6            := p_isev_rel_rec2.attribute6;
    l_isev_rel_rec.attribute7            := p_isev_rel_rec2.attribute7;
    l_isev_rel_rec.attribute8            := p_isev_rel_rec2.attribute8;
    l_isev_rel_rec.attribute9            := p_isev_rel_rec2.attribute9;
    l_isev_rel_rec.attribute10           := p_isev_rel_rec2.attribute10;
    l_isev_rel_rec.attribute11           := p_isev_rel_rec2.attribute11;
    l_isev_rel_rec.attribute12           := p_isev_rel_rec2.attribute12;
    l_isev_rel_rec.attribute13           := p_isev_rel_rec2.attribute13;
    l_isev_rel_rec.attribute14           := p_isev_rel_rec2.attribute14;
    l_isev_rel_rec.attribute15           := p_isev_rel_rec2.attribute15;
    RETURN (l_isev_rel_rec);
  END migrate_isev;

  FUNCTION migrate_isev(p_isev_rel_tbl1 IN isev_rel_tbl_type,
    p_isev_rel_tbl2 IN isev_rel_tbl_type)
    RETURN isev_rel_tbl_type IS
    l_isev_rel_tbl isev_rel_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_isev_rel_tbl1.COUNT <> p_isev_rel_tbl2.COUNT THEN
      l_isev_rel_tbl := p_isev_rel_tbl1;
    ELSE
      IF (p_isev_rel_tbl1.COUNT > 0) THEN
        i := p_isev_rel_tbl1.FIRST;
        j := p_isev_rel_tbl2.FIRST;
        LOOP
          l_isev_rel_tbl(i) := migrate_isev(p_isev_rel_tbl1(i), p_isev_rel_tbl2(j));
          EXIT WHEN (i = p_isev_rel_tbl1.LAST);
          i := p_isev_rel_tbl1.NEXT(i);
          j := p_isev_rel_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_isev_rel_tbl);
  END migrate_isev;

  PROCEDURE CREATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	            IN isev_ext_rec_type,
    x_isev_ext_rec              OUT NOCOPY isev_ext_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_IA_STARTEND';
    l_return_status	  VARCHAR2(1);
    l_isev_ext_rec     isev_ext_rec_type := p_isev_ext_rec;
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
    g_isev_ext_rec := l_isev_ext_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_isev_ext_rec := migrate_isev(l_isev_ext_rec, g_isev_ext_rec);
    OKC_TIME_PVT.CREATE_IA_STARTEND(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_isev_ext_rec,
       x_isev_ext_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_isev_ext_rec := x_isev_ext_rec;
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
  END CREATE_IA_STARTEND;

  PROCEDURE CREATE_IA_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_isev_ext_tbl                     IN isev_ext_tbl_type,
    x_isev_ext_tbl                     OUT NOCOPY isev_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_isev_ext_tbl.COUNT > 0 THEN
      i := p_isev_ext_tbl.FIRST;
      LOOP
        CREATE_IA_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_isev_ext_tbl(i),
	    x_isev_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_isev_ext_tbl.LAST);
        i := p_isev_ext_tbl.NEXT(i);
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
  END CREATE_IA_STARTEND;

  PROCEDURE UPDATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	            IN isev_ext_rec_type,
    x_isev_ext_rec              OUT NOCOPY isev_ext_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_IA_STARTEND';
    l_return_status	  VARCHAR2(1);
    l_isev_ext_rec     isev_ext_rec_type := p_isev_ext_rec;
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
    g_isev_ext_rec := l_isev_ext_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_isev_ext_rec := migrate_isev(l_isev_ext_rec, g_isev_ext_rec);
    OKC_TIME_PVT.UPDATE_IA_STARTEND(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_isev_ext_rec,
       x_isev_ext_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_isev_ext_rec := x_isev_ext_rec;
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
  END UPDATE_IA_STARTEND;

  PROCEDURE UPDATE_IA_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_isev_ext_tbl                     IN isev_ext_tbl_type,
    x_isev_ext_tbl                     OUT NOCOPY isev_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_isev_ext_tbl.COUNT > 0 THEN
      i := p_isev_ext_tbl.FIRST;
      LOOP
        UPDATE_IA_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_isev_ext_tbl(i),
	    x_isev_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_isev_ext_tbl.LAST);
        i := p_isev_ext_tbl.NEXT(i);
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
  END UPDATE_IA_STARTEND;

  PROCEDURE DELETE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec              IN isev_ext_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_IA_STARTEND';
    l_return_status	  VARCHAR2(1);
    l_isev_ext_rec     isev_ext_rec_type := p_isev_ext_rec;
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
    g_isev_ext_rec := l_isev_ext_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_PVT.DELETE_IA_STARTEND(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_isev_ext_rec);
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
  END DELETE_IA_STARTEND;

  PROCEDURE DELETE_IA_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_isev_ext_tbl                     IN isev_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_isev_ext_tbl.COUNT > 0 THEN
      i := p_isev_ext_tbl.FIRST;
      LOOP
        DELETE_IA_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_isev_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_isev_ext_tbl.LAST);
        i := p_isev_ext_tbl.NEXT(i);
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
  END DELETE_IA_STARTEND;

  PROCEDURE LOCK_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec              IN isev_ext_rec_type) IS
  BEGIN
    OKC_TIME_PVT.LOCK_IA_STARTEND(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_isev_ext_rec);
  END LOCK_IA_STARTEND;

  PROCEDURE LOCK_IA_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_isev_ext_tbl                     IN isev_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_isev_ext_tbl.COUNT > 0 THEN
      i := p_isev_ext_tbl.FIRST;
      LOOP
        LOCK_IA_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_isev_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_isev_ext_tbl.LAST);
        i := p_isev_ext_tbl.NEXT(i);
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
  END LOCK_IA_STARTEND;

  PROCEDURE VALID_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_ext_rec_type) IS
  BEGIN
    OKC_TIME_PVT.VALID_IA_STARTEND(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_isev_ext_rec);
  END VALID_IA_STARTEND;

  PROCEDURE VALID_IA_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_isev_ext_tbl                     IN isev_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_isev_ext_tbl.COUNT > 0 THEN
      i := p_isev_ext_tbl.FIRST;
      LOOP
        VALID_IA_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_isev_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_isev_ext_tbl.LAST);
        i := p_isev_ext_tbl.NEXT(i);
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
  END VALID_IA_STARTEND;

  PROCEDURE CREATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	            IN isev_rel_rec_type,
    x_isev_rel_rec              OUT NOCOPY isev_rel_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_IA_STARTEND';
    l_return_status	  VARCHAR2(1);
    l_isev_rel_rec     isev_rel_rec_type := p_isev_rel_rec;
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
    g_isev_rel_rec := l_isev_rel_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_isev_rel_rec := migrate_isev(l_isev_rel_rec, g_isev_rel_rec);
    OKC_TIME_PVT.CREATE_IA_STARTEND(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_isev_rel_rec,
       x_isev_rel_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_isev_rel_rec := x_isev_rel_rec;
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
  END CREATE_IA_STARTEND;

  PROCEDURE CREATE_IA_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_isev_rel_tbl                     IN isev_rel_tbl_type,
    x_isev_rel_tbl                     OUT NOCOPY isev_rel_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_isev_rel_tbl.COUNT > 0 THEN
      i := p_isev_rel_tbl.FIRST;
      LOOP
        CREATE_IA_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_isev_rel_tbl(i),
	    x_isev_rel_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_isev_rel_tbl.LAST);
        i := p_isev_rel_tbl.Next(i);
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
  END CREATE_IA_STARTEND;

  PROCEDURE UPDATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	            IN isev_rel_rec_type,
    x_isev_rel_rec              OUT NOCOPY isev_rel_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_IA_STARTEND';
    l_return_status	  VARCHAR2(1);
    l_isev_rel_rec     isev_rel_rec_type := p_isev_rel_rec;
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
    g_isev_rel_rec := l_isev_rel_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_isev_rel_rec := migrate_isev(l_isev_rel_rec, g_isev_rel_rec);
    OKC_TIME_PVT.UPDATE_IA_STARTEND(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_isev_rel_rec,
       x_isev_rel_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_isev_rel_rec := x_isev_rel_rec;
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
  END UPDATE_IA_STARTEND;

  PROCEDURE UPDATE_IA_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_isev_rel_tbl                     IN isev_rel_tbl_type,
    x_isev_rel_tbl                     OUT NOCOPY isev_rel_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_isev_rel_tbl.COUNT > 0 THEN
      i := p_isev_rel_tbl.FIRST;
      LOOP
        UPDATE_IA_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_isev_rel_tbl(i),
	    x_isev_rel_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_isev_rel_tbl.LAST);
        i := p_isev_rel_tbl.Next(i);
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
  END UPDATE_IA_STARTEND;

  PROCEDURE DELETE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec              IN isev_rel_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_IA_STARTEND';
    l_return_status	  VARCHAR2(1);
    l_isev_rel_rec     isev_rel_rec_type := p_isev_rel_rec;
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
    g_isev_rel_rec := l_isev_rel_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_PVT.DELETE_IA_STARTEND(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_isev_rel_rec);
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
  END DELETE_IA_STARTEND;

  PROCEDURE DELETE_IA_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_isev_rel_tbl                     IN isev_rel_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_isev_rel_tbl.COUNT > 0 THEN
      i := p_isev_rel_tbl.FIRST;
      LOOP
        DELETE_IA_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_isev_rel_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_isev_rel_tbl.LAST);
        i := p_isev_rel_tbl.Next(i);
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
  END DELETE_IA_STARTEND;

  PROCEDURE LOCK_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec              IN isev_rel_rec_type) IS
  BEGIN
    OKC_TIME_PVT.LOCK_IA_STARTEND(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_isev_rel_rec);
  END LOCK_IA_STARTEND;

  PROCEDURE LOCK_IA_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_isev_rel_tbl                     IN isev_rel_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_isev_rel_tbl.COUNT > 0 THEN
      i := p_isev_rel_tbl.FIRST;
      LOOP
        LOCK_IA_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_isev_rel_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_isev_rel_tbl.LAST);
        i := p_isev_rel_tbl.Next(i);
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
  END LOCK_IA_STARTEND;

  PROCEDURE VALID_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_rel_rec_type) IS
  BEGIN
    OKC_TIME_PVT.VALID_IA_STARTEND(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_isev_rel_rec);
  END VALID_IA_STARTEND;

  PROCEDURE VALID_IA_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_isev_rel_tbl                     IN isev_rel_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_isev_rel_tbl.COUNT > 0 THEN
      i := p_isev_rel_tbl.FIRST;
      LOOP
        VALID_IA_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_isev_rel_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_isev_rel_tbl.LAST);
        i := p_isev_rel_tbl.Next(i);
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
  END VALID_IA_STARTEND;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_IG_STARTEND
 --------------------------------------------------------------------------

  FUNCTION migrate_igsv(p_igsv_ext_rec1 IN igsv_ext_rec_type,
                        p_igsv_ext_rec2 IN igsv_ext_rec_type)
    RETURN igsv_ext_rec_type IS
    l_igsv_ext_rec igsv_ext_rec_type;
  BEGIN
    l_igsv_ext_rec.id                    := p_igsv_ext_rec1.id;
    l_igsv_ext_rec.object_version_number := p_igsv_ext_rec1.object_version_number;
    l_igsv_ext_rec.created_by            := p_igsv_ext_rec1.created_by;
    l_igsv_ext_rec.creation_date         := p_igsv_ext_rec1.creation_date;
    l_igsv_ext_rec.last_updated_by       := p_igsv_ext_rec1.last_updated_by;
    l_igsv_ext_rec.last_update_date      := p_igsv_ext_rec1.last_update_date;
    l_igsv_ext_rec.last_update_login     := p_igsv_ext_rec1.last_update_login;
    l_igsv_ext_rec.tze_id := p_igsv_ext_rec2.tze_id;
    l_igsv_ext_rec.sfwt_flag             := p_igsv_ext_rec2.sfwt_flag;
    l_igsv_ext_rec.dnz_chr_id         := p_igsv_ext_rec2.dnz_chr_id;
    l_igsv_ext_rec.tve_id_limited        := p_igsv_ext_rec2.tve_id_limited;
    l_igsv_ext_rec.tve_id_started        := p_igsv_ext_rec2.tve_id_started;
    l_igsv_ext_rec.tve_id_ended          := p_igsv_ext_rec2.tve_id_ended;
    l_igsv_ext_rec.short_description     := p_igsv_ext_rec2.short_description;
    l_igsv_ext_rec.description           := p_igsv_ext_rec2.description;
    l_igsv_ext_rec.comments              := p_igsv_ext_rec2.comments;
    l_igsv_ext_rec.attribute_category    := p_igsv_ext_rec2.attribute_category;
    l_igsv_ext_rec.attribute1            := p_igsv_ext_rec2.attribute1;
    l_igsv_ext_rec.attribute2            := p_igsv_ext_rec2.attribute2;
    l_igsv_ext_rec.attribute3            := p_igsv_ext_rec2.attribute3;
    l_igsv_ext_rec.attribute4            := p_igsv_ext_rec2.attribute4;
    l_igsv_ext_rec.attribute5            := p_igsv_ext_rec2.attribute5;
    l_igsv_ext_rec.attribute6            := p_igsv_ext_rec2.attribute6;
    l_igsv_ext_rec.attribute7            := p_igsv_ext_rec2.attribute7;
    l_igsv_ext_rec.attribute8            := p_igsv_ext_rec2.attribute8;
    l_igsv_ext_rec.attribute9            := p_igsv_ext_rec2.attribute9;
    l_igsv_ext_rec.attribute10           := p_igsv_ext_rec2.attribute10;
    l_igsv_ext_rec.attribute11           := p_igsv_ext_rec2.attribute11;
    l_igsv_ext_rec.attribute12           := p_igsv_ext_rec2.attribute12;
    l_igsv_ext_rec.attribute13           := p_igsv_ext_rec2.attribute13;
    l_igsv_ext_rec.attribute14           := p_igsv_ext_rec2.attribute14;
    l_igsv_ext_rec.attribute15           := p_igsv_ext_rec2.attribute15;
    RETURN (l_igsv_ext_rec);
  END migrate_igsv;

  FUNCTION migrate_igsv(p_igsv_ext_tbl1 IN igsv_ext_tbl_type,
    p_igsv_ext_tbl2 IN igsv_ext_tbl_type)
    RETURN igsv_ext_tbl_type IS
    l_igsv_ext_tbl igsv_ext_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_igsv_ext_tbl1.COUNT <> p_igsv_ext_tbl2.COUNT THEN
      l_igsv_ext_tbl := p_igsv_ext_tbl1;
    ELSE
      IF (p_igsv_ext_tbl1.COUNT > 0) THEN
        i := p_igsv_ext_tbl1.FIRST;
        j := p_igsv_ext_tbl2.FIRST;
        LOOP
          l_igsv_ext_tbl(i) := migrate_igsv(p_igsv_ext_tbl1(i), p_igsv_ext_tbl2(j));
          EXIT WHEN (i = p_igsv_ext_tbl1.LAST);
          i := p_igsv_ext_tbl1.NEXT(i);
          j := p_igsv_ext_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_igsv_ext_tbl);
  END migrate_igsv;

  PROCEDURE CREATE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	            IN igsv_ext_rec_type,
    x_igsv_ext_rec              OUT NOCOPY igsv_ext_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_IG_STARTEND';
    l_return_status	  VARCHAR2(1);
    l_igsv_ext_rec     igsv_ext_rec_type := p_igsv_ext_rec;
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
    g_igsv_ext_rec := l_igsv_ext_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_igsv_ext_rec := migrate_igsv(l_igsv_ext_rec, g_igsv_ext_rec);
    OKC_TIME_PVT.CREATE_IG_STARTEND(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_igsv_ext_rec,
       x_igsv_ext_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_igsv_ext_rec := x_igsv_ext_rec;
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
  END CREATE_IG_STARTEND;

  PROCEDURE CREATE_IG_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_igsv_ext_tbl                     IN igsv_ext_tbl_type,
    x_igsv_ext_tbl                     OUT NOCOPY igsv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_igsv_ext_tbl.COUNT > 0 THEN
      i := p_igsv_ext_tbl.FIRST;
      LOOP
        CREATE_IG_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_igsv_ext_tbl(i),
	    x_igsv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_igsv_ext_tbl.LAST);
        i := p_igsv_ext_tbl.NEXT(i);
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
  END CREATE_IG_STARTEND;

  PROCEDURE UPDATE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	            IN igsv_ext_rec_type,
    x_igsv_ext_rec              OUT NOCOPY igsv_ext_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_IG_STARTEND';
    l_return_status	  VARCHAR2(1);
    l_igsv_ext_rec     igsv_ext_rec_type := p_igsv_ext_rec;
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
    g_igsv_ext_rec := l_igsv_ext_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_igsv_ext_rec := migrate_igsv(l_igsv_ext_rec, g_igsv_ext_rec);
    OKC_TIME_PVT.UPDATE_IG_STARTEND(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_igsv_ext_rec,
       x_igsv_ext_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_igsv_ext_rec := x_igsv_ext_rec;
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
  END UPDATE_IG_STARTEND;

  PROCEDURE UPDATE_IG_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_igsv_ext_tbl                     IN igsv_ext_tbl_type,
    x_igsv_ext_tbl                     OUT NOCOPY igsv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_igsv_ext_tbl.COUNT > 0 THEN
      i := p_igsv_ext_tbl.FIRST;
      LOOP
        UPDATE_IG_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_igsv_ext_tbl(i),
	    x_igsv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_igsv_ext_tbl.LAST);
        i := p_igsv_ext_tbl.NEXT(i);
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
  END UPDATE_IG_STARTEND;

  PROCEDURE DELETE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec              IN igsv_ext_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_IG_STARTEND';
    l_return_status	  VARCHAR2(1);
    l_igsv_ext_rec     igsv_ext_rec_type := p_igsv_ext_rec;
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
    g_igsv_ext_rec := l_igsv_ext_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_PVT.DELETE_IG_STARTEND(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_igsv_ext_rec);
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
  END DELETE_IG_STARTEND;

  PROCEDURE DELETE_IG_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_igsv_ext_tbl                     IN igsv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_igsv_ext_tbl.COUNT > 0 THEN
      i := p_igsv_ext_tbl.FIRST;
      LOOP
        DELETE_IG_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_igsv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_igsv_ext_tbl.LAST);
        i := p_igsv_ext_tbl.NEXT(i);
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
  END DELETE_IG_STARTEND;

  PROCEDURE LOCK_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec		    IN igsv_ext_rec_type) IS
  BEGIN
    OKC_TIME_PVT.LOCK_IG_STARTEND(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_igsv_ext_rec);
  END LOCK_IG_STARTEND;

  PROCEDURE LOCK_IG_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_igsv_ext_tbl                     IN igsv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_igsv_ext_tbl.COUNT > 0 THEN
      i := p_igsv_ext_tbl.FIRST;
      LOOP
        LOCK_IG_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_igsv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_igsv_ext_tbl.LAST);
        i := p_igsv_ext_tbl.NEXT(i);
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
  END LOCK_IG_STARTEND;

  PROCEDURE VALID_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec		    IN igsv_ext_rec_type) IS
  BEGIN
    OKC_TIME_PVT.VALID_IG_STARTEND(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_igsv_ext_rec);
  END VALID_IG_STARTEND;

  PROCEDURE VALID_IG_STARTEND(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_igsv_ext_tbl                     IN igsv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_igsv_ext_tbl.COUNT > 0 THEN
      i := p_igsv_ext_tbl.FIRST;
      LOOP
        VALID_IG_STARTEND(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_igsv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_igsv_ext_tbl.LAST);
        i := p_igsv_ext_tbl.NEXT(i);
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
  END VALID_IG_STARTEND;

---The following procedures cater to handling of OKC_TIME_CYCLE
 --------------------------------------------------------------------------

  FUNCTION migrate_cylv(p_cylv_ext_rec1 IN cylv_ext_rec_type,
                        p_cylv_ext_rec2 IN cylv_ext_rec_type)
    RETURN cylv_ext_rec_type IS
    l_cylv_ext_rec cylv_ext_rec_type;
  BEGIN
    l_cylv_ext_rec.id                    := p_cylv_ext_rec1.id;
    l_cylv_ext_rec.object_version_number := p_cylv_ext_rec1.object_version_number;
    l_cylv_ext_rec.created_by            := p_cylv_ext_rec1.created_by;
    l_cylv_ext_rec.creation_date         := p_cylv_ext_rec1.creation_date;
    l_cylv_ext_rec.last_updated_by       := p_cylv_ext_rec1.last_updated_by;
    l_cylv_ext_rec.last_update_date      := p_cylv_ext_rec1.last_update_date;
    l_cylv_ext_rec.last_update_login     := p_cylv_ext_rec1.last_update_login;
    l_cylv_ext_rec.tve_id_limited         := p_cylv_ext_rec2.tve_id_limited;
    l_cylv_ext_rec.limited_start_date        := p_cylv_ext_rec2.limited_start_date;
    l_cylv_ext_rec.limited_end_date        := p_cylv_ext_rec2.limited_end_date;
    l_cylv_ext_rec.tze_id := p_cylv_ext_rec2.tze_id;
    l_cylv_ext_rec.name              := p_cylv_ext_rec2.name;
    l_cylv_ext_rec.interval_yn          := p_cylv_ext_rec2.interval_yn;
    l_cylv_ext_rec.active_yn          := p_cylv_ext_rec2.active_yn;
    l_cylv_ext_rec.uom_code          := p_cylv_ext_rec2.uom_code;
    l_cylv_ext_rec.duration          := p_cylv_ext_rec2.duration;
    l_cylv_ext_rec.spn_id                := p_cylv_ext_rec2.spn_id;
    l_cylv_ext_rec.sfwt_flag             := p_cylv_ext_rec2.sfwt_flag;
    l_cylv_ext_rec.short_description     := p_cylv_ext_rec2.short_description;
    l_cylv_ext_rec.description           := p_cylv_ext_rec2.description;
    l_cylv_ext_rec.comments              := p_cylv_ext_rec2.comments;
    l_cylv_ext_rec.attribute_category    := p_cylv_ext_rec2.attribute_category;
    l_cylv_ext_rec.attribute1            := p_cylv_ext_rec2.attribute1;
    l_cylv_ext_rec.attribute2            := p_cylv_ext_rec2.attribute2;
    l_cylv_ext_rec.attribute3            := p_cylv_ext_rec2.attribute3;
    l_cylv_ext_rec.attribute4            := p_cylv_ext_rec2.attribute4;
    l_cylv_ext_rec.attribute5            := p_cylv_ext_rec2.attribute5;
    l_cylv_ext_rec.attribute6            := p_cylv_ext_rec2.attribute6;
    l_cylv_ext_rec.attribute7            := p_cylv_ext_rec2.attribute7;
    l_cylv_ext_rec.attribute8            := p_cylv_ext_rec2.attribute8;
    l_cylv_ext_rec.attribute9            := p_cylv_ext_rec2.attribute9;
    l_cylv_ext_rec.attribute10           := p_cylv_ext_rec2.attribute10;
    l_cylv_ext_rec.attribute11           := p_cylv_ext_rec2.attribute11;
    l_cylv_ext_rec.attribute12           := p_cylv_ext_rec2.attribute12;
    l_cylv_ext_rec.attribute13           := p_cylv_ext_rec2.attribute13;
    l_cylv_ext_rec.attribute14           := p_cylv_ext_rec2.attribute14;
    l_cylv_ext_rec.attribute15           := p_cylv_ext_rec2.attribute15;
    RETURN (l_cylv_ext_rec);
  END migrate_cylv;

  FUNCTION migrate_cylv(p_cylv_ext_tbl1 IN cylv_ext_tbl_type,
    p_cylv_ext_tbl2 IN cylv_ext_tbl_type)
    RETURN cylv_ext_tbl_type IS
    l_cylv_ext_tbl cylv_ext_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_cylv_ext_tbl1.COUNT <> p_cylv_ext_tbl2.COUNT THEN
      l_cylv_ext_tbl := p_cylv_ext_tbl1;
    ELSE
      IF (p_cylv_ext_tbl1.COUNT > 0) THEN
        i := p_cylv_ext_tbl1.FIRST;
        j := p_cylv_ext_tbl2.FIRST;
        LOOP
          l_cylv_ext_tbl(i) := migrate_cylv(p_cylv_ext_tbl1(i), p_cylv_ext_tbl2(j));
          EXIT WHEN (i = p_cylv_ext_tbl1.LAST);
          i := p_cylv_ext_tbl1.NEXT(i);
          j := p_cylv_ext_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_cylv_ext_tbl);
  END migrate_cylv;

  PROCEDURE CREATE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec	            IN cylv_ext_rec_type,
    x_cylv_ext_rec              OUT NOCOPY cylv_ext_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_CYCLE';
    l_return_status	  VARCHAR2(1);
    l_cylv_ext_rec     cylv_ext_rec_type := p_cylv_ext_rec;
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
    g_cylv_ext_rec := l_cylv_ext_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_cylv_ext_rec := migrate_cylv(l_cylv_ext_rec, g_cylv_ext_rec);
    OKC_TIME_PVT.CREATE_CYCLE(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_cylv_ext_rec,
       x_cylv_ext_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_cylv_ext_rec := x_cylv_ext_rec;
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
  END CREATE_CYCLE;

  PROCEDURE CREATE_CYCLE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cylv_ext_tbl                     IN cylv_ext_tbl_type,
    x_cylv_ext_tbl                     OUT NOCOPY cylv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cylv_ext_tbl.COUNT > 0 THEN
      i := p_cylv_ext_tbl.FIRST;
      LOOP
        CREATE_CYCLE(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cylv_ext_tbl(i),
	    x_cylv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cylv_ext_tbl.LAST);
        i := p_cylv_ext_tbl.NEXT(i);
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
  END CREATE_CYCLE;

  PROCEDURE UPDATE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec	            IN cylv_ext_rec_type,
    x_cylv_ext_rec              OUT NOCOPY cylv_ext_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_CYCLE';
    l_return_status	  VARCHAR2(1);
    l_cylv_ext_rec     cylv_ext_rec_type := p_cylv_ext_rec;
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
    g_cylv_ext_rec := l_cylv_ext_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_cylv_ext_rec := migrate_cylv(l_cylv_ext_rec, g_cylv_ext_rec);
    OKC_TIME_PVT.UPDATE_CYCLE(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_cylv_ext_rec,
       x_cylv_ext_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_cylv_ext_rec := x_cylv_ext_rec;
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
  END UPDATE_CYCLE;

  PROCEDURE UPDATE_CYCLE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cylv_ext_tbl                     IN cylv_ext_tbl_type,
    x_cylv_ext_tbl                     OUT NOCOPY cylv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cylv_ext_tbl.COUNT > 0 THEN
      i := p_cylv_ext_tbl.FIRST;
      LOOP
        UPDATE_CYCLE(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cylv_ext_tbl(i),
	    x_cylv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cylv_ext_tbl.LAST);
        i := p_cylv_ext_tbl.NEXT(i);
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
  END UPDATE_CYCLE;

  PROCEDURE DELETE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec              IN cylv_ext_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_CYCLE';
    l_return_status	  VARCHAR2(1);
    l_cylv_ext_rec     cylv_ext_rec_type := p_cylv_ext_rec;
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
    g_cylv_ext_rec := l_cylv_ext_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_PVT.DELETE_CYCLE(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_cylv_ext_rec);
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
  END DELETE_CYCLE;

  PROCEDURE DELETE_CYCLE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cylv_ext_tbl                     IN cylv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cylv_ext_tbl.COUNT > 0 THEN
      i := p_cylv_ext_tbl.FIRST;
      LOOP
        DELETE_CYCLE(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cylv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cylv_ext_tbl.LAST);
        i := p_cylv_ext_tbl.NEXT(i);
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
  END DELETE_CYCLE;

  PROCEDURE LOCK_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec		    IN cylv_ext_rec_type) IS
  BEGIN
    OKC_TIME_PVT.LOCK_CYCLE(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cylv_ext_rec);
  END LOCK_CYCLE;

  PROCEDURE LOCK_CYCLE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cylv_ext_tbl                     IN cylv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cylv_ext_tbl.COUNT > 0 THEN
      i := p_cylv_ext_tbl.FIRST;
      LOOP
        LOCK_CYCLE(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cylv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cylv_ext_tbl.LAST);
        i := p_cylv_ext_tbl.NEXT(i);
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
  END LOCK_CYCLE;

  PROCEDURE VALID_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec		    IN cylv_ext_rec_type) IS
  BEGIN
    OKC_TIME_PVT.VALID_CYCLE(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cylv_ext_rec);
  END VALID_CYCLE;

  PROCEDURE VALID_CYCLE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cylv_ext_tbl                     IN cylv_ext_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cylv_ext_tbl.COUNT > 0 THEN
      i := p_cylv_ext_tbl.FIRST;
      LOOP
        VALID_CYCLE(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cylv_ext_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cylv_ext_tbl.LAST);
        i := p_cylv_ext_tbl.NEXT(i);
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
  END VALID_CYCLE;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_SPAN
 --------------------------------------------------------------------------

  FUNCTION migrate_spnv(p_spnv_rec1 IN spnv_rec_type,
                        p_spnv_rec2 IN spnv_rec_type)
    RETURN spnv_rec_type IS
    l_spnv_rec spnv_rec_type;
  BEGIN
    l_spnv_rec.id                    := p_spnv_rec1.id;
    l_spnv_rec.object_version_number := p_spnv_rec1.object_version_number;
    l_spnv_rec.created_by            := p_spnv_rec1.created_by;
    l_spnv_rec.creation_date         := p_spnv_rec1.creation_date;
    l_spnv_rec.last_updated_by       := p_spnv_rec1.last_updated_by;
    l_spnv_rec.last_update_date      := p_spnv_rec1.last_update_date;
    l_spnv_rec.last_update_login     := p_spnv_rec1.last_update_login;
    l_spnv_rec.tve_id                := p_spnv_rec2.tve_id;
    l_spnv_rec.spn_id                := p_spnv_rec2.spn_id;
    l_spnv_rec.uom_code  := p_spnv_rec2.uom_code;
    l_spnv_rec.name                  := p_spnv_rec2.name;
    l_spnv_rec.duration              := p_spnv_rec2.duration;
    l_spnv_rec.active_yn             := p_spnv_rec2.active_yn;
    RETURN (l_spnv_rec);
  END migrate_spnv;

  FUNCTION migrate_spnv(p_spnv_tbl1 IN spnv_tbl_type,
    p_spnv_tbl2 IN spnv_tbl_type)
    RETURN spnv_tbl_type IS
    l_spnv_tbl spnv_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_spnv_tbl1.COUNT <> p_spnv_tbl2.COUNT THEN
      l_spnv_tbl := p_spnv_tbl1;
    ELSE
      IF (p_spnv_tbl1.COUNT > 0) THEN
        i := p_spnv_tbl1.FIRST;
        j := p_spnv_tbl2.FIRST;
        LOOP
          l_spnv_tbl(i) := migrate_spnv(p_spnv_tbl1(i), p_spnv_tbl2(j));
          EXIT WHEN (i = p_spnv_tbl1.LAST);
          i := p_spnv_tbl1.NEXT(i);
          j := p_spnv_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_spnv_tbl);
  END migrate_spnv;

  PROCEDURE CREATE_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec	            IN spnv_rec_type,
    x_spnv_rec              OUT NOCOPY spnv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_SPAN';
    l_return_status	  VARCHAR2(1);
    l_spnv_rec     spnv_rec_type := p_spnv_rec;
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
    g_spnv_rec := l_spnv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_spnv_rec := migrate_spnv(l_spnv_rec, g_spnv_rec);
    OKC_TIME_PVT.CREATE_SPAN(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_spnv_rec,
       x_spnv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_spnv_rec := x_spnv_rec;
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
  END CREATE_SPAN;

  PROCEDURE CREATE_SPAN(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_tbl                     IN spnv_tbl_type,
    x_spnv_tbl                     OUT NOCOPY spnv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_spnv_tbl.COUNT > 0 THEN
      i := p_spnv_tbl.FIRST;
      LOOP
        CREATE_SPAN(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_spnv_tbl(i),
	    x_spnv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_spnv_tbl.LAST);
        i := p_spnv_tbl.NEXT(i);
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
  END CREATE_SPAN;

  PROCEDURE UPDATE_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec	            IN spnv_rec_type,
    x_spnv_rec              OUT NOCOPY spnv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_SPAN';
    l_return_status	  VARCHAR2(1);
    l_spnv_rec     spnv_rec_type := p_spnv_rec;
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
    g_spnv_rec := l_spnv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_spnv_rec := migrate_spnv(l_spnv_rec, g_spnv_rec);
    OKC_TIME_PVT.UPDATE_SPAN(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_spnv_rec,
       x_spnv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_spnv_rec := x_spnv_rec;
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
  END UPDATE_SPAN;

  PROCEDURE UPDATE_SPAN(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_tbl                     IN spnv_tbl_type,
    x_spnv_tbl                     OUT NOCOPY spnv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_spnv_tbl.COUNT > 0 THEN
      i := p_spnv_tbl.FIRST;
      LOOP
        UPDATE_SPAN(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_spnv_tbl(i),
	    x_spnv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_spnv_tbl.LAST);
        i := p_spnv_tbl.NEXT(i);
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
  END UPDATE_SPAN;

  PROCEDURE DELETE_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec              IN spnv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_SPAN';
    l_return_status	  VARCHAR2(1);
    l_spnv_rec     spnv_rec_type := p_spnv_rec;
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
    g_spnv_rec := l_spnv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_PVT.DELETE_SPAN(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_spnv_rec);
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
  END DELETE_SPAN;

  PROCEDURE DELETE_SPAN(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_tbl                     IN spnv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_spnv_tbl.COUNT > 0 THEN
      i := p_spnv_tbl.FIRST;
      LOOP
        DELETE_SPAN(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_spnv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_spnv_tbl.LAST);
        i := p_spnv_tbl.NEXT(i);
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
  END DELETE_SPAN;

  PROCEDURE LOCK_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec		    IN spnv_rec_type) IS
  BEGIN
    OKC_TIME_PVT.LOCK_SPAN(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_spnv_rec);
  END LOCK_SPAN;

  PROCEDURE LOCK_SPAN(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_tbl                     IN spnv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_spnv_tbl.COUNT > 0 THEN
      i := p_spnv_tbl.FIRST;
      LOOP
        LOCK_SPAN(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_spnv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_spnv_tbl.LAST);
        i := p_spnv_tbl.NEXT(i);
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
  END LOCK_SPAN;

  PROCEDURE VALID_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec		    IN spnv_rec_type) IS
  BEGIN
    OKC_TIME_PVT.VALID_SPAN(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_spnv_rec);
  END VALID_SPAN;

  PROCEDURE VALID_SPAN(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_tbl                     IN spnv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_spnv_tbl.COUNT > 0 THEN
      i := p_spnv_tbl.FIRST;
      LOOP
        VALID_SPAN(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_spnv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_spnv_tbl.LAST);
        i := p_spnv_tbl.NEXT(i);
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
  END VALID_SPAN;
 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TIME_CODE_UNITS
 --------------------------------------------------------------------------

  FUNCTION migrate_tcuv(p_tcuv_rec1 IN tcuv_rec_type,
                        p_tcuv_rec2 IN tcuv_rec_type)
    RETURN tcuv_rec_type IS
    l_tcuv_rec tcuv_rec_type;
  BEGIN
    l_tcuv_rec.tce_code              := p_tcuv_rec2.tce_code;
    l_tcuv_rec.uom_code              := p_tcuv_rec2.uom_code;
    l_tcuv_rec.quantity              := p_tcuv_rec2.quantity;
    l_tcuv_rec.active_flag           := p_tcuv_rec2.active_flag;
    l_tcuv_rec.object_version_number := p_tcuv_rec1.object_version_number;
    l_tcuv_rec.created_by            := p_tcuv_rec1.created_by;
    l_tcuv_rec.creation_date         := p_tcuv_rec1.creation_date;
    l_tcuv_rec.last_updated_by       := p_tcuv_rec1.last_updated_by;
    l_tcuv_rec.last_update_date      := p_tcuv_rec1.last_update_date;
    l_tcuv_rec.last_update_login     := p_tcuv_rec1.last_update_login;
    l_tcuv_rec.sfwt_flag             := p_tcuv_rec2.sfwt_flag;
    l_tcuv_rec.short_description     := p_tcuv_rec2.short_description;
    l_tcuv_rec.description           := p_tcuv_rec2.description;
    l_tcuv_rec.comments              := p_tcuv_rec2.comments;
    l_tcuv_rec.attribute_category    := p_tcuv_rec2.attribute_category;
    l_tcuv_rec.attribute1            := p_tcuv_rec2.attribute1;
    l_tcuv_rec.attribute2            := p_tcuv_rec2.attribute2;
    l_tcuv_rec.attribute3            := p_tcuv_rec2.attribute3;
    l_tcuv_rec.attribute4            := p_tcuv_rec2.attribute4;
    l_tcuv_rec.attribute5            := p_tcuv_rec2.attribute5;
    l_tcuv_rec.attribute6            := p_tcuv_rec2.attribute6;
    l_tcuv_rec.attribute7            := p_tcuv_rec2.attribute7;
    l_tcuv_rec.attribute8            := p_tcuv_rec2.attribute8;
    l_tcuv_rec.attribute9            := p_tcuv_rec2.attribute9;
    l_tcuv_rec.attribute10           := p_tcuv_rec2.attribute10;
    l_tcuv_rec.attribute11           := p_tcuv_rec2.attribute11;
    l_tcuv_rec.attribute12           := p_tcuv_rec2.attribute12;
    l_tcuv_rec.attribute13           := p_tcuv_rec2.attribute13;
    l_tcuv_rec.attribute14           := p_tcuv_rec2.attribute14;
    l_tcuv_rec.attribute15           := p_tcuv_rec2.attribute15;
    RETURN (l_tcuv_rec);
  END migrate_tcuv;

  FUNCTION migrate_tcuv(p_tcuv_tbl1 IN tcuv_tbl_type,
    p_tcuv_tbl2 IN tcuv_tbl_type)
    RETURN tcuv_tbl_type IS
    l_tcuv_tbl tcuv_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_tcuv_tbl1.COUNT <> p_tcuv_tbl2.COUNT THEN
      l_tcuv_tbl := p_tcuv_tbl1;
    ELSE
      IF (p_tcuv_tbl1.COUNT > 0) THEN
        i := p_tcuv_tbl1.FIRST;
        j := p_tcuv_tbl2.FIRST;
        LOOP
          l_tcuv_tbl(i) := migrate_tcuv(p_tcuv_tbl1(i), p_tcuv_tbl2(j));
          EXIT WHEN (i = p_tcuv_tbl1.LAST);
          i := p_tcuv_tbl1.NEXT(i);
          j := p_tcuv_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_tcuv_tbl);
  END migrate_tcuv;

  PROCEDURE CREATE_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec	            IN tcuv_rec_type,
    x_tcuv_rec              OUT NOCOPY tcuv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_TIME_CODE_UNITS';
    l_return_status	  VARCHAR2(1);
    l_tcuv_rec     tcuv_rec_type := p_tcuv_rec;
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
    g_tcuv_rec := l_tcuv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_tcuv_rec := migrate_tcuv(l_tcuv_rec, g_tcuv_rec);
    OKC_TIME_PVT.CREATE_TIME_CODE_UNITS(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_tcuv_rec,
       x_tcuv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_tcuv_rec := x_tcuv_rec;
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
  END CREATE_TIME_CODE_UNITS;

  PROCEDURE CREATE_TIME_CODE_UNITS(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type,
    x_tcuv_tbl                     OUT NOCOPY tcuv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tcuv_tbl.COUNT > 0 THEN
      i := p_tcuv_tbl.FIRST;
      LOOP
        CREATE_TIME_CODE_UNITS(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tcuv_tbl(i),
	    x_tcuv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tcuv_tbl.LAST);
        i := p_tcuv_tbl.NEXT(i);
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
  END CREATE_TIME_CODE_UNITS;

  PROCEDURE UPDATE_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec	            IN tcuv_rec_type,
    x_tcuv_rec              OUT NOCOPY tcuv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_TIME_CODE_UNITS';
    l_return_status	  VARCHAR2(1);
    l_tcuv_rec     tcuv_rec_type := p_tcuv_rec;
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
    g_tcuv_rec := l_tcuv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_tcuv_rec := migrate_tcuv(l_tcuv_rec, g_tcuv_rec);
    OKC_TIME_PVT.UPDATE_TIME_CODE_UNITS(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_tcuv_rec,
       x_tcuv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_tcuv_rec := x_tcuv_rec;
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
  END UPDATE_TIME_CODE_UNITS;

  PROCEDURE UPDATE_TIME_CODE_UNITS(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type,
    x_tcuv_tbl                     OUT NOCOPY tcuv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tcuv_tbl.COUNT > 0 THEN
      i := p_tcuv_tbl.FIRST;
      LOOP
        UPDATE_TIME_CODE_UNITS(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tcuv_tbl(i),
	    x_tcuv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tcuv_tbl.LAST);
        i := p_tcuv_tbl.NEXT(i);
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
  END UPDATE_TIME_CODE_UNITS;

  PROCEDURE DELETE_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec              IN tcuv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_TIME_CODE_UNITS';
    l_return_status	  VARCHAR2(1);
    l_tcuv_rec     tcuv_rec_type := p_tcuv_rec;
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
    g_tcuv_rec := l_tcuv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_PVT.DELETE_TIME_CODE_UNITS(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_tcuv_rec);
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
  END DELETE_TIME_CODE_UNITS;

  PROCEDURE DELETE_TIME_CODE_UNITS(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tcuv_tbl.COUNT > 0 THEN
      i := p_tcuv_tbl.FIRST;
      LOOP
        DELETE_TIME_CODE_UNITS(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tcuv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tcuv_tbl.LAST);
        i := p_tcuv_tbl.NEXT(i);
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
  END DELETE_TIME_CODE_UNITS;

  PROCEDURE LOCK_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec		    IN tcuv_rec_type) IS
  BEGIN
    OKC_TIME_PVT.LOCK_TIME_CODE_UNITS(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_tcuv_rec);
  END LOCK_TIME_CODE_UNITS;

  PROCEDURE LOCK_TIME_CODE_UNITS(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tcuv_tbl.COUNT > 0 THEN
      i := p_tcuv_tbl.FIRST;
      LOOP
        LOCK_TIME_CODE_UNITS(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tcuv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tcuv_tbl.LAST);
        i := p_tcuv_tbl.NEXT(i);
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
  END LOCK_TIME_CODE_UNITS;

  PROCEDURE VALID_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec		    IN tcuv_rec_type) IS
  BEGIN
    OKC_TIME_PVT.VALID_TIME_CODE_UNITS(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_tcuv_rec);
  END VALID_TIME_CODE_UNITS;

  PROCEDURE VALID_TIME_CODE_UNITS(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_tcuv_tbl.COUNT > 0 THEN
      i := p_tcuv_tbl.FIRST;
      LOOP
        VALID_TIME_CODE_UNITS(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_tcuv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_tcuv_tbl.LAST);
        i := p_tcuv_tbl.NEXT(i);
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
  END VALID_TIME_CODE_UNITS;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_RESOLVED_TIMEVALUES
 --------------------------------------------------------------------------

  FUNCTION migrate_rtvv(p_rtvv_rec1 IN rtvv_rec_type,
                        p_rtvv_rec2 IN rtvv_rec_type)
    RETURN rtvv_rec_type IS
    l_rtvv_rec rtvv_rec_type;
  BEGIN
    l_rtvv_rec.coe_id                := p_rtvv_rec2.coe_id;
    l_rtvv_rec.tve_id                := p_rtvv_rec2.tve_id;
    l_rtvv_rec.datetime                := p_rtvv_rec2.datetime;
    l_rtvv_rec.id               := p_rtvv_rec1.id;
    l_rtvv_rec.object_version_number := p_rtvv_rec1.object_version_number;
    l_rtvv_rec.created_by            := p_rtvv_rec1.created_by;
    l_rtvv_rec.creation_date         := p_rtvv_rec1.creation_date;
    l_rtvv_rec.last_updated_by       := p_rtvv_rec1.last_updated_by;
    l_rtvv_rec.last_update_date      := p_rtvv_rec1.last_update_date;
    l_rtvv_rec.last_update_login     := p_rtvv_rec1.last_update_login;
    RETURN (l_rtvv_rec);
  END migrate_rtvv;

  FUNCTION migrate_rtvv(p_rtvv_tbl1 IN rtvv_tbl_type,
    p_rtvv_tbl2 IN rtvv_tbl_type)
    RETURN rtvv_tbl_type IS
    l_rtvv_tbl rtvv_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_rtvv_tbl1.COUNT <> p_rtvv_tbl2.COUNT THEN
      l_rtvv_tbl := p_rtvv_tbl1;
    ELSE
      IF (p_rtvv_tbl1.COUNT > 0) THEN
        i := p_rtvv_tbl1.FIRST;
        j := p_rtvv_tbl2.FIRST;
        LOOP
          l_rtvv_tbl(i) := migrate_rtvv(p_rtvv_tbl1(i), p_rtvv_tbl2(j));
          EXIT WHEN (i = p_rtvv_tbl1.LAST);
          i := p_rtvv_tbl1.NEXT(i);
          j := p_rtvv_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_rtvv_tbl);
  END migrate_rtvv;

  PROCEDURE CREATE_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec	            IN rtvv_rec_type,
    x_rtvv_rec              OUT NOCOPY rtvv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_RESOLVED_TIMEVALUES';
    l_return_status	  VARCHAR2(1);
    l_rtvv_rec     rtvv_rec_type := p_rtvv_rec;
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
    g_rtvv_rec := l_rtvv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rtvv_rec := migrate_rtvv(l_rtvv_rec, g_rtvv_rec);
    OKC_TIME_PVT.CREATE_RESOLVED_TIMEVALUES(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_rtvv_rec,
       x_rtvv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_rtvv_rec := x_rtvv_rec;
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
  END CREATE_RESOLVED_TIMEVALUES;

  PROCEDURE CREATE_RESOLVED_TIMEVALUES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtvv_tbl                     IN rtvv_tbl_type,
    x_rtvv_tbl                     OUT NOCOPY rtvv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rtvv_tbl.COUNT > 0 THEN
      i := p_rtvv_tbl.FIRST;
      LOOP
        CREATE_RESOLVED_TIMEVALUES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_rtvv_tbl(i),
	    x_rtvv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rtvv_tbl.LAST);
        i := p_rtvv_tbl.NEXT(i);
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
  END CREATE_RESOLVED_TIMEVALUES;

  PROCEDURE UPDATE_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec	            IN rtvv_rec_type,
    x_rtvv_rec              OUT NOCOPY rtvv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_RESOLVED_TIMEVALUES';
    l_return_status	  VARCHAR2(1);
    l_rtvv_rec     rtvv_rec_type := p_rtvv_rec;
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
    g_rtvv_rec := l_rtvv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rtvv_rec := migrate_rtvv(l_rtvv_rec, g_rtvv_rec);
    OKC_TIME_PVT.UPDATE_RESOLVED_TIMEVALUES(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_rtvv_rec,
       x_rtvv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_rtvv_rec := x_rtvv_rec;
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
  END UPDATE_RESOLVED_TIMEVALUES;

  PROCEDURE UPDATE_RESOLVED_TIMEVALUES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtvv_tbl                     IN rtvv_tbl_type,
    x_rtvv_tbl                     OUT NOCOPY rtvv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rtvv_tbl.COUNT > 0 THEN
      i := p_rtvv_tbl.FIRST;
      LOOP
        UPDATE_RESOLVED_TIMEVALUES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_rtvv_tbl(i),
	    x_rtvv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rtvv_tbl.LAST);
        i := p_rtvv_tbl.NEXT(i);
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
  END UPDATE_RESOLVED_TIMEVALUES;

  PROCEDURE DELETE_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec              IN rtvv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_RESOLVED_TIMEVALUES';
    l_return_status	  VARCHAR2(1);
    l_rtvv_rec     rtvv_rec_type := p_rtvv_rec;
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
    g_rtvv_rec := l_rtvv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_PVT.DELETE_RESOLVED_TIMEVALUES(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_rtvv_rec);
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
  END DELETE_RESOLVED_TIMEVALUES;

  PROCEDURE DELETE_RESOLVED_TIMEVALUES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtvv_tbl                     IN rtvv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rtvv_tbl.COUNT > 0 THEN
      i := p_rtvv_tbl.FIRST;
      LOOP
        DELETE_RESOLVED_TIMEVALUES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_rtvv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rtvv_tbl.LAST);
        i := p_rtvv_tbl.NEXT(i);
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
  END DELETE_RESOLVED_TIMEVALUES;

  PROCEDURE LOCK_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec		    IN rtvv_rec_type) IS
  BEGIN
    OKC_TIME_PVT.LOCK_RESOLVED_TIMEVALUES(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rtvv_rec);
  END LOCK_RESOLVED_TIMEVALUES;

  PROCEDURE LOCK_RESOLVED_TIMEVALUES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtvv_tbl                     IN rtvv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rtvv_tbl.COUNT > 0 THEN
      i := p_rtvv_tbl.FIRST;
      LOOP
        LOCK_RESOLVED_TIMEVALUES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_rtvv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rtvv_tbl.LAST);
        i := p_rtvv_tbl.NEXT(i);
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
  END LOCK_RESOLVED_TIMEVALUES;

  PROCEDURE VALID_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec		    IN rtvv_rec_type) IS
  BEGIN
    OKC_TIME_PVT.VALID_RESOLVED_TIMEVALUES(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rtvv_rec);
  END VALID_RESOLVED_TIMEVALUES;

  PROCEDURE VALID_RESOLVED_TIMEVALUES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtvv_tbl                     IN rtvv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rtvv_tbl.COUNT > 0 THEN
      i := p_rtvv_tbl.FIRST;
      LOOP
        VALID_RESOLVED_TIMEVALUES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_rtvv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rtvv_tbl.LAST);
        i := p_rtvv_tbl.NEXT(i);
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
  END VALID_RESOLVED_TIMEVALUES;
END OKC_TIME_PUB;

/
