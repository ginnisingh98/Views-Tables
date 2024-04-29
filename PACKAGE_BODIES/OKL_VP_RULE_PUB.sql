--------------------------------------------------------
--  DDL for Package Body OKL_VP_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_RULE_PUB" AS
/* $Header: OKLPRLGB.pls 115.5 2004/04/21 06:46:33 rnaik noship $ */
G_GEN_COMMENTS VARCHAR2(1) := 'T';

  ---------------------------------------------------------------------------
  -- FUNCTION migrate_rgpv
  ---------------------------------------------------------------------------
  FUNCTION migrate_rgpv (
    p_rgpv_rec1 IN rgpv_rec_type,
    p_rgpv_rec2 IN rgpv_rec_type
  ) RETURN rgpv_rec_type IS
    l_rgpv_rec rgpv_rec_type;
  BEGIN
    l_rgpv_rec.id                    := p_rgpv_rec1.id;
    l_rgpv_rec.object_version_number := p_rgpv_rec1.object_version_number;
    l_rgpv_rec.created_by            := p_rgpv_rec1.created_by;
    l_rgpv_rec.creation_date         := p_rgpv_rec1.creation_date;
    l_rgpv_rec.last_updated_by       := p_rgpv_rec1.last_updated_by;
    l_rgpv_rec.last_update_date      := p_rgpv_rec1.last_update_date;
    l_rgpv_rec.last_update_login     := p_rgpv_rec1.last_update_login;
    l_rgpv_rec.rgd_code              := p_rgpv_rec2.rgd_code;
    l_rgpv_rec.sat_code              := p_rgpv_rec2.sat_code;
    l_rgpv_rec.rgp_type              := p_rgpv_rec2.rgp_type;
    l_rgpv_rec.cle_id                := p_rgpv_rec2.cle_id;
    l_rgpv_rec.chr_id                := p_rgpv_rec2.chr_id;
    l_rgpv_rec.dnz_chr_id            := p_rgpv_rec2.dnz_chr_id;
    l_rgpv_rec.parent_rgp_id         := p_rgpv_rec2.parent_rgp_id;
    l_rgpv_rec.sfwt_flag             := p_rgpv_rec2.sfwt_flag;
    l_rgpv_rec.comments              := p_rgpv_rec2.comments;
    l_rgpv_rec.attribute_category    := p_rgpv_rec2.attribute_category;
    l_rgpv_rec.attribute1            := p_rgpv_rec2.attribute1;
    l_rgpv_rec.attribute2            := p_rgpv_rec2.attribute2;
    l_rgpv_rec.attribute3            := p_rgpv_rec2.attribute3;
    l_rgpv_rec.attribute4            := p_rgpv_rec2.attribute4;
    l_rgpv_rec.attribute5            := p_rgpv_rec2.attribute5;
    l_rgpv_rec.attribute6            := p_rgpv_rec2.attribute6;
    l_rgpv_rec.attribute7            := p_rgpv_rec2.attribute7;
    l_rgpv_rec.attribute8            := p_rgpv_rec2.attribute8;
    l_rgpv_rec.attribute9            := p_rgpv_rec2.attribute9;
    l_rgpv_rec.attribute10           := p_rgpv_rec2.attribute10;
    l_rgpv_rec.attribute11           := p_rgpv_rec2.attribute11;
    l_rgpv_rec.attribute12           := p_rgpv_rec2.attribute12;
    l_rgpv_rec.attribute13           := p_rgpv_rec2.attribute13;
    l_rgpv_rec.attribute14           := p_rgpv_rec2.attribute14;
    l_rgpv_rec.attribute15           := p_rgpv_rec2.attribute15;
    RETURN (l_rgpv_rec);
  END migrate_rgpv;
  --------------------------------------
  -- PROCEDURE create_rule_group
  --------------------------------------
  PROCEDURE create_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;
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
    g_rgpv_rec := p_rgpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rgpv_rec := migrate_rgpv(l_rgpv_rec, g_rgpv_rec);
     OKL_VP_RULE_PVT.create_rule_group(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => l_rgpv_rec,
      x_rgpv_rec      => x_rgpv_rec);
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     g_rgpv_rec := x_rgpv_rec;
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
  END create_rule_group;
  --------------------------------------
  -- PROCEDURE create_rule_group
  --------------------------------------
  PROCEDURE create_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type,
    x_rgpv_tbl                     OUT NOCOPY rgpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rgpv_tbl.COUNT > 0 THEN
      i := p_rgpv_tbl.FIRST;
      LOOP
        create_rule_group(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rgpv_rec      => p_rgpv_tbl(i),
          x_rgpv_rec      => x_rgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rgpv_tbl.LAST);
        i := p_rgpv_tbl.NEXT(i);
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
  END create_rule_group;
  --------------------------------------
  -- PROCEDURE update_rule_group
  --------------------------------------
  PROCEDURE update_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;
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
    g_rgpv_rec := p_rgpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rgpv_rec := migrate_rgpv(l_rgpv_rec, g_rgpv_rec);
     OKL_VP_RULE_PVT.update_rule_group(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => l_rgpv_rec,
      x_rgpv_rec      => x_rgpv_rec);
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     g_rgpv_rec := x_rgpv_rec;
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
  END update_rule_group;
  --------------------------------------
  -- PROCEDURE update_rule_group
  --------------------------------------
  PROCEDURE update_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type,
    x_rgpv_tbl                     OUT NOCOPY rgpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rgpv_tbl.COUNT > 0 THEN
      i := p_rgpv_tbl.FIRST;
      LOOP
        update_rule_group(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rgpv_rec      => p_rgpv_tbl(i),
          x_rgpv_rec      => x_rgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rgpv_tbl.LAST);
        i := p_rgpv_tbl.NEXT(i);
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
  END update_rule_group;
  --------------------------------------
  -- PROCEDURE delete_rule_group
  --------------------------------------
  PROCEDURE delete_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;
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
    g_rgpv_rec := p_rgpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
     OKL_VP_RULE_PVT.delete_rule_group(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => p_rgpv_rec);
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     g_rgpv_rec := l_rgpv_rec;
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
  END delete_rule_group;
  --------------------------------------
  -- PROCEDURE delete_rule_group
  --------------------------------------
  PROCEDURE delete_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rgpv_tbl.COUNT > 0 THEN
      i := p_rgpv_tbl.FIRST;
      LOOP
        delete_rule_group(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rgpv_rec      => p_rgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rgpv_tbl.LAST);
        i := p_rgpv_tbl.NEXT(i);
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
  END delete_rule_group;

END OKL_VP_RULE_PUB;

/
