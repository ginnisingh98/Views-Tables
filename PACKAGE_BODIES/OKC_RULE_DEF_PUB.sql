--------------------------------------------------------
--  DDL for Package Body OKC_RULE_DEF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RULE_DEF_PUB" AS
/* $Header: OKCPRGDB.pls 120.0 2005/05/25 19:14:08 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  l_init_msg_list                VARCHAR2(1) := OKC_API.G_FALSE;

  FUNCTION migrate_rdsv(p_rdsv_rec1 IN rdsv_rec_type,
                        p_rdsv_rec2 IN rdsv_rec_type)
    RETURN rdsv_rec_type IS
    l_rdsv_rec rdsv_rec_type;
  BEGIN
    l_rdsv_rec.row_id                := p_rdsv_rec1.row_id;
    l_rdsv_rec.object_version_number := p_rdsv_rec1.object_version_number;
    l_rdsv_rec.created_by            := p_rdsv_rec1.created_by;
    l_rdsv_rec.creation_date         := p_rdsv_rec1.creation_date;
    l_rdsv_rec.last_updated_by       := p_rdsv_rec1.last_updated_by;
    l_rdsv_rec.last_update_date      := p_rdsv_rec1.last_update_date;
    l_rdsv_rec.last_update_login     := p_rdsv_rec1.last_update_login;
    l_rdsv_rec.rgr_rgd_code          := p_rdsv_rec2.rgr_rgd_code;
    l_rdsv_rec.rgr_rdf_code          := p_rdsv_rec2.rgr_rdf_code;
    l_rdsv_rec.buy_or_sell           := p_rdsv_rec2.buy_or_sell;
    l_rdsv_rec.access_level          := p_rdsv_rec2.access_level;
    l_rdsv_rec.start_date            := p_rdsv_rec2.start_date;
    l_rdsv_rec.end_date              := p_rdsv_rec2.end_date;
    l_rdsv_rec.jtot_object_code      := p_rdsv_rec2.jtot_object_code;
    l_rdsv_rec.object_id_number      := p_rdsv_rec2.object_id_number;
    RETURN (l_rdsv_rec);
  END migrate_rdsv;

  FUNCTION migrate_rgrv(p_rgrv_rec1 IN rgrv_rec_type,
                        p_rgrv_rec2 IN rgrv_rec_type)
    RETURN rgrv_rec_type IS
    l_rgrv_rec rgrv_rec_type;
  BEGIN
    l_rgrv_rec.object_version_number := p_rgrv_rec1.object_version_number;
    l_rgrv_rec.created_by            := p_rgrv_rec1.created_by;
    l_rgrv_rec.creation_date         := p_rgrv_rec1.creation_date;
    l_rgrv_rec.last_updated_by       := p_rgrv_rec1.last_updated_by;
    l_rgrv_rec.last_update_date      := p_rgrv_rec1.last_update_date;
    l_rgrv_rec.last_update_login     := p_rgrv_rec1.last_update_login;
    l_rgrv_rec.min_cardinality       := p_rgrv_rec1.min_cardinality;
    l_rgrv_rec.max_cardinality       := p_rgrv_rec1.max_cardinality;
    l_rgrv_rec.pricing_related_yn    := p_rgrv_rec1.pricing_related_yn;
    l_rgrv_rec.access_level          := p_rgrv_rec1.access_level;
    l_rgrv_rec.rgd_code              := p_rgrv_rec2.rgd_code;
    l_rgrv_rec.rdf_code              := p_rgrv_rec2.rdf_code;
    l_rgrv_rec.optional_yn           := p_rgrv_rec2.optional_yn;
    RETURN (l_rgrv_rec);
  END migrate_rgrv;

  --------------------------------------
  --PROCEDURE create_rg_def_rule
  --------------------------------------
  PROCEDURE create_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_rec                     IN rgrv_rec_type,
     x_rgrv_rec                     OUT NOCOPY rgrv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'create_rg_def_rule';
     l_rgrv_rec                     rgrv_rec_type := p_rgrv_rec;
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
     g_rgrv_rec := l_rgrv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_rgrv_rec := migrate_rgrv(l_rgrv_rec, g_rgrv_rec);

     OKC_RULE_DEF_PVT.create_rg_def_rule(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rgrv_rec            => l_rgrv_rec,
                         x_rgrv_rec            => x_rgrv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_rgrv_rec := x_rgrv_rec;
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

  END create_rg_def_rule;

  --------------------------------------
  --PROCEDURE create_rg_def_rule
  --------------------------------------
  PROCEDURE create_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_tbl                     IN rgrv_tbl_type,
     x_rgrv_tbl                     OUT NOCOPY rgrv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_rgrv_tbl.COUNT > 0 THEN
       i := p_rgrv_tbl.FIRST;
       LOOP
       create_rg_def_rule(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rgrv_rec            => p_rgrv_tbl(i),
                         x_rgrv_rec            => x_rgrv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_rgrv_tbl.LAST);
       i := p_rgrv_tbl.NEXT(i);
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
  END create_rg_def_rule;


  --------------------------------------
  --PROCEDURE update_rg_def_rule
  --------------------------------------
  PROCEDURE update_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_rec                     IN rgrv_rec_type,
     x_rgrv_rec                     OUT NOCOPY rgrv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'update_rg_def_rule';
     l_rgrv_rec                     rgrv_rec_type := p_rgrv_rec;
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
     g_rgrv_rec := l_rgrv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_rgrv_rec := migrate_rgrv(l_rgrv_rec, g_rgrv_rec);

     OKC_RULE_DEF_PVT.update_rg_def_rule(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rgrv_rec            => l_rgrv_rec,
                         x_rgrv_rec            => x_rgrv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_rgrv_rec := x_rgrv_rec;
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

  END update_rg_def_rule;

  --------------------------------------
  --PROCEDURE update_rg_def_rule
  --------------------------------------
  PROCEDURE update_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_tbl                     IN rgrv_tbl_type,
     x_rgrv_tbl                     OUT NOCOPY rgrv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_rgrv_tbl.COUNT > 0 THEN
       i := p_rgrv_tbl.FIRST;
       LOOP
       update_rg_def_rule(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rgrv_rec            => p_rgrv_tbl(i),
                         x_rgrv_rec            => x_rgrv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_rgrv_tbl.LAST);
       i := p_rgrv_tbl.NEXT(i);
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
  END update_rg_def_rule;

  --------------------------------------
  --PROCEDURE delete_rg_def_rule
  --------------------------------------
  PROCEDURE delete_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_rec                     IN rgrv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'delete_rg_def_rule';
     l_rgrv_rec                     rgrv_rec_type := p_rgrv_rec;
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
     g_rgrv_rec := l_rgrv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKC_RULE_DEF_PVT.delete_rg_def_rule(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rgrv_rec            => p_rgrv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_rgrv_rec := l_rgrv_rec;
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

  END delete_rg_def_rule;

  --------------------------------------
  --PROCEDURE delete_rg_def_rule
  --------------------------------------
  PROCEDURE delete_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_tbl                     IN rgrv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_rgrv_tbl.COUNT > 0 THEN
       i := p_rgrv_tbl.FIRST;
       LOOP
       delete_rg_def_rule(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rgrv_rec            => p_rgrv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_rgrv_tbl.LAST);
       i := p_rgrv_tbl.NEXT(i);
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
  END delete_rg_def_rule;

  --------------------------------------
  --PROCEDURE validate_rg_def_rule
  --------------------------------------
  PROCEDURE validate_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_rec                     IN rgrv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'validate_rg_def_rule';
     l_rgrv_rec                     rgrv_rec_type := p_rgrv_rec;
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
     g_rgrv_rec := l_rgrv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKC_RULE_DEF_PVT.validate_rg_def_rule(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rgrv_rec            => p_rgrv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_rgrv_rec := l_rgrv_rec;
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
  END validate_rg_def_rule;

  --------------------------------------
  --PROCEDURE validate_rg_def_rule
  --------------------------------------
  PROCEDURE validate_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_tbl                     IN rgrv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_rgrv_tbl.COUNT > 0 THEN
       i := p_rgrv_tbl.FIRST;
       LOOP
       validate_rg_def_rule(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rgrv_rec            => p_rgrv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_rgrv_tbl.LAST);
       i := p_rgrv_tbl.NEXT(i);
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
  END validate_rg_def_rule;

  --------------------------------------
  --PROCEDURE lock_rg_def_rule
  --------------------------------------
  PROCEDURE lock_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_rec                     IN rgrv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
     OKC_RULE_DEF_PVT.lock_rg_def_rule(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rgrv_rec            => p_rgrv_rec);
  END lock_rg_def_rule;

  --------------------------------------
  --PROCEDURE lock_rg_def_rule
  --------------------------------------
  PROCEDURE lock_rg_def_rule(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rgrv_tbl                     IN rgrv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_rgrv_tbl.COUNT > 0 THEN
       i := p_rgrv_tbl.FIRST;
       LOOP
       lock_rg_def_rule(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rgrv_rec            => p_rgrv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_rgrv_tbl.LAST);
       i := p_rgrv_tbl.NEXT(i);
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
  END lock_rg_def_rule;

  --------------------------------------
  --PROCEDURE create_rd_source
  --------------------------------------
  PROCEDURE create_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_rec                     IN rdsv_rec_type,
     x_rdsv_rec                     OUT NOCOPY rdsv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'create_rd_source';
     l_rdsv_rec                     rdsv_rec_type := p_rdsv_rec;
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
     g_rdsv_rec := l_rdsv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_rdsv_rec := migrate_rdsv(l_rdsv_rec, g_rdsv_rec);

     OKC_RULE_DEF_PVT.create_rd_source(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rdsv_rec            => l_rdsv_rec,
                         x_rdsv_rec            => x_rdsv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_rdsv_rec := x_rdsv_rec;
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
  END create_rd_source;

  --------------------------------------
  --PROCEDURE create_rd_source
  --------------------------------------
  PROCEDURE create_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_tbl                     IN rdsv_tbl_type,
     x_rdsv_tbl                     OUT NOCOPY rdsv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_rdsv_tbl.COUNT > 0 THEN
       i := p_rdsv_tbl.FIRST;
       LOOP
       create_rd_source(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rdsv_rec            => p_rdsv_tbl(i),
                         x_rdsv_rec            => x_rdsv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_rdsv_tbl.LAST);
       i := p_rdsv_tbl.NEXT(i);
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
  END create_rd_source;

  --------------------------------------
  --PROCEDURE update_rd_source
  --------------------------------------
  PROCEDURE update_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_rec                     IN rdsv_rec_type,
     x_rdsv_rec                     OUT NOCOPY rdsv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'update_rd_source';
     l_rdsv_rec                     rdsv_rec_type := p_rdsv_rec;
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
     g_rdsv_rec := l_rdsv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_rdsv_rec := migrate_rdsv(l_rdsv_rec, g_rdsv_rec);

     OKC_RULE_DEF_PVT.update_rd_source(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rdsv_rec            => l_rdsv_rec,
                         x_rdsv_rec            => x_rdsv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_rdsv_rec := x_rdsv_rec;
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
  END update_rd_source;

  --------------------------------------
  --PROCEDURE update_rd_source
  --------------------------------------
  PROCEDURE update_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_tbl                     IN rdsv_tbl_type,
     x_rdsv_tbl                     OUT NOCOPY rdsv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_rdsv_tbl.COUNT > 0 THEN
       i := p_rdsv_tbl.FIRST;
       LOOP
       update_rd_source(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rdsv_rec            => p_rdsv_tbl(i),
                         x_rdsv_rec            => x_rdsv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_rdsv_tbl.LAST);
       i := p_rdsv_tbl.NEXT(i);
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
  END update_rd_source;

  --------------------------------------
  --PROCEDURE delete_rd_source
  --------------------------------------
  PROCEDURE delete_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_rec                     IN rdsv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'delete_rd_source';
     l_rdsv_rec                     rdsv_rec_type := p_rdsv_rec;
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
     g_rdsv_rec := l_rdsv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKC_RULE_DEF_PVT.delete_rd_source(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rdsv_rec            => p_rdsv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_rdsv_rec := l_rdsv_rec;
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
  END delete_rd_source;

  --------------------------------------
  --PROCEDURE delete_rd_source
  --------------------------------------
  PROCEDURE delete_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_tbl                     IN rdsv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_rdsv_tbl.COUNT > 0 THEN
       i := p_rdsv_tbl.FIRST;
       LOOP
       delete_rd_source(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rdsv_rec            => p_rdsv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_rdsv_tbl.LAST);
       i := p_rdsv_tbl.NEXT(i);
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
  END delete_rd_source;

  --------------------------------------
  --PROCEDURE validate_rd_source
  --------------------------------------
  PROCEDURE validate_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_rec                     IN rdsv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'validate_rd_source';
     l_rdsv_rec                     rdsv_rec_type := p_rdsv_rec;
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
     g_rdsv_rec := l_rdsv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKC_RULE_DEF_PVT.validate_rd_source(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rdsv_rec            => p_rdsv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_rdsv_rec := l_rdsv_rec;
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
  END validate_rd_source;

  --------------------------------------
  --PROCEDURE validate_rd_source
  --------------------------------------
  PROCEDURE validate_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_tbl                     IN rdsv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_rdsv_tbl.COUNT > 0 THEN
       i := p_rdsv_tbl.FIRST;
       LOOP
       validate_rd_source(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rdsv_rec            => p_rdsv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_rdsv_tbl.LAST);
       i := p_rdsv_tbl.NEXT(i);
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
  END validate_rd_source;

  --------------------------------------
  --PROCEDURE lock_rd_source
  --------------------------------------
  PROCEDURE lock_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_rec                     IN rdsv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
     OKC_RULE_DEF_PVT.lock_rd_source(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rdsv_rec            => p_rdsv_rec);
  END lock_rd_source;

  --------------------------------------
  --PROCEDURE lock_rd_source
  --------------------------------------
  PROCEDURE lock_rd_source(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rdsv_tbl                     IN rdsv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_rdsv_tbl.COUNT > 0 THEN
       i := p_rdsv_tbl.FIRST;
       LOOP
       lock_rd_source(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_rdsv_rec            => p_rdsv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           raise G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
       EXIT WHEN (i = p_rdsv_tbl.LAST);
       i := p_rdsv_tbl.NEXT(i);
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
  END lock_rd_source;

END okc_rule_def_pub;

/
