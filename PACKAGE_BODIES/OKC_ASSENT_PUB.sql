--------------------------------------------------------
--  DDL for Package Body OKC_ASSENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ASSENT_PUB" AS
/* $Header: OKCPASTB.pls 120.0 2005/05/25 22:37:22 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  PROCEDURE add_language IS
  BEGIN
    okc_assent_pvt.add_language;
  END;

  FUNCTION migrate_astv(p_astv_rec1 IN astv_rec_type,
                        p_astv_rec2 IN astv_rec_type)
    RETURN astv_rec_type IS
    l_astv_rec astv_rec_type;
  BEGIN
    l_astv_rec.id                    := p_astv_rec1.id;
    l_astv_rec.scs_code              := p_astv_rec1.scs_code;
    l_astv_rec.sts_code              := p_astv_rec1.sts_code;
    l_astv_rec.opn_code              := p_astv_rec1.opn_code;
    l_astv_rec.ste_code              := p_astv_rec1.ste_code;
    l_astv_rec.object_version_number := p_astv_rec1.object_version_number;
    l_astv_rec.allowed_yn            := p_astv_rec1.allowed_yn;
    l_astv_rec.created_by            := p_astv_rec1.created_by;
    l_astv_rec.creation_date         := p_astv_rec1.creation_date;
    l_astv_rec.last_updated_by       := p_astv_rec1.last_updated_by;
    l_astv_rec.last_update_date      := p_astv_rec1.last_update_date;
    l_astv_rec.last_update_login     := p_astv_rec1.last_update_login;
    l_astv_rec.attribute_category    := p_astv_rec2.attribute_category;
    l_astv_rec.attribute1            := p_astv_rec2.attribute1;
    l_astv_rec.attribute2            := p_astv_rec2.attribute2;
    l_astv_rec.attribute3            := p_astv_rec2.attribute3;
    l_astv_rec.attribute4            := p_astv_rec2.attribute4;
    l_astv_rec.attribute5            := p_astv_rec2.attribute5;
    l_astv_rec.attribute6            := p_astv_rec2.attribute6;
    l_astv_rec.attribute7            := p_astv_rec2.attribute7;
    l_astv_rec.attribute8            := p_astv_rec2.attribute8;
    l_astv_rec.attribute9            := p_astv_rec2.attribute9;
    l_astv_rec.attribute10           := p_astv_rec2.attribute10;
    l_astv_rec.attribute11           := p_astv_rec2.attribute11;
    l_astv_rec.attribute12           := p_astv_rec2.attribute12;
    l_astv_rec.attribute13           := p_astv_rec2.attribute13;
    l_astv_rec.attribute14           := p_astv_rec2.attribute14;
    l_astv_rec.attribute15           := p_astv_rec2.attribute15;
    RETURN (l_astv_rec);
  END migrate_astv;

  FUNCTION migrate_stsv(p_stsv_rec1 IN stsv_rec_type,
                        p_stsv_rec2 IN stsv_rec_type)
    RETURN stsv_rec_type IS
    l_stsv_rec stsv_rec_type;
  BEGIN
    l_stsv_rec.code                  := p_stsv_rec1.code;
    l_stsv_rec.ste_code              := p_stsv_rec1.ste_code;
    l_stsv_rec.sfwt_flag             := p_stsv_rec1.sfwt_flag;
    l_stsv_rec.object_version_number := p_stsv_rec1.object_version_number;
    l_stsv_rec.default_yn            := p_stsv_rec1.default_yn;
    l_stsv_rec.created_by            := p_stsv_rec1.created_by;
    l_stsv_rec.creation_date         := p_stsv_rec1.creation_date;
    l_stsv_rec.last_updated_by       := p_stsv_rec1.last_updated_by;
    l_stsv_rec.last_update_date      := p_stsv_rec1.last_update_date;
    l_stsv_rec.last_update_login     := p_stsv_rec1.last_update_login;
    l_stsv_rec.meaning               := p_stsv_rec2.meaning;
    l_stsv_rec.description           := p_stsv_rec2.description;
    l_stsv_rec.start_date            := p_stsv_rec2.start_date;
    l_stsv_rec.end_date              := p_stsv_rec2.end_date;
    RETURN (l_stsv_rec);
  END migrate_stsv;

  --------------------------------------
  --PROCEDURE create_assent
  --------------------------------------
  PROCEDURE create_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_rec                     IN astv_rec_type,
     x_astv_rec                     OUT NOCOPY astv_rec_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'create_assent';
     l_astv_rec                     astv_rec_type := p_astv_rec;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

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
     g_astv_rec := l_astv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_astv_rec := migrate_astv(l_astv_rec, g_astv_rec);


     OKC_ASSENT_PVT.create_assent(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         l_astv_rec,
                         x_astv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

     -- Call user hook for AFTER
     g_astv_rec := x_astv_rec;
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

  END create_assent;

  --------------------------------------
  --PROCEDURE create_assent
  --------------------------------------
  PROCEDURE create_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_tbl                     IN  astv_tbl_type,
     x_astv_tbl                     OUT NOCOPY astv_tbl_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'create_assent';
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_astv_tbl.COUNT > 0 THEN
       i := p_astv_tbl.FIRST;
       LOOP
       create_assent(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_astv_rec            => p_astv_tbl(i),
                         x_astv_rec            => x_astv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_astv_tbl.LAST);
       i := p_astv_tbl.NEXT(i);
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

  END create_assent;

  --------------------------------------
  --PROCEDURE update_assent
  --------------------------------------
  PROCEDURE update_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_rec                     IN  astv_rec_type,
     x_astv_rec                     OUT NOCOPY astv_rec_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'update_assent';
     l_astv_rec                     astv_rec_type := p_astv_rec;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

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
     g_astv_rec := l_astv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_astv_rec := migrate_astv(l_astv_rec, g_astv_rec);

     OKC_ASSENT_PVT.update_assent(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         l_astv_rec,
                         x_astv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_astv_rec := x_astv_rec;
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

  END update_assent;

  --------------------------------------
  --PROCEDURE update_assent
  --------------------------------------
  PROCEDURE update_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_tbl                     IN  astv_tbl_type,
     x_astv_tbl                     OUT NOCOPY astv_tbl_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'update_assent';
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_astv_tbl.COUNT > 0 THEN
       i := p_astv_tbl.FIRST;
       LOOP
       update_assent(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_astv_rec            => p_astv_tbl(i),
                         x_astv_rec            => x_astv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_astv_tbl.LAST);
       i := p_astv_tbl.NEXT(i);
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

  END update_assent;

  --------------------------------------
  --PROCEDURE delete_assent
  --------------------------------------
  PROCEDURE delete_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_rec                     IN  astv_rec_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'delete_assent';
     l_astv_rec                     astv_rec_type := p_astv_rec;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

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
     g_astv_rec := l_astv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_astv_rec := migrate_astv(l_astv_rec, g_astv_rec);

     OKC_ASSENT_PVT.delete_assent(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_astv_rec);

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

  END delete_assent;

  --------------------------------------
  --PROCEDURE delete_assent
  --------------------------------------
  PROCEDURE delete_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_tbl                     IN astv_tbl_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'delete_assent';
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_astv_tbl.COUNT > 0 THEN
       i := p_astv_tbl.FIRST;
       LOOP
       delete_assent(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_astv_rec            => p_astv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_astv_tbl.LAST);
       i := p_astv_tbl.NEXT(i);
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

  END delete_assent;

  --------------------------------------
  --PROCEDURE validate_assent
  --------------------------------------
  PROCEDURE validate_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_rec                     IN astv_rec_type) IS
  BEGIN
     OKC_ASSENT_PVT.validate_assent(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_astv_rec            => p_astv_rec);
  END validate_assent;

  --------------------------------------
  --PROCEDURE validate_assent
  --------------------------------------
  PROCEDURE validate_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_tbl                     IN astv_tbl_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'validate_assent';
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_astv_tbl.COUNT > 0 THEN
       i := p_astv_tbl.FIRST;
       LOOP
       validate_assent(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_astv_rec            => p_astv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_astv_tbl.LAST);
       i := p_astv_tbl.NEXT(i);
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

  END validate_assent;

  --------------------------------------
  --PROCEDURE lock_assent
  --------------------------------------
  PROCEDURE lock_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_rec                     IN astv_rec_type) IS
  BEGIN
     OKC_ASSENT_PVT.lock_assent(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_astv_rec            => p_astv_rec);

  END lock_assent;

  --------------------------------------
  --PROCEDURE lock_assent
  --------------------------------------
  PROCEDURE lock_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_tbl                     IN astv_tbl_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'lock_assent';
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_astv_tbl.COUNT > 0 THEN
       i := p_astv_tbl.FIRST;
       LOOP
       lock_assent(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_astv_rec            => p_astv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_astv_tbl.LAST);
       i := p_astv_tbl.NEXT(i);
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

  END lock_assent;

  --------------------------------------
  -- FUNCTION header_operation_allowed
  --------------------------------------
  FUNCTION header_operation_allowed(
    p_header_id                    IN NUMBER,
    p_opn_code                     IN VARCHAR2,
    p_crt_id                       IN NUMBER ) return varchar2 IS
    l_return_status                VARCHAR2(1);
  BEGIN
    l_return_status := OKC_ASSENT_PVT.header_operation_allowed(
                                                              p_header_id,
                                                              p_opn_code,
												  p_crt_id);
    Return(l_return_status);
  END header_operation_allowed;

  --------------------------------------
  -- FUNCTION line_operation_allowed
  --------------------------------------
  FUNCTION line_operation_allowed(
    p_line_id                      IN NUMBER,
    p_opn_code                     IN VARCHAR2) return varchar2 IS
    l_return_status                VARCHAR2(1);
  BEGIN
    l_return_status := OKC_ASSENT_PVT.line_operation_allowed(
                                                            p_line_id,
                                                            p_opn_code);
    Return(l_return_status);
  END line_operation_allowed;

  --------------------------------------
  --PROCEDURE create_status
  --------------------------------------
  PROCEDURE create_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_rec                     IN stsv_rec_type,
     x_stsv_rec                     OUT NOCOPY stsv_rec_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'create_status';
     l_stsv_rec                     stsv_rec_type := p_stsv_rec;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

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
     g_stsv_rec := l_stsv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_stsv_rec := migrate_stsv(l_stsv_rec, g_stsv_rec);

     OKC_ASSENT_PVT.create_status(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         l_stsv_rec,
                         x_stsv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

     -- Call user hook for AFTER
     g_stsv_rec := x_stsv_rec;
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

  END create_status;

  --------------------------------------
  --PROCEDURE create_status
  --------------------------------------
  PROCEDURE create_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_tbl                     IN  stsv_tbl_type,
     x_stsv_tbl                     OUT NOCOPY stsv_tbl_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'create_status';
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_stsv_tbl.COUNT > 0 THEN
       i := p_stsv_tbl.FIRST;
       LOOP
       create_status(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_stsv_rec            => p_stsv_tbl(i),
                         x_stsv_rec            => x_stsv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_stsv_tbl.LAST);
       i := p_stsv_tbl.NEXT(i);
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

  END create_status;

  --------------------------------------
  --PROCEDURE update_status
  --------------------------------------
  PROCEDURE update_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_rec                     IN stsv_rec_type,
     x_stsv_rec                     OUT NOCOPY stsv_rec_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'update_status';
     l_stsv_rec                     stsv_rec_type := p_stsv_rec;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

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
     g_stsv_rec := l_stsv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_stsv_rec := migrate_stsv(l_stsv_rec, g_stsv_rec);

     OKC_ASSENT_PVT.update_status(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         l_stsv_rec,
                         x_stsv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

     -- Call user hook for AFTER
     g_stsv_rec := x_stsv_rec;
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

  END update_status;

  --------------------------------------
  --PROCEDURE update_status
  --------------------------------------
  PROCEDURE update_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_tbl                     IN  stsv_tbl_type,
     x_stsv_tbl                     OUT NOCOPY stsv_tbl_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'update_status';
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_stsv_tbl.COUNT > 0 THEN
       i := p_stsv_tbl.FIRST;
       LOOP
       update_status(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_stsv_rec            => p_stsv_tbl(i),
                         x_stsv_rec            => x_stsv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_stsv_tbl.LAST);
       i := p_stsv_tbl.NEXT(i);
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

  END update_status;

  --------------------------------------
  --PROCEDURE delete_status
  --------------------------------------
  PROCEDURE delete_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_rec                     IN stsv_rec_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'delete_status';
     l_stsv_rec                     stsv_rec_type := p_stsv_rec;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

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
     g_stsv_rec := l_stsv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_stsv_rec := migrate_stsv(l_stsv_rec, g_stsv_rec);

     OKC_ASSENT_PVT.delete_status(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_stsv_rec);
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

  END delete_status;

  --------------------------------------
  --PROCEDURE delete_status
  --------------------------------------
  PROCEDURE delete_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_tbl                     IN  stsv_tbl_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'delete_status';
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_stsv_tbl.COUNT > 0 THEN
       i := p_stsv_tbl.FIRST;
       LOOP
       delete_status(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_stsv_rec            => p_stsv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_stsv_tbl.LAST);
       i := p_stsv_tbl.NEXT(i);
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

  END delete_status;

  --------------------------------------
  --PROCEDURE lock_status
  --------------------------------------
  PROCEDURE lock_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_rec                     IN stsv_rec_type) IS

  BEGIN
     OKC_ASSENT_PVT.lock_status(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_stsv_rec);
  END lock_status;

  --------------------------------------
  --PROCEDURE lock_status
  --------------------------------------
  PROCEDURE lock_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_tbl                     IN  stsv_tbl_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'lock_status';
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_stsv_tbl.COUNT > 0 THEN
       i := p_stsv_tbl.FIRST;
       LOOP
       lock_status(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_stsv_rec            => p_stsv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_stsv_tbl.LAST);
       i := p_stsv_tbl.NEXT(i);
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

  END lock_status;

  --------------------------------------
  --PROCEDURE validate_status
  --------------------------------------
  PROCEDURE validate_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_rec                     IN stsv_rec_type) IS

  BEGIN
     OKC_ASSENT_PVT.validate_status(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_stsv_rec);
  END validate_status;

  --------------------------------------
  --PROCEDURE validate_status
  --------------------------------------
  PROCEDURE validate_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_tbl                     IN  stsv_tbl_type) IS
     l_api_name      CONSTANT VARCHAR2(30) := 'validate_status';
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_stsv_tbl.COUNT > 0 THEN
       i := p_stsv_tbl.FIRST;
       LOOP
       validate_status(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_stsv_rec            => p_stsv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_stsv_tbl.LAST);
       i := p_stsv_tbl.NEXT(i);
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

  END validate_status;

  PROCEDURE get_default_status(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_status_type                  IN VARCHAR2,
    x_status_code                  OUT NOCOPY VARCHAR2) IS
  BEGIN
     OKC_ASSENT_PVT.get_default_status(
                               x_return_status,
                               p_status_type,
                               x_status_code);
  END get_default_status;

  PROCEDURE validate_unique_code(x_return_status OUT NOCOPY VARCHAR2,
                                       p_stsv_rec IN stsv_rec_type) IS
  BEGIN
    OKC_ASSENT_PVT.validate_unique_code(p_stsv_rec, x_return_status);
  END  validate_unique_code;

  PROCEDURE validate_unique_meaning(x_return_status OUT NOCOPY VARCHAR2,
                                       p_stsv_rec IN stsv_rec_type) IS
  BEGIN
    OKC_ASSENT_PVT.validate_unique_meaning(p_stsv_rec, x_return_status);
  END  validate_unique_meaning;



 PROCEDURE validate_unique_code(
 x_return_status 	 OUT NOCOPY VARCHAR2,
 p_stsv_tbl                     IN  stsv_tbl_type) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(OKC_API.G_FALSE);
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_stsv_tbl.COUNT > 0 THEN
      i := p_stsv_tbl.FIRST;
      LOOP
        validate_unique_code(l_return_status, p_stsv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_stsv_tbl.LAST);
        i := p_stsv_tbl.NEXT(i);
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
  END validate_unique_code;

 PROCEDURE validate_unique_meaning(
 x_return_status                OUT NOCOPY VARCHAR2,
 p_stsv_tbl                     IN  stsv_tbl_type) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(OKC_API.G_FALSE);
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_stsv_tbl.COUNT > 0 THEN
      i := p_stsv_tbl.FIRST;
      LOOP
        validate_unique_meaning(l_return_status, p_stsv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_stsv_tbl.LAST);
        i := p_stsv_tbl.NEXT(i);
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
  END validate_unique_meaning;


END okc_assent_pub;

/
