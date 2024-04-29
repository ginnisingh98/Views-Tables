--------------------------------------------------------
--  DDL for Package Body OKC_ACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ACTIONS_PUB" AS
/* $Header: OKCPACNB.pls 120.0 2005/05/25 22:53:47 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/***********************  HAND-CODED  ***************************************/

  FUNCTION migrate_acnv(p_acnv_rec1 IN acnv_rec_type,
                        p_acnv_rec2 IN acnv_rec_type)
    RETURN acnv_rec_type IS
    l_acnv_rec acnv_rec_type;
  BEGIN
    l_acnv_rec.id                    := p_acnv_rec1.id;
    l_acnv_rec.correlation           := p_acnv_rec1.correlation;
    l_acnv_rec.object_version_number := p_acnv_rec1.object_version_number;
    l_acnv_rec.created_by            := p_acnv_rec1.created_by;
    l_acnv_rec.creation_date         := p_acnv_rec1.creation_date;
    l_acnv_rec.last_updated_by       := p_acnv_rec1.last_updated_by;
    l_acnv_rec.last_update_date      := p_acnv_rec1.last_update_date;
    l_acnv_rec.last_update_login     := p_acnv_rec1.last_update_login;
    l_acnv_rec.sfwt_flag             := p_acnv_rec2.sfwt_flag;
    l_acnv_rec.seeded_flag           := p_acnv_rec2.seeded_flag;
    l_acnv_rec.application_id        := p_acnv_rec2.application_id;
    l_acnv_rec.name                  := p_acnv_rec2.name;
    l_acnv_rec.description           := p_acnv_rec2.description;
    l_acnv_rec.short_description     := p_acnv_rec2.short_description;
    l_acnv_rec.comments              := p_acnv_rec2.comments;
    l_acnv_rec.enabled_yn            := p_acnv_rec2.enabled_yn;
    l_acnv_rec.factory_enabled_yn    := p_acnv_rec2.factory_enabled_yn;
    l_acnv_rec.counter_action_yn     := p_acnv_rec2.counter_action_yn;
    l_acnv_rec.sync_allowed_yn       := p_acnv_rec2.sync_allowed_yn;
    l_acnv_rec.acn_type              := p_acnv_rec2.acn_type;
    l_acnv_rec.attribute_category    := p_acnv_rec2.attribute_category;
    l_acnv_rec.attribute1            := p_acnv_rec2.attribute1;
    l_acnv_rec.attribute2            := p_acnv_rec2.attribute2;
    l_acnv_rec.attribute3            := p_acnv_rec2.attribute3;
    l_acnv_rec.attribute4            := p_acnv_rec2.attribute4;
    l_acnv_rec.attribute5            := p_acnv_rec2.attribute5;
    l_acnv_rec.attribute6            := p_acnv_rec2.attribute6;
    l_acnv_rec.attribute7            := p_acnv_rec2.attribute7;
    l_acnv_rec.attribute8            := p_acnv_rec2.attribute8;
    l_acnv_rec.attribute9            := p_acnv_rec2.attribute9;
    l_acnv_rec.attribute10           := p_acnv_rec2.attribute10;
    l_acnv_rec.attribute11           := p_acnv_rec2.attribute11;
    l_acnv_rec.attribute12           := p_acnv_rec2.attribute12;
    l_acnv_rec.attribute13           := p_acnv_rec2.attribute13;
    l_acnv_rec.attribute14           := p_acnv_rec2.attribute14;
    l_acnv_rec.attribute15           := p_acnv_rec2.attribute15;
    RETURN (l_acnv_rec);
  END migrate_acnv;

  FUNCTION migrate_aaev(p_aaev_rec1 IN aaev_rec_type,
                        p_aaev_rec2 IN aaev_rec_type)
    RETURN aaev_rec_type IS
    l_aaev_rec aaev_rec_type;
  BEGIN
    l_aaev_rec.id                    := p_aaev_rec1.id;
    l_aaev_rec.aal_id                := p_aaev_rec1.aal_id;
    l_aaev_rec.object_version_number := p_aaev_rec1.object_version_number;
    l_aaev_rec.created_by            := p_aaev_rec1.created_by;
    l_aaev_rec.creation_date         := p_aaev_rec1.creation_date;
    l_aaev_rec.last_updated_by       := p_aaev_rec1.last_updated_by;
    l_aaev_rec.last_update_date      := p_aaev_rec1.last_update_date;
    l_aaev_rec.last_update_login     := p_aaev_rec1.last_update_login;
    l_aaev_rec.sfwt_flag             := p_aaev_rec2.sfwt_flag;
    l_aaev_rec.seeded_flag           := p_aaev_rec2.seeded_flag;
    l_aaev_rec.application_id        := p_aaev_rec2.application_id;
    l_aaev_rec.acn_id                := p_aaev_rec2.acn_id;
    l_aaev_rec.element_name          := p_aaev_rec2.element_name;
    l_aaev_rec.name                  := p_aaev_rec2.name;
    l_aaev_rec.description           := p_aaev_rec2.description;
    l_aaev_rec.data_type             := p_aaev_rec2.data_type;
    l_aaev_rec.list_yn               := p_aaev_rec2.list_yn;
    l_aaev_rec.visible_yn            := p_aaev_rec2.visible_yn;
    l_aaev_rec.date_of_interest_yn   := p_aaev_rec2.date_of_interest_yn;
    l_aaev_rec.format_mask           := p_aaev_rec2.format_mask;
    l_aaev_rec.minimum_value         := p_aaev_rec2.minimum_value;
    l_aaev_rec.maximum_value         := p_aaev_rec2.maximum_value;
    l_aaev_rec.jtot_object_code      := p_aaev_rec2.jtot_object_code;
    l_aaev_rec.NAME_COLUMN           := p_aaev_rec2.NAME_COLUMN;
    l_aaev_rec.description_column    := p_aaev_rec2.description_column;
    l_aaev_rec.source_doc_number_yn  := p_aaev_rec2.source_doc_number_yn;
    l_aaev_rec.attribute_category    := p_aaev_rec2.attribute_category;
    l_aaev_rec.attribute1            := p_aaev_rec2.attribute1;
    l_aaev_rec.attribute2            := p_aaev_rec2.attribute2;
    l_aaev_rec.attribute3            := p_aaev_rec2.attribute3;
    l_aaev_rec.attribute4            := p_aaev_rec2.attribute4;
    l_aaev_rec.attribute5            := p_aaev_rec2.attribute5;
    l_aaev_rec.attribute6            := p_aaev_rec2.attribute6;
    l_aaev_rec.attribute7            := p_aaev_rec2.attribute7;
    l_aaev_rec.attribute8            := p_aaev_rec2.attribute8;
    l_aaev_rec.attribute9            := p_aaev_rec2.attribute9;
    l_aaev_rec.attribute10           := p_aaev_rec2.attribute10;
    l_aaev_rec.attribute11           := p_aaev_rec2.attribute11;
    l_aaev_rec.attribute12           := p_aaev_rec2.attribute12;
    l_aaev_rec.attribute13           := p_aaev_rec2.attribute13;
    l_aaev_rec.attribute14           := p_aaev_rec2.attribute14;
    l_aaev_rec.attribute15           := p_aaev_rec2.attribute15;
    RETURN (l_aaev_rec);
  END migrate_aaev;

  PROCEDURE add_language IS
  BEGIN
    okc_actions_pvt.add_language;
  END;

  -- Object type procedure for Insert
  PROCEDURE create_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    p_aaev_tbl                     IN aaev_tbl_type,
    x_acnv_rec                     OUT NOCOPY acnv_rec_type,
    x_aaev_tbl                     OUT NOCOPY aaev_tbl_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'create_actions';
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       -- call to complex API
       okc_actions_pvt.create_actions(p_api_version
                                     ,p_init_msg_list
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data
                                     ,p_acnv_rec
                                     ,p_aaev_tbl
                                     ,x_acnv_rec
                                     ,x_aaev_tbl);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);
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
    END create_actions;

  PROCEDURE create_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type,
    p_aaev_tbl                     IN aaev_tbl_type,
    x_acnv_tbl                     OUT NOCOPY acnv_tbl_type,
    x_aaev_tbl                     OUT NOCOPY aaev_tbl_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'create_actions';
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       -- call to complex API
       okc_actions_pvt.create_actions(p_api_version
                                     ,p_init_msg_list
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data
                                     ,p_acnv_tbl
                                     ,p_aaev_tbl
                                     ,x_acnv_tbl
                                     ,x_aaev_tbl);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);
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
    END create_actions;

  -- Object type procedure for update
  PROCEDURE update_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    p_aaev_tbl                     IN aaev_tbl_type,
    x_acnv_rec                     OUT NOCOPY acnv_rec_type,
    x_aaev_tbl                     OUT NOCOPY aaev_tbl_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'update_actions';
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       -- call to complex API
       okc_actions_pvt.update_actions(p_api_version
                                     ,p_init_msg_list
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data
                                     ,p_acnv_rec
                                     ,p_aaev_tbl
                                     ,x_acnv_rec
                                     ,x_aaev_tbl);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);
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
    END update_actions;

  -- Object type procedure for validate
  PROCEDURE validate_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    p_aaev_tbl                     IN aaev_tbl_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'validate_actions';
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       -- call to complex API
       okc_actions_pvt.validate_actions(p_api_version
                                       ,p_init_msg_list
                                       ,x_return_status
                                       ,x_msg_count
                                       ,x_msg_data
                                       ,p_acnv_rec
                                       ,p_aaev_tbl);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);
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
    END validate_actions;

  -- Procedues for Actions
  PROCEDURE create_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type,
    x_acnv_tbl                     OUT NOCOPY acnv_tbl_type) IS

    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_acnv_tbl.COUNT > 0 THEN
          i := p_acnv_tbl.FIRST;
          LOOP
            create_actions(
                           p_api_version
                          ,p_init_msg_list
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,p_acnv_tbl(i)
                          ,x_acnv_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_acnv_tbl.LAST);
           i := p_acnv_tbl.NEXT(i);
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
    END create_actions;

  PROCEDURE create_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    x_acnv_rec                     OUT NOCOPY acnv_rec_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'create_actions';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_rec            acnv_rec_type := p_acnv_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- Call user hook for BEFORE
     g_acnv_rec := l_acnv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- get values back from hook call
     l_acnv_rec := migrate_acnv(l_acnv_rec, g_acnv_rec);

       -- call to complex API procedure
       okc_actions_pvt.create_actions(p_api_version
                                     ,p_init_msg_list
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data
                                     ,l_acnv_rec
                                     ,x_acnv_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- USER HOOK CALL FOR AFTER, STARTS
  	g_acnv_rec := x_acnv_rec;

      	okc_util.call_user_hook(x_return_status  => x_return_status,
       				p_package_name   => g_pkg_name,
       				p_procedure_name => l_api_name,
       				p_before_after   => 'A');

      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_ERROR;
      	END IF;
     -- USER HOOK CALL FOR AFTER, ENDS

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

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
    END create_actions;


  PROCEDURE lock_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type) IS

    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_acnv_tbl.COUNT > 0 THEN
          i := p_acnv_tbl.FIRST;
          LOOP
            lock_actions(
                         p_api_version
                        ,p_init_msg_list
                        ,l_return_status
                        ,x_msg_count
                        ,x_msg_data
                        ,p_acnv_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_acnv_tbl.LAST);
           i := p_acnv_tbl.NEXT(i);
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
    END lock_actions;

  PROCEDURE lock_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'lock_actions';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_rec            acnv_rec_type := p_acnv_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       -- call to complex API procedure
       okc_actions_pvt.lock_actions(p_api_version
                                     ,p_init_msg_list
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data
                                     ,p_acnv_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

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
    END lock_actions;

  PROCEDURE update_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type,
    x_acnv_tbl                     OUT NOCOPY acnv_tbl_type) IS

    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_acnv_tbl.COUNT > 0 THEN
          i := p_acnv_tbl.FIRST;
          LOOP
            update_actions(
                         p_api_version
                        ,p_init_msg_list
                        ,l_return_status
                        ,x_msg_count
                        ,x_msg_data
                        ,p_acnv_tbl(i)
                        ,x_acnv_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_acnv_tbl.LAST);
           i := p_acnv_tbl.NEXT(i);
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
    END update_actions;

  PROCEDURE update_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    x_acnv_rec                     OUT NOCOPY acnv_rec_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'update_actions';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_rec            acnv_rec_type := p_acnv_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- Call user hook for BEFORE
     g_acnv_rec := l_acnv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- get values back from hook call
     l_acnv_rec := migrate_acnv(l_acnv_rec, g_acnv_rec);

       -- call to complex API procedure
       okc_actions_pvt.update_actions(p_api_version
                                     ,p_init_msg_list
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data
                                     ,l_acnv_rec
                                     ,x_acnv_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- USER HOOK CALL FOR AFTER, STARTS
  	g_acnv_rec := x_acnv_rec;

      	okc_util.call_user_hook(x_return_status  => x_return_status,
       				p_package_name   => g_pkg_name,
       				p_procedure_name => l_api_name,
       				p_before_after   => 'A');

      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_ERROR;
      	END IF;
     -- USER HOOK CALL FOR AFTER, ENDS

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

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
    END update_actions;

  PROCEDURE delete_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type) IS

    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_acnv_tbl.COUNT > 0 THEN
          i := p_acnv_tbl.FIRST;
          LOOP
            delete_actions(
                           p_api_version
                          ,p_init_msg_list
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,p_acnv_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_acnv_tbl.LAST);
           i := p_acnv_tbl.NEXT(i);
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
    END delete_actions;

  PROCEDURE delete_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'delete_actions';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_rec            acnv_rec_type := p_acnv_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- Call user hook for BEFORE
     g_acnv_rec := l_acnv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- get values back from hook call
     l_acnv_rec := migrate_acnv(l_acnv_rec, g_acnv_rec);

       -- call to complex API procedure
       okc_actions_pvt.delete_actions(p_api_version
                                     ,p_init_msg_list
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data
                                     ,l_acnv_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- USER HOOK CALL FOR AFTER, STARTS
  	g_acnv_rec := l_acnv_rec;

      	okc_util.call_user_hook(x_return_status  => x_return_status,
       				p_package_name   => g_pkg_name,
       				p_procedure_name => l_api_name,
       				p_before_after   => 'A');

      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_ERROR;
      	END IF;
     -- USER HOOK CALL FOR AFTER, ENDS

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

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
    END delete_actions;

  PROCEDURE validate_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type) IS

    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_acnv_tbl.COUNT > 0 THEN
          i := p_acnv_tbl.FIRST;
          LOOP
            validate_actions(
                             p_api_version
                            ,p_init_msg_list
                            ,l_return_status
                            ,x_msg_count
                            ,x_msg_data
                            ,p_acnv_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_acnv_tbl.LAST);
           i := p_acnv_tbl.NEXT(i);
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
    END validate_actions;

  PROCEDURE validate_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'validate_actions';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_rec            acnv_rec_type := p_acnv_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- Call user hook for BEFORE
     g_acnv_rec := l_acnv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- get values back from hook call
     l_acnv_rec := migrate_acnv(l_acnv_rec, g_acnv_rec);

       -- call to complex API procedure
       okc_actions_pvt.validate_actions(p_api_version
                                       ,p_init_msg_list
                                       ,x_return_status
                                       ,x_msg_count
                                       ,x_msg_data
                                       ,l_acnv_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- USER HOOK CALL FOR AFTER, STARTS
  	g_acnv_rec := l_acnv_rec;

      	okc_util.call_user_hook(x_return_status  => x_return_status,
       				p_package_name   => g_pkg_name,
       				p_procedure_name => l_api_name,
       				p_before_after   => 'A');

      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_ERROR;
      	END IF;
     -- USER HOOK CALL FOR AFTER, ENDS

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

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
    END validate_actions;

  -- Procedures for Action Attributes
  PROCEDURE create_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type,
    x_aaev_tbl                     OUT NOCOPY aaev_tbl_type) IS
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_aaev_tbl.COUNT > 0 THEN
          i := p_aaev_tbl.FIRST;
          LOOP
            create_act_atts(
                            p_api_version
                           ,p_init_msg_list
                           ,l_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,p_aaev_tbl(i)
                           ,x_aaev_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_aaev_tbl.LAST);
           i := p_aaev_tbl.NEXT(i);
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
    END create_act_atts;


  PROCEDURE create_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type,
    x_aaev_rec                     OUT NOCOPY aaev_rec_type) IS
    l_api_name            CONSTANT VARCHAR2(30) := 'create_act_atts';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aaev_rec            aaev_rec_type := p_aaev_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- Call user hook for BEFORE
     g_aaev_rec := l_aaev_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- get values back from hook call
     l_aaev_rec := migrate_aaev(l_aaev_rec, g_aaev_rec);

       -- call to complex API procedure
       okc_actions_pvt.create_act_atts(p_api_version
                                      ,p_init_msg_list
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data
                                      ,l_aaev_rec
                                      ,x_aaev_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- USER HOOK CALL FOR AFTER, STARTS
  	g_aaev_rec := x_aaev_rec;

      	okc_util.call_user_hook(x_return_status  => x_return_status,
       				p_package_name   => g_pkg_name,
       				p_procedure_name => l_api_name,
       				p_before_after   => 'A');

      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_ERROR;
      	END IF;
     -- USER HOOK CALL FOR AFTER, ENDS

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

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
    END create_act_atts;

  PROCEDURE lock_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type) IS

    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_aaev_tbl.COUNT > 0 THEN
          i := p_aaev_tbl.FIRST;
          LOOP
            lock_act_atts(
                         p_api_version
                        ,p_init_msg_list
                        ,l_return_status
                        ,x_msg_count
                        ,x_msg_data
                        ,p_aaev_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_aaev_tbl.LAST);
           i := p_aaev_tbl.NEXT(i);
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
    END lock_act_atts;

  PROCEDURE lock_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'lock_act_atts';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aaev_rec            aaev_rec_type := p_aaev_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       -- call to complex API procedure
       okc_actions_pvt.lock_act_atts(p_api_version
                                    ,p_init_msg_list
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data
                                    ,p_aaev_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

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
    END lock_act_atts;


  PROCEDURE update_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type,
    x_aaev_tbl                     OUT NOCOPY aaev_tbl_type) IS
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_aaev_tbl.COUNT > 0 THEN
          i := p_aaev_tbl.FIRST;
          LOOP
            update_act_atts(
                            p_api_version
                           ,p_init_msg_list
                           ,l_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,p_aaev_tbl(i)
                           ,x_aaev_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_aaev_tbl.LAST);
           i := p_aaev_tbl.NEXT(i);
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
    END update_act_atts;

  PROCEDURE update_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type,
    x_aaev_rec                     OUT NOCOPY aaev_rec_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'update_act_atts';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aaev_rec            aaev_rec_type := p_aaev_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- Call user hook for BEFORE
     g_aaev_rec := l_aaev_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- get values back from hook call
     l_aaev_rec := migrate_aaev(l_aaev_rec, g_aaev_rec);

       -- call to complex API procedure
       okc_actions_pvt.update_act_atts(p_api_version
                                      ,p_init_msg_list
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data
                                      ,l_aaev_rec
                                      ,x_aaev_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- USER HOOK CALL FOR AFTER, STARTS
  	g_aaev_rec := x_aaev_rec;

      	okc_util.call_user_hook(x_return_status  => x_return_status,
       				p_package_name   => g_pkg_name,
       				p_procedure_name => l_api_name,
       				p_before_after   => 'A');

      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_ERROR;
      	END IF;
     -- USER HOOK CALL FOR AFTER, ENDS

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

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
    END update_act_atts;

  PROCEDURE delete_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type) IS

    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_aaev_tbl.COUNT > 0 THEN
          i := p_aaev_tbl.FIRST;
          LOOP
            delete_act_atts(
                            p_api_version
                           ,p_init_msg_list
                           ,l_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,p_aaev_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_aaev_tbl.LAST);
           i := p_aaev_tbl.NEXT(i);
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
    END delete_act_atts;

  PROCEDURE delete_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'delete_act_atts';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aaev_rec            aaev_rec_type := p_aaev_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- Call user hook for BEFORE
     g_aaev_rec := l_aaev_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- get values back from hook call
     l_aaev_rec := migrate_aaev(l_aaev_rec, g_aaev_rec);

       -- call to complex API procedure
       okc_actions_pvt.delete_act_atts(p_api_version
                                      ,p_init_msg_list
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data
                                      ,l_aaev_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- USER HOOK CALL FOR AFTER, STARTS
  	g_aaev_rec := l_aaev_rec;

      	okc_util.call_user_hook(x_return_status  => x_return_status,
       				p_package_name   => g_pkg_name,
       				p_procedure_name => l_api_name,
       				p_before_after   => 'A');

      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_ERROR;
      	END IF;
     -- USER HOOK CALL FOR AFTER, ENDS

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

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
    END delete_act_atts;

  PROCEDURE validate_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type) IS

    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_aaev_tbl.COUNT > 0 THEN
          i := p_aaev_tbl.FIRST;
          LOOP
            validate_act_atts(
                              p_api_version
                             ,p_init_msg_list
                             ,l_return_status
                             ,x_msg_count
                             ,x_msg_data
                             ,p_aaev_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_aaev_tbl.LAST);
           i := p_aaev_tbl.NEXT(i);
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
    END validate_act_atts;

  PROCEDURE validate_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'validate_act_atts';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aaev_rec            aaev_rec_type := p_aaev_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- Call user hook for BEFORE
     g_aaev_rec := l_aaev_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- get values back from hook call
     l_aaev_rec := migrate_aaev(l_aaev_rec, g_aaev_rec);

       -- call to complex API procedure
       okc_actions_pvt.validate_act_atts(p_api_version
                                        ,p_init_msg_list
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data
                                        ,l_aaev_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- USER HOOK CALL FOR AFTER, STARTS
  	g_aaev_rec := l_aaev_rec;

      	okc_util.call_user_hook(x_return_status  => x_return_status,
       				p_package_name   => g_pkg_name,
       				p_procedure_name => l_api_name,
       				p_before_after   => 'A');

      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_ERROR;
      	END IF;
     -- USER HOOK CALL FOR AFTER, ENDS

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

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
    END validate_act_atts;

END OKC_ACTIONS_PUB;

/
