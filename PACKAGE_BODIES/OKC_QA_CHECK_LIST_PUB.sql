--------------------------------------------------------
--  DDL for Package Body OKC_QA_CHECK_LIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_QA_CHECK_LIST_PUB" AS
/* $Header: OKCPQCLB.pls 120.0 2005/05/25 19:03:31 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- FUNCTION migrate_qclv
  ---------------------------------------------------------------------------
  FUNCTION migrate_qclv (
    p_qclv_rec1 IN qclv_rec_type,
    p_qclv_rec2 IN qclv_rec_type
  ) RETURN qclv_rec_type IS
    l_qclv_rec qclv_rec_type;
  BEGIN
    l_qclv_rec.id                    := p_qclv_rec1.id;
    l_qclv_rec.object_version_number := p_qclv_rec1.object_version_number;
    l_qclv_rec.created_by            := p_qclv_rec1.created_by;
    l_qclv_rec.creation_date         := p_qclv_rec1.creation_date;
    l_qclv_rec.last_updated_by       := p_qclv_rec1.last_updated_by;
    l_qclv_rec.last_update_date      := p_qclv_rec1.last_update_date;
    l_qclv_rec.last_update_login     := p_qclv_rec1.last_update_login;
    l_qclv_rec.name                  := p_qclv_rec2.name;
    l_qclv_rec.short_description     := p_qclv_rec2.short_description;
    l_qclv_rec.begin_date            := p_qclv_rec2.begin_date;
    l_qclv_rec.end_date              := p_qclv_rec2.end_date;
    l_qclv_rec.sfwt_flag             := p_qclv_rec2.sfwt_flag;
    l_qclv_rec.attribute_category    := p_qclv_rec2.attribute_category;
    l_qclv_rec.attribute1            := p_qclv_rec2.attribute1;
    l_qclv_rec.attribute2            := p_qclv_rec2.attribute2;
    l_qclv_rec.attribute3            := p_qclv_rec2.attribute3;
    l_qclv_rec.attribute4            := p_qclv_rec2.attribute4;
    l_qclv_rec.attribute5            := p_qclv_rec2.attribute5;
    l_qclv_rec.attribute6            := p_qclv_rec2.attribute6;
    l_qclv_rec.attribute7            := p_qclv_rec2.attribute7;
    l_qclv_rec.attribute8            := p_qclv_rec2.attribute8;
    l_qclv_rec.attribute9            := p_qclv_rec2.attribute9;
    l_qclv_rec.attribute10           := p_qclv_rec2.attribute10;
    l_qclv_rec.attribute11           := p_qclv_rec2.attribute11;
    l_qclv_rec.attribute12           := p_qclv_rec2.attribute12;
    l_qclv_rec.attribute13           := p_qclv_rec2.attribute13;
    l_qclv_rec.attribute14           := p_qclv_rec2.attribute14;
    l_qclv_rec.attribute15           := p_qclv_rec2.attribute15;
    l_qclv_rec.application_id        := p_qclv_rec2.application_id;
    l_qclv_rec.default_yn        := p_qclv_rec2.default_yn;


    RETURN (l_qclv_rec);
  END migrate_qclv;

  --------------------------------------
  -- PROCEDURE create_qa_check_list
  --------------------------------------
  PROCEDURE create_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type,
    x_qclv_rec                     OUT NOCOPY qclv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_qa_check_list';
    l_qclv_rec                     qclv_rec_type := p_qclv_rec;
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
    g_qclv_rec := p_qclv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_qclv_rec := migrate_qclv(l_qclv_rec, g_qclv_rec);

    OKC_QA_CHECK_LIST_PVT.create_qa_check_list(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qclv_rec      => l_qclv_rec,
      x_qclv_rec      => x_qclv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_qclv_rec := x_qclv_rec;
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
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END create_qa_check_list;

  --------------------------------------
  -- PROCEDURE create_qa_check_list
  --------------------------------------
  PROCEDURE create_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_tbl                     IN  qclv_tbl_type,
    x_qclv_tbl                     OUT NOCOPY qclv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qclv_tbl.COUNT > 0 THEN
      i := p_qclv_tbl.FIRST;
      LOOP
        create_qa_check_list(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qclv_rec      => p_qclv_tbl(i),
          x_qclv_rec      => x_qclv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qclv_tbl.LAST);
        i := p_qclv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_qa_check_list;

  --------------------------------------
  -- PROCEDURE update_qa_check_list
  --------------------------------------
  PROCEDURE update_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type,
    x_qclv_rec                     OUT NOCOPY qclv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_qa_check_list';
    l_qclv_rec                     qclv_rec_type := p_qclv_rec;
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
    g_qclv_rec := p_qclv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_qclv_rec := migrate_qclv(l_qclv_rec, g_qclv_rec);

    OKC_QA_CHECK_LIST_PVT.update_qa_check_list(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qclv_rec      => l_qclv_rec,
      x_qclv_rec      => x_qclv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_qclv_rec := x_qclv_rec;
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
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END update_qa_check_list;

  --------------------------------------
  -- PROCEDURE update_qa_check_list
  --------------------------------------
  PROCEDURE update_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_tbl                     IN  qclv_tbl_type,
    x_qclv_tbl                     OUT NOCOPY qclv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qclv_tbl.COUNT > 0 THEN
      i := p_qclv_tbl.FIRST;
      LOOP
        update_qa_check_list(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qclv_rec      => p_qclv_tbl(i),
          x_qclv_rec      => x_qclv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qclv_tbl.LAST);
        i := p_qclv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_qa_check_list;

  --------------------------------------
  -- PROCEDURE delete_qa_check_list
  --------------------------------------
  PROCEDURE delete_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_qa_check_list';
    l_qclv_rec                     qclv_rec_type := p_qclv_rec;
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
    g_qclv_rec := p_qclv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_QA_CHECK_LIST_PVT.delete_qa_check_list(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qclv_rec      => p_qclv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_qclv_rec := l_qclv_rec;
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
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END delete_qa_check_list;

  --------------------------------------
  -- PROCEDURE delete_qa_check_list
  --------------------------------------
  PROCEDURE delete_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_tbl                     IN  qclv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qclv_tbl.COUNT > 0 THEN
      i := p_qclv_tbl.FIRST;
      LOOP
        delete_qa_check_list(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qclv_rec      => p_qclv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qclv_tbl.LAST);
        i := p_qclv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_qa_check_list;

  --------------------------------------
  -- PROCEDURE lock_qa_check_list
  --------------------------------------
  PROCEDURE lock_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type) IS
  BEGIN
    OKC_QA_CHECK_LIST_PVT.lock_qa_check_list(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qclv_rec      => p_qclv_rec);
  END lock_qa_check_list;

  --------------------------------------
  -- PROCEDURE lock_qa_check_list
  --------------------------------------
  PROCEDURE lock_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_tbl                     IN  qclv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qclv_tbl.COUNT > 0 THEN
      i := p_qclv_tbl.FIRST;
      LOOP
        lock_qa_check_list(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qclv_rec      => p_qclv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qclv_tbl.LAST);
        i := p_qclv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END lock_qa_check_list;

  --------------------------------------
  -- PROCEDURE validate_qa_check_list
  --------------------------------------
  PROCEDURE validate_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_qa_check_list';
    l_qclv_rec                     qclv_rec_type := p_qclv_rec;
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
    g_qclv_rec := p_qclv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_QA_CHECK_LIST_PVT.validate_qa_check_list(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qclv_rec      => p_qclv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_qclv_rec := l_qclv_rec;
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
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END validate_qa_check_list;

  --------------------------------------
  -- PROCEDURE validate_qa_check_list
  --------------------------------------
  PROCEDURE validate_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_tbl                     IN  qclv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qclv_tbl.COUNT > 0 THEN
      i := p_qclv_tbl.FIRST;
      LOOP
        validate_qa_check_list(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qclv_rec      => p_qclv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qclv_tbl.LAST);
        i := p_qclv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_qa_check_list;

  ---------------------------------------------------------------------------
  -- FUNCTION migrate_qlpv
  ---------------------------------------------------------------------------
  FUNCTION migrate_qlpv (
    p_qlpv_rec1 IN qlpv_rec_type,
    p_qlpv_rec2 IN qlpv_rec_type
  ) RETURN qlpv_rec_type IS
    l_qlpv_rec qlpv_rec_type;
  BEGIN
    l_qlpv_rec.row_id                := p_qlpv_rec1.row_id;
    l_qlpv_rec.object_version_number := p_qlpv_rec1.object_version_number;
    l_qlpv_rec.created_by            := p_qlpv_rec1.created_by;
    l_qlpv_rec.creation_date         := p_qlpv_rec1.creation_date;
    l_qlpv_rec.last_updated_by       := p_qlpv_rec1.last_updated_by;
    l_qlpv_rec.last_update_date      := p_qlpv_rec1.last_update_date;
    l_qlpv_rec.last_update_login     := p_qlpv_rec1.last_update_login;
    l_qlpv_rec.qcl_id                := p_qlpv_rec2.qcl_id;
    l_qlpv_rec.pdf_id                := p_qlpv_rec2.pdf_id;
    l_qlpv_rec.severity              := p_qlpv_rec2.severity;
    l_qlpv_rec.active_yn             := p_qlpv_rec2.active_yn;
    l_qlpv_rec.run_sequence          := p_qlpv_rec2.run_sequence;
    l_qlpv_rec.attribute_category    := p_qlpv_rec2.attribute_category;
    l_qlpv_rec.attribute1            := p_qlpv_rec2.attribute1;
    l_qlpv_rec.attribute2            := p_qlpv_rec2.attribute2;
    l_qlpv_rec.attribute3            := p_qlpv_rec2.attribute3;
    l_qlpv_rec.attribute4            := p_qlpv_rec2.attribute4;
    l_qlpv_rec.attribute5            := p_qlpv_rec2.attribute5;
    l_qlpv_rec.attribute6            := p_qlpv_rec2.attribute6;
    l_qlpv_rec.attribute7            := p_qlpv_rec2.attribute7;
    l_qlpv_rec.attribute8            := p_qlpv_rec2.attribute8;
    l_qlpv_rec.attribute9            := p_qlpv_rec2.attribute9;
    l_qlpv_rec.attribute10           := p_qlpv_rec2.attribute10;
    l_qlpv_rec.attribute11           := p_qlpv_rec2.attribute11;
    l_qlpv_rec.attribute12           := p_qlpv_rec2.attribute12;
    l_qlpv_rec.attribute13           := p_qlpv_rec2.attribute13;
    l_qlpv_rec.attribute14           := p_qlpv_rec2.attribute14;
    l_qlpv_rec.attribute15           := p_qlpv_rec2.attribute15;
    l_qlpv_rec.access_level          := p_qlpv_rec2.access_level;

    RETURN (l_qlpv_rec);
  END migrate_qlpv;

  --------------------------------------
  -- PROCEDURE create_qa_process
  --------------------------------------
  PROCEDURE create_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type,
    x_qlpv_rec                     OUT NOCOPY qlpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_qa_process';
    l_qlpv_rec                     qlpv_rec_type := p_qlpv_rec;
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
    g_qlpv_rec := p_qlpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_qlpv_rec := migrate_qlpv(l_qlpv_rec, g_qlpv_rec);

    OKC_QA_CHECK_LIST_PVT.create_qa_process(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qlpv_rec      => l_qlpv_rec,
      x_qlpv_rec      => x_qlpv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_qlpv_rec := x_qlpv_rec;
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
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END create_qa_process;

  --------------------------------------
  -- PROCEDURE create_qa_process
  --------------------------------------
  PROCEDURE create_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_tbl                     IN  qlpv_tbl_type,
    x_qlpv_tbl                     OUT NOCOPY qlpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qlpv_tbl.COUNT > 0 THEN
      i := p_qlpv_tbl.FIRST;
      LOOP
        create_qa_process(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qlpv_rec      => p_qlpv_tbl(i),
          x_qlpv_rec      => x_qlpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qlpv_tbl.LAST);
        i := p_qlpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_qa_process;

  --------------------------------------
  -- PROCEDURE update_qa_process
  --------------------------------------
  PROCEDURE update_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type,
    x_qlpv_rec                     OUT NOCOPY qlpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_qa_process';
    l_qlpv_rec                     qlpv_rec_type := p_qlpv_rec;
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
    g_qlpv_rec := p_qlpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_qlpv_rec := migrate_qlpv(l_qlpv_rec, g_qlpv_rec);

    OKC_QA_CHECK_LIST_PVT.update_qa_process(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qlpv_rec      => l_qlpv_rec,
      x_qlpv_rec      => x_qlpv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_qlpv_rec := x_qlpv_rec;
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
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END update_qa_process;

  --------------------------------------
  -- PROCEDURE update_qa_process
  --------------------------------------
  PROCEDURE update_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_tbl                     IN  qlpv_tbl_type,
    x_qlpv_tbl                     OUT NOCOPY qlpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qlpv_tbl.COUNT > 0 THEN
      i := p_qlpv_tbl.FIRST;
      LOOP
        update_qa_process(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qlpv_rec      => p_qlpv_tbl(i),
          x_qlpv_rec      => x_qlpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qlpv_tbl.LAST);
        i := p_qlpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_qa_process;

  --------------------------------------
  -- PROCEDURE delete_qa_process
  --------------------------------------
  PROCEDURE delete_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_qa_process';
    l_qlpv_rec                     qlpv_rec_type := p_qlpv_rec;
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
    g_qlpv_rec := p_qlpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_QA_CHECK_LIST_PVT.delete_qa_process(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qlpv_rec      => p_qlpv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_qlpv_rec := l_qlpv_rec;
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
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END delete_qa_process;

  --------------------------------------
  -- PROCEDURE delete_qa_process
  --------------------------------------
  PROCEDURE delete_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_tbl                     IN  qlpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qlpv_tbl.COUNT > 0 THEN
      i := p_qlpv_tbl.FIRST;
      LOOP
        delete_qa_process(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qlpv_rec      => p_qlpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qlpv_tbl.LAST);
        i := p_qlpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_qa_process;

  --------------------------------------
  -- PROCEDURE lock_qa_process
  --------------------------------------
  PROCEDURE lock_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type) IS
  BEGIN
    OKC_QA_CHECK_LIST_PVT.lock_qa_process(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qlpv_rec      => p_qlpv_rec);
  END lock_qa_process;

  --------------------------------------
  -- PROCEDURE lock_qa_process
  --------------------------------------
  PROCEDURE lock_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_tbl                     IN  qlpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qlpv_tbl.COUNT > 0 THEN
      i := p_qlpv_tbl.FIRST;
      LOOP
        lock_qa_process(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qlpv_rec      => p_qlpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qlpv_tbl.LAST);
        i := p_qlpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END lock_qa_process;

  --------------------------------------
  -- PROCEDURE validate_qa_process
  --------------------------------------
  PROCEDURE validate_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_qa_process';
    l_qlpv_rec                     qlpv_rec_type := p_qlpv_rec;
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
    g_qlpv_rec := p_qlpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_QA_CHECK_LIST_PVT.validate_qa_process(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qlpv_rec      => p_qlpv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_qlpv_rec := l_qlpv_rec;
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
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END validate_qa_process;

  --------------------------------------
  -- PROCEDURE validate_qa_process
  --------------------------------------
  PROCEDURE validate_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_tbl                     IN  qlpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qlpv_tbl.COUNT > 0 THEN
      i := p_qlpv_tbl.FIRST;
      LOOP
        validate_qa_process(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qlpv_rec      => p_qlpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qlpv_tbl.LAST);
        i := p_qlpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_qa_process;

  ---------------------------------------------------------------------------
  -- FUNCTION migrate_qppv
  ---------------------------------------------------------------------------
  FUNCTION migrate_qppv (
    p_qppv_rec1 IN qppv_rec_type,
    p_qppv_rec2 IN qppv_rec_type
  ) RETURN qppv_rec_type IS
    l_qppv_rec qppv_rec_type;
  BEGIN
    l_qppv_rec.object_version_number := p_qppv_rec1.object_version_number;
    l_qppv_rec.created_by            := p_qppv_rec1.created_by;
    l_qppv_rec.creation_date         := p_qppv_rec1.creation_date;
    l_qppv_rec.last_updated_by       := p_qppv_rec1.last_updated_by;
    l_qppv_rec.last_update_date      := p_qppv_rec1.last_update_date;
    l_qppv_rec.last_update_login     := p_qppv_rec1.last_update_login;
    l_qppv_rec.qlp_qcl_id            := p_qppv_rec2.qlp_qcl_id;
    l_qppv_rec.qlp_pdf_id            := p_qppv_rec2.qlp_pdf_id;
    l_qppv_rec.qlp_run_sequence      := p_qppv_rec2.qlp_run_sequence;
    l_qppv_rec.pdp_id                := p_qppv_rec2.pdp_id;
    l_qppv_rec.parm_value            := p_qppv_rec2.parm_value;
    l_qppv_rec.attribute_category    := p_qppv_rec2.attribute_category;
    l_qppv_rec.attribute1            := p_qppv_rec2.attribute1;
    l_qppv_rec.attribute2            := p_qppv_rec2.attribute2;
    l_qppv_rec.attribute3            := p_qppv_rec2.attribute3;
    l_qppv_rec.attribute4            := p_qppv_rec2.attribute4;
    l_qppv_rec.attribute5            := p_qppv_rec2.attribute5;
    l_qppv_rec.attribute6            := p_qppv_rec2.attribute6;
    l_qppv_rec.attribute7            := p_qppv_rec2.attribute7;
    l_qppv_rec.attribute8            := p_qppv_rec2.attribute8;
    l_qppv_rec.attribute9            := p_qppv_rec2.attribute9;
    l_qppv_rec.attribute10           := p_qppv_rec2.attribute10;
    l_qppv_rec.attribute11           := p_qppv_rec2.attribute11;
    l_qppv_rec.attribute12           := p_qppv_rec2.attribute12;
    l_qppv_rec.attribute13           := p_qppv_rec2.attribute13;
    l_qppv_rec.attribute14           := p_qppv_rec2.attribute14;
    l_qppv_rec.attribute15           := p_qppv_rec2.attribute15;

    RETURN (l_qppv_rec);
  END migrate_qppv;

  --------------------------------------
  -- PROCEDURE create_qa_parm
  --------------------------------------
  PROCEDURE create_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type,
    x_qppv_rec                     OUT NOCOPY qppv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_qa_parm';
    l_qppv_rec                     qppv_rec_type := p_qppv_rec;
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
    g_qppv_rec := p_qppv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_qppv_rec := migrate_qppv(l_qppv_rec, g_qppv_rec);

    OKC_QA_CHECK_LIST_PVT.create_qa_parm(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qppv_rec      => l_qppv_rec,
      x_qppv_rec      => x_qppv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_qppv_rec := x_qppv_rec;
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
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END create_qa_parm;

  --------------------------------------
  -- PROCEDURE create_qa_parm
  --------------------------------------
  PROCEDURE create_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_tbl                     IN  qppv_tbl_type,
    x_qppv_tbl                     OUT NOCOPY qppv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qppv_tbl.COUNT > 0 THEN
      i := p_qppv_tbl.FIRST;
      LOOP
        create_qa_parm(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qppv_rec      => p_qppv_tbl(i),
          x_qppv_rec      => x_qppv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qppv_tbl.LAST);
        i := p_qppv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_qa_parm;

  --------------------------------------
  -- PROCEDURE update_qa_parm
  --------------------------------------
  PROCEDURE update_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type,
    x_qppv_rec                     OUT NOCOPY qppv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_qa_parm';
    l_qppv_rec                     qppv_rec_type := p_qppv_rec;
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
    g_qppv_rec := p_qppv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_qppv_rec := migrate_qppv(l_qppv_rec, g_qppv_rec);

    OKC_QA_CHECK_LIST_PVT.update_qa_parm(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qppv_rec      => l_qppv_rec,
      x_qppv_rec      => x_qppv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_qppv_rec := x_qppv_rec;
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
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END update_qa_parm;

  --------------------------------------
  -- PROCEDURE update_qa_parm
  --------------------------------------
  PROCEDURE update_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_tbl                     IN  qppv_tbl_type,
    x_qppv_tbl                     OUT NOCOPY qppv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qppv_tbl.COUNT > 0 THEN
      i := p_qppv_tbl.FIRST;
      LOOP
        update_qa_parm(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qppv_rec      => p_qppv_tbl(i),
          x_qppv_rec      => x_qppv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qppv_tbl.LAST);
        i := p_qppv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_qa_parm;

  --------------------------------------
  -- PROCEDURE delete_qa_parm
  --------------------------------------
  PROCEDURE delete_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_qa_parm';
    l_qppv_rec                     qppv_rec_type := p_qppv_rec;
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
    g_qppv_rec := p_qppv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_QA_CHECK_LIST_PVT.delete_qa_parm(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qppv_rec      => p_qppv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_qppv_rec := l_qppv_rec;
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
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END delete_qa_parm;

  --------------------------------------
  -- PROCEDURE delete_qa_parm
  --------------------------------------
  PROCEDURE delete_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_tbl                     IN  qppv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qppv_tbl.COUNT > 0 THEN
      i := p_qppv_tbl.FIRST;
      LOOP
        delete_qa_parm(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qppv_rec      => p_qppv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qppv_tbl.LAST);
        i := p_qppv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_qa_parm;

  --------------------------------------
  -- PROCEDURE lock_qa_parm
  --------------------------------------
  PROCEDURE lock_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type) IS
  BEGIN
    OKC_QA_CHECK_LIST_PVT.lock_qa_parm(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qppv_rec      => p_qppv_rec);
  END lock_qa_parm;

  --------------------------------------
  -- PROCEDURE lock_qa_parm
  --------------------------------------
  PROCEDURE lock_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_tbl                     IN  qppv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qppv_tbl.COUNT > 0 THEN
      i := p_qppv_tbl.FIRST;
      LOOP
        lock_qa_parm(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qppv_rec      => p_qppv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qppv_tbl.LAST);
        i := p_qppv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END lock_qa_parm;

  --------------------------------------
  -- PROCEDURE validate_qa_parm
  --------------------------------------
  PROCEDURE validate_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_qa_parm';
    l_qppv_rec                     qppv_rec_type := p_qppv_rec;
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
    g_qppv_rec := p_qppv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_QA_CHECK_LIST_PVT.validate_qa_parm(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_qppv_rec      => p_qppv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_qppv_rec := l_qppv_rec;
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
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END validate_qa_parm;

  --------------------------------------
  -- PROCEDURE validate_qa_parm
  --------------------------------------
  PROCEDURE validate_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_tbl                     IN  qppv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_qppv_tbl.COUNT > 0 THEN
      i := p_qppv_tbl.FIRST;
      LOOP
        validate_qa_parm(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_qppv_rec      => p_qppv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_qppv_tbl.LAST);
        i := p_qppv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_qa_parm;

  --------------------------------------
  -- PROCEDURE add_language
  --------------------------------------
  PROCEDURE add_language IS
  BEGIN
    OKC_QA_CHECK_LIST_PVT.ADD_LANGUAGE;
  END add_language;

END OKC_QA_CHECK_LIST_PUB;

/
