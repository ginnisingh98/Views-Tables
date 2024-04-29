--------------------------------------------------------
--  DDL for Package Body OKC_CONTRACT_GROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONTRACT_GROUP_PUB" as
/* $Header: OKCPCGPB.pls 120.0 2005/05/25 18:57:50 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  FUNCTION migrate_cgpv(p_cgpv_rec1 IN cgpv_rec_type,
                        p_cgpv_rec2 IN cgpv_rec_type)
    RETURN cgpv_rec_type IS
    l_cgpv_rec cgpv_rec_type;
  BEGIN
    l_cgpv_rec.id                    := p_cgpv_rec1.id;
    l_cgpv_rec.object_version_number := p_cgpv_rec1.object_version_number;
    l_cgpv_rec.created_by            := p_cgpv_rec1.created_by;
    l_cgpv_rec.creation_date         := p_cgpv_rec1.creation_date;
    l_cgpv_rec.last_updated_by       := p_cgpv_rec1.last_updated_by;
    l_cgpv_rec.last_update_date      := p_cgpv_rec1.last_update_date;
    l_cgpv_rec.user_id               := p_cgpv_rec1.user_id;
    l_cgpv_rec.last_update_login     := p_cgpv_rec1.last_update_login;
    l_cgpv_rec.sfwt_flag             := p_cgpv_rec2.sfwt_flag;
    l_cgpv_rec.name                  := p_cgpv_rec2.name;
    l_cgpv_rec.public_yn             := p_cgpv_rec2.public_yn;
    l_cgpv_rec.short_description     := p_cgpv_rec2.short_description;
    l_cgpv_rec.attribute_category    := p_cgpv_rec2.attribute_category;
    l_cgpv_rec.attribute1            := p_cgpv_rec2.attribute1;
    l_cgpv_rec.attribute2            := p_cgpv_rec2.attribute2;
    l_cgpv_rec.attribute3            := p_cgpv_rec2.attribute3;
    l_cgpv_rec.attribute4            := p_cgpv_rec2.attribute4;
    l_cgpv_rec.attribute5            := p_cgpv_rec2.attribute5;
    l_cgpv_rec.attribute6            := p_cgpv_rec2.attribute6;
    l_cgpv_rec.attribute7            := p_cgpv_rec2.attribute7;
    l_cgpv_rec.attribute8            := p_cgpv_rec2.attribute8;
    l_cgpv_rec.attribute9            := p_cgpv_rec2.attribute9;
    l_cgpv_rec.attribute10           := p_cgpv_rec2.attribute10;
    l_cgpv_rec.attribute11           := p_cgpv_rec2.attribute11;
    l_cgpv_rec.attribute12           := p_cgpv_rec2.attribute12;
    l_cgpv_rec.attribute13           := p_cgpv_rec2.attribute13;
    l_cgpv_rec.attribute14           := p_cgpv_rec2.attribute14;
    l_cgpv_rec.attribute15           := p_cgpv_rec2.attribute15;
    RETURN (l_cgpv_rec);
  END migrate_cgpv;

  FUNCTION migrate_cgpv(p_cgpv_tbl1 IN cgpv_tbl_type,
                        p_cgpv_tbl2 IN cgpv_tbl_type)
    RETURN cgpv_tbl_type IS
    l_cgpv_tbl cgpv_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    -- If the user hook deleted some records or added some new records in the table,
    -- discard the change and simply copy the original table.
    IF p_cgpv_tbl1.COUNT <> p_cgpv_tbl2.COUNT THEN
      l_cgpv_tbl := p_cgpv_tbl1;
    ELSE
      IF (p_cgpv_tbl1.COUNT > 0) THEN
        i := p_cgpv_tbl1.FIRST;
        j := p_cgpv_tbl2.FIRST;
        LOOP
          l_cgpv_tbl(i) := migrate_cgpv(p_cgpv_tbl1(i), p_cgpv_tbl2(j));
          EXIT WHEN (i = p_cgpv_tbl1.LAST);
          i := p_cgpv_tbl1.NEXT(i);
          j := p_cgpv_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_cgpv_tbl);
  END migrate_cgpv;

  FUNCTION migrate_cgcv(p_cgcv_rec1 IN cgcv_rec_type,
                        p_cgcv_rec2 IN cgcv_rec_type)
    RETURN cgcv_rec_type IS
    l_cgcv_rec cgcv_rec_type;
  BEGIN
    l_cgcv_rec.id                    := p_cgcv_rec1.id;
    l_cgcv_rec.object_version_number := p_cgcv_rec1.object_version_number;
    l_cgcv_rec.created_by            := p_cgcv_rec1.created_by;
    l_cgcv_rec.creation_date         := p_cgcv_rec1.creation_date;
    l_cgcv_rec.last_updated_by       := p_cgcv_rec1.last_updated_by;
    l_cgcv_rec.last_update_date      := p_cgcv_rec1.last_update_date;
    l_cgcv_rec.last_update_login     := p_cgcv_rec1.last_update_login;
    l_cgcv_rec.cgp_parent_id         := p_cgcv_rec2.cgp_parent_id;
    l_cgcv_rec.included_chr_id       := p_cgcv_rec2.included_chr_id;
    l_cgcv_rec.included_cgp_id       := p_cgcv_rec2.included_cgp_id;
    l_cgcv_rec.scs_code              := p_cgcv_rec2.scs_code;
    RETURN (l_cgcv_rec);
  END migrate_cgcv;

  FUNCTION migrate_cgcv(p_cgcv_tbl1 IN cgcv_tbl_type,
                        p_cgcv_tbl2 IN cgcv_tbl_type)
    RETURN cgcv_tbl_type IS
    l_cgcv_tbl cgcv_tbl_type;
    i NUMBER := 0;
    j NUMBER := 0;
  BEGIN
    IF p_cgcv_tbl1.COUNT <> p_cgcv_tbl2.COUNT THEN
      l_cgcv_tbl := p_cgcv_tbl1;
    ELSE
      IF (p_cgcv_tbl1.COUNT > 0) THEN
        i := p_cgcv_tbl1.FIRST;
        j := p_cgcv_tbl2.FIRST;
        LOOP
          l_cgcv_tbl(i) := migrate_cgcv(p_cgcv_tbl1(i), p_cgcv_tbl2(j));
          EXIT WHEN (i = p_cgcv_tbl1.LAST);
          i := p_cgcv_tbl1.NEXT(i);
          j := p_cgcv_tbl2.NEXT(j);
        END LOOP;
      END IF;
    END IF;
    RETURN (l_cgcv_tbl);
  END migrate_cgcv;

  PROCEDURE add_language IS
  BEGIN
    okc_contract_group_pvt.add_language;
  END;

  PROCEDURE create_ctr_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type,
    x_cgpv_rec                     OUT NOCOPY cgpv_rec_type,
    p_cgcv_tbl                     IN cgcv_tbl_type,
    x_cgcv_tbl                     OUT NOCOPY cgcv_tbl_type) IS
  BEGIN
    okc_contract_group_pvt.create_ctr_group(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_rec,
	    x_cgpv_rec,
	    p_cgcv_tbl,
	    x_cgcv_tbl);
  END create_ctr_group;

  PROCEDURE update_ctr_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type,
    x_cgpv_rec                     OUT NOCOPY cgpv_rec_type,
    p_cgcv_tbl                     IN cgcv_tbl_type,
    x_cgcv_tbl                     OUT NOCOPY cgcv_tbl_type) IS
  BEGIN
    okc_contract_group_pvt.update_ctr_group(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_rec,
	    x_cgpv_rec,
	    p_cgcv_tbl,
	    x_cgcv_tbl);
  END update_ctr_group;

  PROCEDURE validate_ctr_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type,
    p_cgcv_tbl                     IN cgcv_tbl_type) IS
  BEGIN
    okc_contract_group_pvt.validate_ctr_group(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_rec,
	    p_cgcv_tbl);
  END validate_ctr_group;

  PROCEDURE create_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type,
    x_cgpv_rec                     OUT NOCOPY cgpv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_contract_group';
    l_return_status		   VARCHAR2(1);
    l_cgpv_rec                     cgpv_rec_type := p_cgpv_rec;
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
    g_cgpv_rec := l_cgpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_cgpv_rec := migrate_cgpv(l_cgpv_rec, g_cgpv_rec);

    okc_contract_group_pvt.create_contract_group(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    l_cgpv_rec,
	    x_cgpv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_cgpv_rec := x_cgpv_rec;
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
  END create_contract_group;

  PROCEDURE create_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_tbl                     IN cgpv_tbl_type,
    x_cgpv_tbl                     OUT NOCOPY cgpv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgpv_tbl.COUNT > 0 THEN
      i := p_cgpv_tbl.FIRST;
      LOOP
        create_contract_group(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_tbl(i),
	    x_cgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cgpv_tbl.LAST);
        i := p_cgpv_tbl.NEXT(i);
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
  END create_contract_group;

  PROCEDURE update_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type,
    x_cgpv_rec                     OUT NOCOPY cgpv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_contract_group';
    l_return_status		   VARCHAR2(1);
    l_cgpv_rec                     cgpv_rec_type := p_cgpv_rec;
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
    g_cgpv_rec := l_cgpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_cgpv_rec := migrate_cgpv(l_cgpv_rec, g_cgpv_rec);

    okc_contract_group_pvt.update_contract_group(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    l_cgpv_rec,
	    x_cgpv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_cgpv_rec := x_cgpv_rec;
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
  END update_contract_group;

  PROCEDURE update_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_tbl                     IN cgpv_tbl_type,
    x_cgpv_tbl                     OUT NOCOPY cgpv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgpv_tbl.COUNT > 0 THEN
      i := p_cgpv_tbl.FIRST;
      LOOP
        update_contract_group(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_tbl(i),
	    x_cgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cgpv_tbl.LAST);
        i := p_cgpv_tbl.NEXT(i);
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
  END update_contract_group;

  PROCEDURE delete_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_contract_group';
    l_return_status		   VARCHAR2(1);
    l_cgpv_rec                     cgpv_rec_type := p_cgpv_rec;
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
    g_cgpv_rec := l_cgpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okc_contract_group_pvt.delete_contract_group(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_rec);
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
  END delete_contract_group;

  PROCEDURE delete_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_tbl                     IN cgpv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgpv_tbl.COUNT > 0 THEN
      i := p_cgpv_tbl.FIRST;
      LOOP
        delete_contract_group(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cgpv_tbl.LAST);
        i := p_cgpv_tbl.NEXT(i);
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
  END delete_contract_group;

  PROCEDURE lock_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type) IS
  BEGIN
    okc_contract_group_pvt.lock_contract_group(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_rec);
  END lock_contract_group;

  PROCEDURE lock_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_tbl                     IN cgpv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgpv_tbl.COUNT > 0 THEN
      i := p_cgpv_tbl.FIRST;
      LOOP
        lock_contract_group(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cgpv_tbl.LAST);
        i := p_cgpv_tbl.NEXT(i);
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
  END lock_contract_group;

  PROCEDURE validate_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_contract_group';
    l_return_status		   VARCHAR2(1);
    l_cgpv_rec                     cgpv_rec_type := p_cgpv_rec;
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
    g_cgpv_rec := l_cgpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okc_contract_group_pvt.validate_contract_group(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_rec);
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
  END validate_contract_group;

  PROCEDURE validate_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_tbl                     IN cgpv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgpv_tbl.COUNT > 0 THEN
      i := p_cgpv_tbl.FIRST;
      LOOP
        validate_contract_group(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cgpv_tbl.LAST);
        i := p_cgpv_tbl.NEXT(i);
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
  END validate_contract_group;

  PROCEDURE create_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type,
    x_cgcv_rec                     OUT NOCOPY cgcv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_contract_grpngs';
    l_return_status		   VARCHAR2(1);
    l_cgcv_rec                     cgcv_rec_type := p_cgcv_rec;
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
    g_cgcv_rec := l_cgcv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_cgcv_rec := migrate_cgcv(l_cgcv_rec, g_cgcv_rec);

    okc_contract_group_pvt.create_contract_grpngs(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    l_cgcv_rec,
	    x_cgcv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_cgcv_rec := x_cgcv_rec;
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
  END create_contract_grpngs;

  PROCEDURE create_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type,
    x_cgcv_tbl                     OUT NOCOPY cgcv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgcv_tbl.COUNT > 0 THEN
      i := p_cgcv_tbl.FIRST;
      LOOP
        create_contract_grpngs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgcv_tbl(i),
	    x_cgcv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cgcv_tbl.LAST);
        i := p_cgcv_tbl.NEXT(i);
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
  END create_contract_grpngs;

  PROCEDURE update_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type,
    x_cgcv_rec                     OUT NOCOPY cgcv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_contract_grpngs';
    l_return_status		   VARCHAR2(1);
    l_cgcv_rec                     cgcv_rec_type := p_cgcv_rec;
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
    g_cgcv_rec := l_cgcv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_cgcv_rec := migrate_cgcv(l_cgcv_rec, g_cgcv_rec);

    okc_contract_group_pvt.update_contract_grpngs(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    l_cgcv_rec,
	    x_cgcv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call user hook for AFTER
    g_cgcv_rec := x_cgcv_rec;
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
  END update_contract_grpngs;

  PROCEDURE update_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type,
    x_cgcv_tbl                     OUT NOCOPY cgcv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgcv_tbl.COUNT > 0 THEN
      i := p_cgcv_tbl.FIRST;
      LOOP
        update_contract_grpngs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgcv_tbl(i),
	    x_cgcv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cgcv_tbl.LAST);
        i := p_cgcv_tbl.NEXT(i);
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
  END update_contract_grpngs;

  PROCEDURE delete_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_contract_grpngs';
    l_return_status		   VARCHAR2(1);
    l_cgcv_rec                     cgcv_rec_type := p_cgcv_rec;
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
    g_cgcv_rec := l_cgcv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okc_contract_group_pvt.delete_contract_grpngs(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    l_cgcv_rec);
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
  END delete_contract_grpngs;

  PROCEDURE delete_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgcv_tbl.COUNT > 0 THEN
      i := p_cgcv_tbl.FIRST;
      LOOP
        delete_contract_grpngs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgcv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cgcv_tbl.LAST);
        i := p_cgcv_tbl.NEXT(i);
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
  END delete_contract_grpngs;

  PROCEDURE lock_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type) IS
  BEGIN
    okc_contract_group_pvt.lock_contract_grpngs(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgcv_rec);
  END lock_contract_grpngs;

  PROCEDURE lock_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgcv_tbl.COUNT > 0 THEN
      i := p_cgcv_tbl.FIRST;
      LOOP
        lock_contract_grpngs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgcv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cgcv_tbl.LAST);
        i := p_cgcv_tbl.NEXT(i);
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
  END lock_contract_grpngs;

  PROCEDURE validate_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_contract_grpngs';
    l_return_status		   VARCHAR2(1);
    l_cgcv_rec                     cgcv_rec_type := p_cgcv_rec;
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
    g_cgcv_rec := l_cgcv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okc_contract_group_pvt.validate_contract_grpngs(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    l_cgcv_rec);
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
  END validate_contract_grpngs;

  PROCEDURE validate_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgcv_tbl.COUNT > 0 THEN
      i := p_cgcv_tbl.FIRST;
      LOOP
        validate_contract_grpngs(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgcv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cgcv_tbl.LAST);
        i := p_cgcv_tbl.NEXT(i);
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
  END validate_contract_grpngs;

  PROCEDURE Validate_Name(x_return_status OUT NOCOPY VARCHAR2,
                          p_cgpv_rec IN cgpv_rec_type) IS
  BEGIN
    okc_contract_group_pvt.Validate_name(x_return_status, p_cgpv_rec);
  END Validate_Name;

  PROCEDURE Validate_Name(x_return_status OUT NOCOPY VARCHAR2,
                          p_cgpv_tbl IN cgpv_tbl_type) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(OKC_API.G_TRUE);
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgpv_tbl.COUNT > 0 THEN
      i := p_cgpv_tbl.FIRST;
      LOOP
        Validate_name(l_return_status, p_cgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cgpv_tbl.LAST);
        i := p_cgpv_tbl.NEXT(i);
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
  END Validate_Name;

  PROCEDURE Validate_Public_YN(x_return_status OUT NOCOPY VARCHAR2,
                               p_cgpv_rec IN cgpv_rec_type) IS
  BEGIN
    okc_contract_group_pvt.Validate_Public_YN(x_return_status, p_cgpv_rec);
  END Validate_Public_YN;

  PROCEDURE Validate_Public_YN(x_return_status OUT NOCOPY VARCHAR2,
                               p_cgpv_tbl IN cgpv_tbl_type) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(OKC_API.G_TRUE);
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgpv_tbl.COUNT > 0 THEN
      i := p_cgpv_tbl.FIRST;
      LOOP
        Validate_Public_YN(l_return_status, p_cgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cgpv_tbl.LAST);
        i := p_cgpv_tbl.NEXT(i);
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
  END Validate_Public_YN;

  PROCEDURE Validate_Short_Description(x_return_status OUT NOCOPY VARCHAR2,
                                       p_cgpv_rec IN cgpv_rec_type) IS
  BEGIN
    okc_contract_group_pvt.Validate_Short_Description(x_return_status, p_cgpv_rec);
  END Validate_Short_Description;

  PROCEDURE Validate_Short_Description(x_return_status OUT NOCOPY VARCHAR2,
                                       p_cgpv_tbl IN cgpv_tbl_type) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(OKC_API.G_FALSE);
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgpv_tbl.COUNT > 0 THEN
      i := p_cgpv_tbl.FIRST;
      LOOP
        Validate_Short_Description(l_return_status, p_cgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cgpv_tbl.LAST);
        i := p_cgpv_tbl.NEXT(i);
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
  END Validate_Short_Description;

  FUNCTION Validate_Record(p_cgpv_rec IN cgpv_rec_type)
    RETURN VARCHAR2 IS
  BEGIN
    Return(okc_contract_group_pvt.Validate_Record(p_cgpv_rec));
  END;

  FUNCTION Validate_Record(p_cgpv_tbl IN cgpv_tbl_type)
    RETURN VARCHAR2 IS
    x_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(OKC_API.G_TRUE);
    IF p_cgpv_tbl.COUNT > 0 THEN
      i := p_cgpv_tbl.FIRST;
      LOOP
        l_return_status := Validate_Record(p_cgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_cgpv_tbl.LAST);
        i := p_cgpv_tbl.NEXT(i);
      END LOOP;
    END IF;
    Return(x_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      Return(x_return_status);
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      Return(x_return_status);
  END Validate_Record;

  PROCEDURE Set_Search_String(
	 p_srch_str      IN         VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    okc_cgc_pvt.Set_Search_String(p_srch_str, x_return_status);
  END;

  PROCEDURE Get_Queried_Contracts(
	 p_cgp_parent_id IN  NUMBER,
	 x_qry_k_tbl     OUT NOCOPY qry_k_tbl,
      x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    okc_cgc_pvt.Get_Queried_Contracts(p_cgp_parent_id, x_qry_k_tbl, x_return_status);
  END;

END OKC_CONTRACT_GROUP_PUB;

/
