--------------------------------------------------------
--  DDL for Package Body OKC_LINE_STYLES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_LINE_STYLES_PUB" AS
/* $Header: OKCPLSEB.pls 120.0 2005/05/25 19:27:21 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

G_EXCEPTION_HALT_PROCESSING   EXCEPTION;
 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_LINE_STYLES
 --------------------------------------------------------------------------

  FUNCTION migrate_lsev(p_lsev_rec1 IN lsev_rec_type,
                        p_lsev_rec2 IN lsev_rec_type)
    RETURN lsev_rec_type IS
    l_lsev_rec lsev_rec_type;
  BEGIN
    l_lsev_rec.id := p_lsev_rec1.id;
    l_lsev_rec.lty_code := p_lsev_rec2.lty_code;
    l_lsev_rec.priced_yn := p_lsev_rec2.priced_yn;
    l_lsev_rec.recursive_yn := p_lsev_rec2.recursive_yn;
    l_lsev_rec.protected_yn := p_lsev_rec2.protected_yn;
    l_lsev_rec.lse_parent_id := p_lsev_rec1.lse_parent_id;
    l_lsev_rec.application_id := p_lsev_rec2.application_id;
    l_lsev_rec.lse_type := p_lsev_rec2.lse_type;
    l_lsev_rec.object_version_number := p_lsev_rec1.object_version_number;
    l_lsev_rec.created_by := p_lsev_rec1.created_by;
    l_lsev_rec.creation_date := p_lsev_rec1.creation_date;
    l_lsev_rec.last_updated_by := p_lsev_rec1.last_updated_by;
    l_lsev_rec.last_update_date := p_lsev_rec1.last_update_date;
    l_lsev_rec.last_update_login := p_lsev_rec1.last_update_login;
    l_lsev_rec.attribute_category := p_lsev_rec2.attribute_category;
    l_lsev_rec.attribute1 := p_lsev_rec2.attribute1;
    l_lsev_rec.attribute2 := p_lsev_rec2.attribute2;
    l_lsev_rec.attribute3 := p_lsev_rec2.attribute3;
    l_lsev_rec.attribute4 := p_lsev_rec2.attribute4;
    l_lsev_rec.attribute5 := p_lsev_rec2.attribute5;
    l_lsev_rec.attribute6 := p_lsev_rec2.attribute6;
    l_lsev_rec.attribute7 := p_lsev_rec2.attribute7;
    l_lsev_rec.attribute8 := p_lsev_rec2.attribute8;
    l_lsev_rec.attribute9 := p_lsev_rec2.attribute9;
    l_lsev_rec.attribute10 := p_lsev_rec2.attribute10;
    l_lsev_rec.attribute11 := p_lsev_rec2.attribute11;
    l_lsev_rec.attribute12 := p_lsev_rec2.attribute12;
    l_lsev_rec.attribute13 := p_lsev_rec2.attribute13;
    l_lsev_rec.attribute14 := p_lsev_rec2.attribute14;
    l_lsev_rec.attribute15 := p_lsev_rec2.attribute15;
    l_lsev_rec.item_to_price_yn := p_lsev_rec2.item_to_price_yn;
    l_lsev_rec.price_basis_yn   := p_lsev_rec2.price_basis_yn;
    l_lsev_rec.access_level     := p_lsev_rec2.access_level;
    l_lsev_rec.service_item_yn     := p_lsev_rec2.service_item_yn;
    RETURN (l_lsev_rec);
  END migrate_lsev;

  FUNCTION migrate_lsev(p_lsev_tbl1 IN lsev_tbl_type,
    p_lsev_tbl2 IN lsev_tbl_type)
    RETURN lsev_tbl_type IS
    l_lsev_tbl lsev_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_lsev_tbl1.COUNT <> p_lsev_tbl2.COUNT THEN
      l_lsev_tbl := p_lsev_tbl1;
    ELSE
      IF (p_lsev_tbl1.COUNT > 0) THEN
        i := p_lsev_tbl1.FIRST;
        j := p_lsev_tbl2.FIRST;
        LOOP
          l_lsev_tbl(i) := migrate_lsev(p_lsev_tbl1(i), p_lsev_tbl2(j));
          EXIT WHEN (i = p_lsev_tbl1.LAST);
          i := p_lsev_tbl1.NEXT(i);
          j := p_lsev_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_lsev_tbl);
  END migrate_lsev;

 PROCEDURE add_language IS
 BEGIN
    OKC_LINE_STYLES_PVT.add_language;
 END add_language;

  PROCEDURE CREATE_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec	            IN lsev_rec_type,
    x_lsev_rec              OUT NOCOPY lsev_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_LINE_STYLES';
    l_return_status	  VARCHAR2(1);
    l_lsev_rec     lsev_rec_type := p_lsev_rec;
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
    g_lsev_rec := l_lsev_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_lsev_rec := migrate_lsev(l_lsev_rec, g_lsev_rec);
    OKC_LINE_STYLES_PVT.CREATE_LINE_STYLES(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_lsev_rec,
       x_lsev_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_lsev_rec := x_lsev_rec;
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
  END CREATE_LINE_STYLES;

  PROCEDURE CREATE_LINE_STYLES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type,
    x_lsev_tbl                     OUT NOCOPY lsev_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lsev_tbl.COUNT > 0 THEN
      i := p_lsev_tbl.FIRST;
      LOOP
        CREATE_LINE_STYLES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsev_tbl(i),
	    x_lsev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lsev_tbl.LAST);
        i := p_lsev_tbl.NEXT(i);
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
  END CREATE_LINE_STYLES;

  PROCEDURE UPDATE_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec	            IN lsev_rec_type,
    x_lsev_rec              OUT NOCOPY lsev_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_LINE_STYLES';
    l_return_status	  VARCHAR2(1);
    l_lsev_rec     lsev_rec_type := p_lsev_rec;
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
    g_lsev_rec := l_lsev_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_lsev_rec := migrate_lsev(l_lsev_rec, g_lsev_rec);
    OKC_LINE_STYLES_PVT.UPDATE_LINE_STYLES(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_lsev_rec,
       x_lsev_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_lsev_rec := x_lsev_rec;
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
  END UPDATE_LINE_STYLES;

  PROCEDURE UPDATE_LINE_STYLES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type,
    x_lsev_tbl                     OUT NOCOPY lsev_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lsev_tbl.COUNT > 0 THEN
      i := p_lsev_tbl.FIRST;
      LOOP
        UPDATE_LINE_STYLES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsev_tbl(i),
	    x_lsev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lsev_tbl.LAST);
        i := p_lsev_tbl.NEXT(i);
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
  END UPDATE_LINE_STYLES;

  PROCEDURE DELETE_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec              IN lsev_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_LINE_STYLES';
    l_return_status	  VARCHAR2(1);
    l_lsev_rec     lsev_rec_type := p_lsev_rec;
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
    g_lsev_rec := l_lsev_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_LINE_STYLES_PVT.DELETE_LINE_STYLES(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_lsev_rec);
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
  END DELETE_LINE_STYLES;

  PROCEDURE DELETE_LINE_STYLES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lsev_tbl.COUNT > 0 THEN
      i := p_lsev_tbl.FIRST;
      LOOP
        DELETE_LINE_STYLES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lsev_tbl.LAST);
        i := p_lsev_tbl.NEXT(i);
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
  END DELETE_LINE_STYLES;

  PROCEDURE LOCK_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		    IN lsev_rec_type) IS
  BEGIN
    OKC_LINE_STYLES_PVT.LOCK_LINE_STYLES(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_lsev_rec);
  END LOCK_LINE_STYLES;

  PROCEDURE LOCK_LINE_STYLES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lsev_tbl.COUNT > 0 THEN
      i := p_lsev_tbl.FIRST;
      LOOP
        LOCK_LINE_STYLES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lsev_tbl.LAST);
        i := p_lsev_tbl.NEXT(i);
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
  END LOCK_LINE_STYLES;

  PROCEDURE VALID_LINE_STYLES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lsev_rec		    IN lsev_rec_type) IS
  BEGIN
    OKC_LINE_STYLES_PVT.VALID_LINE_STYLES(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_lsev_rec);
  END VALID_LINE_STYLES;

  PROCEDURE VALID_LINE_STYLES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lsev_tbl.COUNT > 0 THEN
      i := p_lsev_tbl.FIRST;
      LOOP
        VALID_LINE_STYLES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lsev_tbl.LAST);
        i := p_lsev_tbl.NEXT(i);
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
  END VALID_LINE_STYLES;



FUNCTION USED_IN_K_LINES(
	   p_lsev_tbl                IN lsev_tbl_type) RETURN VARCHAR2 IS
	 i                       NUMBER := 0;
	 l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
	  x_return_status := OKC_API.G_RET_STS_SUCCESS;
	  IF p_lsev_tbl.COUNT > 0 THEN
           i := p_lsev_tbl.FIRST;
		 LOOP
		   l_return_status:=OKC_LINE_STYLES_PVT.USED_IN_K_LINES(p_lsev_tbl(i).id);
		   IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
			  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
				  x_return_status := l_return_status;
		      	  raise G_EXCEPTION_HALT_PROCESSING;
			  ELSE
				  x_return_status := l_return_status;
			  END IF;
		    END IF;
		    EXIT WHEN (i = p_lsev_tbl.LAST);
		    i := p_lsev_tbl.NEXT(i);
		 END LOOP;
      END IF;
	 return x_return_status;
EXCEPTION
	  WHEN G_EXCEPTION_HALT_PROCESSING THEN
	    return x_return_status;
       WHEN OTHERS THEN
		 OKC_API.set_message(p_app_name      => g_app_name,
	      p_msg_name      => g_unexpected_error,
		 p_token1        => g_sqlcode_token,
		 p_token1_value  => sqlcode,
		 p_token2        => g_sqlerrm_token,
		 p_token2_value  => sqlerrm);
		 x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	      return x_return_status;
End USED_IN_K_LINES;



FUNCTION USED_IN_SETUPS(
	   p_lsev_tbl                IN lsev_tbl_type) RETURN VARCHAR2 IS
	 i                       NUMBER := 0;
	 l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
	  x_return_status := OKC_API.G_RET_STS_SUCCESS;
	  IF p_lsev_tbl.COUNT > 0 THEN
           i := p_lsev_tbl.FIRST;
		 LOOP
		   l_return_status:=OKC_LINE_STYLES_PVT.USED_IN_SETUPS(p_lsev_tbl(i).id);
		   IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
			  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
				  x_return_status := l_return_status;
		      	  raise G_EXCEPTION_HALT_PROCESSING;
			  ELSE
				  x_return_status := l_return_status;
			  END IF;
		    END IF;
		    EXIT WHEN (i = p_lsev_tbl.LAST);
		    i := p_lsev_tbl.NEXT(i);
		 END LOOP;
      END IF;
	 return x_return_status;
EXCEPTION
	  WHEN G_EXCEPTION_HALT_PROCESSING THEN
	    return x_return_status;
       WHEN OTHERS THEN
		 OKC_API.set_message(p_app_name      => g_app_name,
	      p_msg_name      => g_unexpected_error,
		 p_token1        => g_sqlcode_token,
		 p_token1_value  => sqlcode,
		 p_token2        => g_sqlerrm_token,
		 p_token2_value  => sqlerrm);
		 x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	      return x_return_status;
End USED_IN_SETUPS;


FUNCTION USED_IN_SRC_OPS(
	   p_lsev_tbl                IN lsev_tbl_type) RETURN VARCHAR2 IS
	 i                       NUMBER := 0;
	 l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
	  x_return_status := OKC_API.G_RET_STS_SUCCESS;
	  IF p_lsev_tbl.COUNT > 0 THEN
           i := p_lsev_tbl.FIRST;
		 LOOP
		   l_return_status:=OKC_LINE_STYLES_PVT.USED_IN_SRC_OPS(p_lsev_tbl(i).id);
		   IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
			  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
				  x_return_status := l_return_status;
		      	  raise G_EXCEPTION_HALT_PROCESSING;
			  ELSE
				  x_return_status := l_return_status;
			  END IF;
		    END IF;
		    EXIT WHEN (i = p_lsev_tbl.LAST);
		    i := p_lsev_tbl.NEXT(i);
		 END LOOP;
      END IF;
	 return x_return_status;
EXCEPTION
	  WHEN G_EXCEPTION_HALT_PROCESSING THEN
	    return x_return_status;
       WHEN OTHERS THEN
		 OKC_API.set_message(p_app_name      => g_app_name,
	      p_msg_name      => g_unexpected_error,
		 p_token1        => g_sqlcode_token,
		 p_token1_value  => sqlcode,
		 p_token2        => g_sqlerrm_token,
		 p_token2_value  => sqlerrm);
		 x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	      return x_return_status;
End USED_IN_SRC_OPS;


 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_LINE_STYLE_SOURCES
 --------------------------------------------------------------------------

  FUNCTION migrate_lssv(p_lssv_rec1 IN lssv_rec_type,
                        p_lssv_rec2 IN lssv_rec_type)
    RETURN lssv_rec_type IS
    l_lssv_rec lssv_rec_type;
  BEGIN
    l_lssv_rec.lse_id := p_lssv_rec1.lse_id;
    l_lssv_rec.jtot_object_code := p_lssv_rec2.jtot_object_code;
    l_lssv_rec.start_date := p_lssv_rec2.start_date;
    l_lssv_rec.end_date := p_lssv_rec2.end_date;
    l_lssv_rec.object_version_number := p_lssv_rec1.object_version_number;
    l_lssv_rec.created_by := p_lssv_rec1.created_by;
    l_lssv_rec.creation_date := p_lssv_rec1.creation_date;
    l_lssv_rec.last_updated_by := p_lssv_rec1.last_updated_by;
    l_lssv_rec.last_update_date := p_lssv_rec1.last_update_date;
    l_lssv_rec.last_update_login := p_lssv_rec1.last_update_login;
    RETURN (l_lssv_rec);
  END migrate_lssv;

  FUNCTION migrate_lssv(p_lssv_tbl1 IN lssv_tbl_type,
    p_lssv_tbl2 IN lssv_tbl_type)
    RETURN lssv_tbl_type IS
    l_lssv_tbl lssv_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_lssv_tbl1.COUNT <> p_lssv_tbl2.COUNT THEN
      l_lssv_tbl := p_lssv_tbl1;
    ELSE
      IF (p_lssv_tbl1.COUNT > 0) THEN
        i := p_lssv_tbl1.FIRST;
        j := p_lssv_tbl2.FIRST;
        LOOP
          l_lssv_tbl(i) := migrate_lssv(p_lssv_tbl1(i), p_lssv_tbl2(j));
          EXIT WHEN (i = p_lssv_tbl1.LAST);
          i := p_lssv_tbl1.NEXT(i);
          j := p_lssv_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_lssv_tbl);
  END migrate_lssv;

  PROCEDURE CREATE_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec	            IN lssv_rec_type,
    x_lssv_rec              OUT NOCOPY lssv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_LINE_STYLE_SOURCES';
    l_return_status	  VARCHAR2(1);
    l_lssv_rec     lssv_rec_type := p_lssv_rec;
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
    g_lssv_rec := l_lssv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_lssv_rec := migrate_lssv(l_lssv_rec, g_lssv_rec);
    OKC_LINE_STYLES_PVT.CREATE_LINE_STYLE_SOURCES(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_lssv_rec,
       x_lssv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_lssv_rec := x_lssv_rec;
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
  END CREATE_LINE_STYLE_SOURCES;

  PROCEDURE CREATE_LINE_STYLE_SOURCES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type,
    x_lssv_tbl                     OUT NOCOPY lssv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lssv_tbl.COUNT > 0 THEN
      i := p_lssv_tbl.FIRST;
      LOOP
        CREATE_LINE_STYLE_SOURCES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lssv_tbl(i),
	    x_lssv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lssv_tbl.LAST);
        i := p_lssv_tbl.NEXT(i);
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
  END CREATE_LINE_STYLE_SOURCES;

  PROCEDURE UPDATE_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec	            IN lssv_rec_type,
    x_lssv_rec              OUT NOCOPY lssv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_LINE_STYLE_SOURCES';
    l_return_status	  VARCHAR2(1);
    l_lssv_rec     lssv_rec_type := p_lssv_rec;
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
    g_lssv_rec := l_lssv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_lssv_rec := migrate_lssv(l_lssv_rec, g_lssv_rec);
    OKC_LINE_STYLES_PVT.UPDATE_LINE_STYLE_SOURCES(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_lssv_rec,
       x_lssv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_lssv_rec := x_lssv_rec;
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
  END UPDATE_LINE_STYLE_SOURCES;

  PROCEDURE UPDATE_LINE_STYLE_SOURCES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type,
    x_lssv_tbl                     OUT NOCOPY lssv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lssv_tbl.COUNT > 0 THEN
      i := p_lssv_tbl.FIRST;
      LOOP
        UPDATE_LINE_STYLE_SOURCES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lssv_tbl(i),
	    x_lssv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lssv_tbl.LAST);
        i := p_lssv_tbl.NEXT(i);
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
  END UPDATE_LINE_STYLE_SOURCES;

  PROCEDURE DELETE_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec              IN lssv_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_LINE_STYLE_SOURCES';
    l_return_status	  VARCHAR2(1);
    l_lssv_rec     lssv_rec_type := p_lssv_rec;
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
    g_lssv_rec := l_lssv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_LINE_STYLES_PVT.DELETE_LINE_STYLE_SOURCES(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_lssv_rec);
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
  END DELETE_LINE_STYLE_SOURCES;

  PROCEDURE DELETE_LINE_STYLE_SOURCES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lssv_tbl.COUNT > 0 THEN
      i := p_lssv_tbl.FIRST;
      LOOP
        DELETE_LINE_STYLE_SOURCES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lssv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lssv_tbl.LAST);
        i := p_lssv_tbl.NEXT(i);
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
  END DELETE_LINE_STYLE_SOURCES;

  PROCEDURE LOCK_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec		    IN lssv_rec_type) IS
  BEGIN
    OKC_LINE_STYLES_PVT.LOCK_LINE_STYLE_SOURCES(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_lssv_rec);
  END LOCK_LINE_STYLE_SOURCES;

  PROCEDURE LOCK_LINE_STYLE_SOURCES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lssv_tbl.COUNT > 0 THEN
      i := p_lssv_tbl.FIRST;
      LOOP
        LOCK_LINE_STYLE_SOURCES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lssv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lssv_tbl.LAST);
        i := p_lssv_tbl.NEXT(i);
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
  END LOCK_LINE_STYLE_SOURCES;

  PROCEDURE VALID_LINE_STYLE_SOURCES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_lssv_rec		    IN lssv_rec_type) IS
  BEGIN
    OKC_LINE_STYLES_PVT.VALID_LINE_STYLE_SOURCES(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_lssv_rec);
  END VALID_LINE_STYLE_SOURCES;

  PROCEDURE VALID_LINE_STYLE_SOURCES(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_lssv_tbl.COUNT > 0 THEN
      i := p_lssv_tbl.FIRST;
      LOOP
        VALID_LINE_STYLE_SOURCES(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lssv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lssv_tbl.LAST);
        i := p_lssv_tbl.NEXT(i);
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
  END VALID_LINE_STYLE_SOURCES;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_VAL_LINE_OPERTION
 --------------------------------------------------------------------------

  FUNCTION migrate_vlov(p_vlov_rec1 IN vlov_rec_type,
                        p_vlov_rec2 IN vlov_rec_type)
    RETURN vlov_rec_type IS
    l_vlov_rec vlov_rec_type;
  BEGIN
    l_vlov_rec.lse_id := p_vlov_rec2.lse_id;
    l_vlov_rec.opn_code := p_vlov_rec2.opn_code;
    l_vlov_rec.object_version_number := p_vlov_rec1.object_version_number;
    l_vlov_rec.created_by := p_vlov_rec1.created_by;
    l_vlov_rec.creation_date := p_vlov_rec1.creation_date;
    l_vlov_rec.last_updated_by := p_vlov_rec1.last_updated_by;
    l_vlov_rec.last_update_date := p_vlov_rec1.last_update_date;
    l_vlov_rec.last_update_login := p_vlov_rec1.last_update_login;
    RETURN (l_vlov_rec);
  END migrate_vlov;

  PROCEDURE CREATE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec	            IN vlov_rec_type,
    x_vlov_rec              OUT NOCOPY vlov_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_VAL_LINE_OPERATION';
    l_return_status	  VARCHAR2(1);
    l_vlov_rec     vlov_rec_type := p_vlov_rec;
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
    g_vlov_rec := l_vlov_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_vlov_rec := migrate_vlov(l_vlov_rec, g_vlov_rec);
    OKC_LINE_STYLES_PVT.CREATE_VAL_LINE_OPERATION(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_vlov_rec,
       x_vlov_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_vlov_rec := x_vlov_rec;
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
  END CREATE_VAL_LINE_OPERATION;

  PROCEDURE CREATE_VAL_LINE_OPERATION(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vlov_tbl                     IN vlov_tbl_type,
    x_vlov_tbl                     OUT NOCOPY vlov_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_vlov_tbl.COUNT > 0 THEN
      i := p_vlov_tbl.FIRST;
      LOOP
        CREATE_VAL_LINE_OPERATION(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_vlov_tbl(i),
	    x_vlov_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_vlov_tbl.LAST);
        i := p_vlov_tbl.NEXT(i);
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
  END CREATE_VAL_LINE_OPERATION;

  PROCEDURE UPDATE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec	            IN vlov_rec_type,
    x_vlov_rec              OUT NOCOPY vlov_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_VAL_LINE_OPERATION';
    l_return_status	  VARCHAR2(1);
    l_vlov_rec     vlov_rec_type := p_vlov_rec;
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
    g_vlov_rec := l_vlov_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_vlov_rec := migrate_vlov(l_vlov_rec, g_vlov_rec);
    OKC_LINE_STYLES_PVT.UPDATE_VAL_LINE_OPERATION(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_vlov_rec,
       x_vlov_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_vlov_rec := x_vlov_rec;
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
  END UPDATE_VAL_LINE_OPERATION;

  PROCEDURE UPDATE_VAL_LINE_OPERATION(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vlov_tbl                     IN vlov_tbl_type,
    x_vlov_tbl                     OUT NOCOPY vlov_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_vlov_tbl.COUNT > 0 THEN
      i := p_vlov_tbl.FIRST;
      LOOP
        UPDATE_VAL_LINE_OPERATION(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_vlov_tbl(i),
	    x_vlov_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_vlov_tbl.LAST);
        i := p_vlov_tbl.NEXT(i);
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
  END UPDATE_VAL_LINE_OPERATION;

  PROCEDURE DELETE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec              IN vlov_rec_type) IS
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_VAL_LINE_OPERATION';
    l_return_status	  VARCHAR2(1);
    l_vlov_rec     vlov_rec_type := p_vlov_rec;
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
    g_vlov_rec := l_vlov_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_LINE_STYLES_PVT.DELETE_VAL_LINE_OPERATION(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_vlov_rec);
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
  END DELETE_VAL_LINE_OPERATION;

  PROCEDURE DELETE_VAL_LINE_OPERATION(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vlov_tbl                     IN vlov_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_vlov_tbl.COUNT > 0 THEN
      i := p_vlov_tbl.FIRST;
      LOOP
        DELETE_VAL_LINE_OPERATION(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_vlov_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_vlov_tbl.LAST);
        i := p_vlov_tbl.NEXT(i);
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
  END DELETE_VAL_LINE_OPERATION;

  PROCEDURE LOCK_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec		    IN vlov_rec_type) IS
  BEGIN
    OKC_LINE_STYLES_PVT.LOCK_VAL_LINE_OPERATION(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_vlov_rec);
  END LOCK_VAL_LINE_OPERATION;

  PROCEDURE LOCK_VAL_LINE_OPERATION(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vlov_tbl                     IN vlov_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_vlov_tbl.COUNT > 0 THEN
      i := p_vlov_tbl.FIRST;
      LOOP
        LOCK_VAL_LINE_OPERATION(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_vlov_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_vlov_tbl.LAST);
        i := p_vlov_tbl.NEXT(i);
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
  END LOCK_VAL_LINE_OPERATION;

  PROCEDURE VALIDATE_VAL_LINE_OPERATION(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_vlov_rec		    IN vlov_rec_type) IS
  BEGIN
    OKC_LINE_STYLES_PVT.VALIDATE_VAL_LINE_OPERATION(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_vlov_rec);
  END VALIDATE_VAL_LINE_OPERATION;

  PROCEDURE VALIDATE_VAL_LINE_OPERATION(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vlov_tbl                     IN vlov_tbl_type) IS
    i			         NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_vlov_tbl.COUNT > 0 THEN
      i := p_vlov_tbl.FIRST;
      LOOP
        VALIDATE_VAL_LINE_OPERATION(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_vlov_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_vlov_tbl.LAST);
        i := p_vlov_tbl.NEXT(i);
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
  END VALIDATE_VAL_LINE_OPERATION;

END OKC_LINE_STYLES_PUB;

/
