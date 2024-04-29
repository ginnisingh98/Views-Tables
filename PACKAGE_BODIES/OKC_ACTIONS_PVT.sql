--------------------------------------------------------
--  DDL for Package Body OKC_ACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ACTIONS_PVT" AS
/* $Header: OKCCACNB.pls 120.0 2005/05/25 22:57:10 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/***********************  HAND-CODED  ***************************************/

  PROCEDURE ADD_LANGUAGE IS
  BEGIN
   okc_acn_pvt.add_language;
   okc_aae_pvt.add_language;
  END;

  -- Object type procedure for create
  PROCEDURE CREATE_ACTIONS(
    p_api_version      	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acnv_rec	            IN acnv_rec_type,
    p_aaev_tbl	            IN aaev_tbl_type,
    x_acnv_rec              OUT NOCOPY acnv_rec_type,
    x_aaev_tbl              OUT NOCOPY aaev_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_rec              acnv_rec_type;
    l_aaev_tbl              aaev_tbl_type := p_aaev_tbl;
    i                       NUMBER;
  BEGIN

    -- populate the master
    create_actions(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_acnv_rec,
    x_acnv_rec);

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- populate the foreign key for the detail
    IF (l_aaev_tbl.COUNT > 0) THEN
       i:= l_aaev_tbl.FIRST;
       LOOP
        l_aaev_tbl(i).acn_id := x_acnv_rec.id;
        EXIT WHEN(i = l_aaev_tbl.LAST);
        i := l_aaev_tbl.NEXT(i);
       END LOOP;
    END IF;

    -- populate the detail
    create_act_atts(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aaev_tbl,
    x_aaev_tbl);

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
       END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

    WHEN OTHERS THEN
    OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                       ,p_msg_name          => g_unexpected_error
                       ,p_token1            => g_sqlcode_token
                       ,p_token1_value      => sqlcode
                       ,p_token2            => g_sqlerrm_token
                       ,p_token2_value      => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END CREATE_ACTIONS;

  PROCEDURE CREATE_ACTIONS(
    p_api_version      	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acnv_tbl	            IN acnv_tbl_type,
    p_aaev_tbl	            IN aaev_tbl_type,
    x_acnv_tbl              OUT NOCOPY acnv_tbl_type,
    x_aaev_tbl              OUT NOCOPY aaev_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acnv_tbl              acnv_tbl_type;
    l_aaev_tbl              aaev_tbl_type := p_aaev_tbl;
    i                       NUMBER;
  BEGIN

    -- populate the master
    create_actions(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_acnv_tbl,
    x_acnv_tbl);

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- populate the foreign key for the detail
    IF (l_aaev_tbl.COUNT > 0) THEN
       i:= l_aaev_tbl.FIRST;
       LOOP
        l_aaev_tbl(i).acn_id := x_acnv_tbl(i).id;
        EXIT WHEN(i = l_aaev_tbl.LAST);
        i := l_aaev_tbl.NEXT(i);
       END LOOP;
    END IF;

    -- populate the detail
    create_act_atts(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aaev_tbl,
    x_aaev_tbl);

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
       END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

    WHEN OTHERS THEN
    OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                       ,p_msg_name          => g_unexpected_error
                       ,p_token1            => g_sqlcode_token
                       ,p_token1_value      => sqlcode
                       ,p_token2            => g_sqlerrm_token
                       ,p_token2_value      => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END CREATE_ACTIONS;

  -- Object type procedure for update
  PROCEDURE UPDATE_ACTIONS(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acnv_rec	            IN acnv_rec_type,
    p_aaev_tbl	            IN aaev_tbl_type,
    x_acnv_rec              OUT NOCOPY acnv_rec_type,
    x_aaev_tbl              OUT NOCOPY aaev_tbl_type) IS

    --l_api_vsersion          CONSTANT NUMBER := 1;
    --l_api_name              CONSTANT VARCHAR2(30) := 'V_update_pub_event';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Update the master
    update_actions(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_acnv_rec,
    x_acnv_rec);

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Update the detail
    update_act_atts(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aaev_tbl,
    x_aaev_tbl);

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
       END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

    WHEN OTHERS THEN
    OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                       ,p_msg_name          => g_unexpected_error
                       ,p_token1            => g_sqlcode_token
                       ,p_token1_value      => sqlcode
                       ,p_token2            => g_sqlerrm_token
                       ,p_token2_value      => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END UPDATE_ACTIONS;

  -- Object type procedure for validate
  PROCEDURE VALIDATE_ACTIONS(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acnv_rec	            IN acnv_rec_type,
    p_aaev_tbl	            IN aaev_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate the master
    validate_actions(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_acnv_rec);

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate the detail
    validate_act_atts(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aaev_tbl);

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
       END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

    WHEN OTHERS THEN
    OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                       ,p_msg_name          => g_unexpected_error
                       ,p_token1            => g_sqlcode_token
                       ,p_token1_value      => sqlcode
                       ,p_token2            => g_sqlerrm_token
                       ,p_token2_value      => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END VALIDATE_ACTIONS;

  -- Procedures for Actions
  PROCEDURE CREATE_ACTIONS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acnv_rec		    IN acnv_rec_type,
    x_acnv_rec              OUT NOCOPY acnv_rec_type) IS

  BEGIN
    okc_acn_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_acnv_rec,
    x_acnv_rec);

  END CREATE_ACTIONS;

  PROCEDURE CREATE_ACTIONS(
    p_api_version		   IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acnv_tbl		    IN acnv_tbl_type,
    x_acnv_tbl              OUT NOCOPY acnv_tbl_type) IS

  BEGIN

    okc_acn_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_acnv_tbl,
    x_acnv_tbl);

  END CREATE_ACTIONS;

  PROCEDURE LOCK_ACTIONS(
    p_api_version		   IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acnv_rec		    IN acnv_rec_type) IS

  BEGIN
    okc_acn_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_acnv_rec);

  END LOCK_ACTIONS;

  PROCEDURE LOCK_ACTIONS(
    p_api_version		   IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acnv_tbl		    IN acnv_tbl_type) IS

  BEGIN
    okc_acn_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_acnv_tbl);

  END LOCK_ACTIONS;

  PROCEDURE UPDATE_ACTIONS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acnv_rec		    IN acnv_rec_type,
    x_acnv_rec              OUT NOCOPY acnv_rec_type) IS
    l_aaev_tbl              OKC_ACTIONS_PUB.aaev_tbl_type;
    v_aaev_tbl              OKC_ACTIONS_PUB.aaev_tbl_type;
    l_api_version      NUMBER := 1;
    l_init_msg_list    VARCHAR2(1) := 'T';
    l_return_status    varchar2(1):= OKC_API.G_RET_STS_SUCCESS;
    l_msg_count        number;
    l_msg_data         varchar2(200);
    l_app_id1          NUMBER;
    l_cnt              NUMBER := 0;
   CURSOR l_id_cur is
   SELECT *
   FROM okc_action_attributes_V
   WHERE acn_id = p_acnv_rec.id;
  BEGIN

    SELECT application_id INTO l_app_id1
    FROM OKC_ACTIONS_B
    WHERE id = p_acnv_rec.id;

    okc_acn_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_acnv_rec,
    x_acnv_rec);
IF x_return_status = 'S' THEN

    IF nvl(p_acnv_rec.application_id,-99) <> nvl(l_app_id1,-99) THEN
       l_aaev_tbl.delete;
       v_aaev_tbl.delete;
       FOR l_aaev_rec in l_id_cur
       LOOP
        l_cnt := l_cnt + 1;
        l_aaev_tbl(l_cnt).id := l_aaev_rec.id;
        l_aaev_tbl(l_cnt).application_id := p_acnv_rec.application_id;
        l_aaev_tbl(l_cnt).object_Version_number := l_aaev_rec.object_Version_number;
        l_aaev_tbl(l_cnt).aal_id := l_aaev_rec.aal_id;
        l_aaev_tbl(l_cnt).ACN_ID := l_aaev_rec.ACN_ID;
        l_aaev_tbl(l_cnt).ELEMENT_NAME := l_aaev_rec.ELEMENT_NAME;
        l_aaev_tbl(l_cnt).NAME := l_aaev_rec.NAME;
        l_aaev_tbl(l_cnt).SFWT_FLAG := l_aaev_rec.SFWT_FLAG;
        l_aaev_tbl(l_cnt).DESCRIPTION := l_aaev_rec.DESCRIPTION;
        l_aaev_tbl(l_cnt).DATA_TYPE := l_aaev_rec.DATA_TYPE;
        l_aaev_tbl(l_cnt).LIST_YN := l_aaev_rec.LIST_YN;
        l_aaev_tbl(l_cnt).VISIBLE_YN := l_aaev_rec.VISIBLE_YN;
        l_aaev_tbl(l_cnt).DATE_OF_INTEREST_YN := l_aaev_rec.DATE_OF_INTEREST_YN;
        l_aaev_tbl(l_cnt).FORMAT_MASK := l_aaev_rec.FORMAT_MASK;
        l_aaev_tbl(l_cnt).MINIMUM_VALUE := l_aaev_rec.MINIMUM_VALUE;
        l_aaev_tbl(l_cnt).MAXIMUM_VALUE := l_aaev_rec.MAXIMUM_VALUE;
        l_aaev_tbl(l_cnt).SEEDED_FLAG := l_aaev_rec.SEEDED_FLAG;
        l_aaev_tbl(l_cnt).ATTRIBUTE_CATEGORY := l_aaev_rec.ATTRIBUTE_CATEGORY;
        l_aaev_tbl(l_cnt).ATTRIBUTE1 := l_aaev_rec.ATTRIBUTE1;
        l_aaev_tbl(l_cnt).ATTRIBUTE2 := l_aaev_rec.ATTRIBUTE2;
        l_aaev_tbl(l_cnt).ATTRIBUTE3 := l_aaev_rec.ATTRIBUTE3;
        l_aaev_tbl(l_cnt).ATTRIBUTE4 := l_aaev_rec.ATTRIBUTE4;
        l_aaev_tbl(l_cnt).ATTRIBUTE5 := l_aaev_rec.ATTRIBUTE5;
        l_aaev_tbl(l_cnt).ATTRIBUTE6 := l_aaev_rec.ATTRIBUTE6;
        l_aaev_tbl(l_cnt).ATTRIBUTE7 := l_aaev_rec.ATTRIBUTE7;
        l_aaev_tbl(l_cnt).ATTRIBUTE8 := l_aaev_rec.ATTRIBUTE8;
        l_aaev_tbl(l_cnt).ATTRIBUTE9 := l_aaev_rec.ATTRIBUTE9;
        l_aaev_tbl(l_cnt).ATTRIBUTE10 := l_aaev_rec.ATTRIBUTE10;
        l_aaev_tbl(l_cnt).ATTRIBUTE11 := l_aaev_rec.ATTRIBUTE11;
        l_aaev_tbl(l_cnt).ATTRIBUTE12 := l_aaev_rec.ATTRIBUTE12;
        l_aaev_tbl(l_cnt).ATTRIBUTE13 := l_aaev_rec.ATTRIBUTE13;
        l_aaev_tbl(l_cnt).ATTRIBUTE14 := l_aaev_rec.ATTRIBUTE14;
        l_aaev_tbl(l_cnt).ATTRIBUTE15 := l_aaev_rec.ATTRIBUTE15;
        l_aaev_tbl(l_cnt).JTOT_OBJECT_CODE := l_aaev_rec.JTOT_OBJECT_CODE;
        l_aaev_tbl(l_cnt).NAME_COLUMN := l_aaev_rec.NAME_COLUMN;
        l_aaev_tbl(l_cnt).DESCRIPTION_COLUMN := l_aaev_rec.DESCRIPTION_COLUMN;
        l_aaev_tbl(l_cnt).SOURCE_DOC_NUMBER_YN := l_aaev_rec.SOURCE_DOC_NUMBER_YN;
        l_aaev_tbl(l_cnt).LAST_UPDATED_BY := l_aaev_rec.LAST_UPDATED_BY;
        l_aaev_tbl(l_cnt).CREATED_BY := l_aaev_rec.CREATED_BY;
        l_aaev_tbl(l_cnt).CREATION_DATE := l_aaev_rec.CREATION_DATE;
        l_aaev_tbl(l_cnt).LAST_UPDATE_DATE := l_aaev_rec.LAST_UPDATE_DATE;
        l_aaev_tbl(l_cnt).LAST_UPDATE_LOGIN := l_aaev_rec.LAST_UPDATE_LOGIN;

       END LOOP;
      -- CLOSE l_id_cur;
   -- v_aaev_tbl := l_aaev_tbl;
  okc_actions_pub.update_act_atts (
     p_api_version      => l_api_version
    ,p_init_msg_list    => l_init_msg_list
    ,x_return_status    => l_return_status
    ,x_msg_count        => l_msg_count
    ,x_msg_data         => l_msg_data
    ,p_aaev_tbl         => l_aaev_tbl
    ,x_aaev_tbl         => v_aaev_tbl
    );
   END IF;
END IF;

  END UPDATE_ACTIONS;



  PROCEDURE UPDATE_ACTIONS(
    p_api_version		   IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acnv_tbl		    IN acnv_tbl_type,
    x_acnv_tbl              OUT NOCOPY acnv_tbl_type) IS
BEGIN
    okc_acn_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_acnv_tbl,
    x_acnv_tbl);
  END UPDATE_ACTIONS;

  -- Procedure for Cascade Delete
  PROCEDURE DELETE_ACTIONS(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acnv_rec		    IN acnv_rec_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                       NUMBER      := 0;
    l_aaev_tbl              aaev_tbl_type;

    CURSOR aae_csr IS
    SELECT aae.id
    FROM   okc_action_attributes_v aae
    WHERE  aae.acn_id = p_acnv_rec.id;

  BEGIN
      -- populate the foreign key of the detail
      FOR aae_rec IN aae_csr LOOP
          i := i + 1;
          l_aaev_tbl(i).acn_id := aae_rec.id;
      END LOOP;

      -- Delete the details
      -- call delete procedure
	 IF l_aaev_tbl.COUNT > 0 THEN
      okc_actions_pvt.delete_act_atts(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aaev_tbl);

        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
             l_return_status := x_return_status;
          END IF;
        END IF;
      END IF;
    -- Delete the Master
    okc_acn_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_acnv_rec);

        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
             l_return_status := x_return_status;
          END IF;
        END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

    WHEN OTHERS THEN
    OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                       ,p_msg_name         => g_unexpected_error
                       ,p_token1           => g_sqlcode_token
                       ,p_token1_value     => sqlcode
                       ,p_token2           => g_sqlerrm_token
                       ,p_token2_value     => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END DELETE_ACTIONS;

  PROCEDURE DELETE_ACTIONS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acnv_tbl		    IN acnv_tbl_type) IS
    i                       NUMBER := 0;
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_acnv_tbl.COUNT > 0) THEN
        i := p_acnv_tbl.FIRST;
        LOOP
           delete_actions(
                          p_api_version
                         ,p_init_msg_list
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data
                         ,p_acnv_tbl(i));
                             EXIT WHEN (i=p_acnv_tbl.LAST);
           i := p_acnv_tbl.NEXT(i);
         END LOOP;
     END IF;

        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
             l_return_status := x_return_status;
          END IF;
        END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

    WHEN OTHERS THEN
    OKC_API.SET_MESSAGE(p_app_name         => g_app_name
                       ,p_msg_name         => g_unexpected_error
                       ,p_token1           => g_sqlcode_token
                       ,p_token1_value     => sqlcode
                       ,p_token2           => g_sqlerrm_token
                       ,p_token2_value     => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END DELETE_ACTIONS;

  PROCEDURE VALIDATE_ACTIONS(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acnv_rec		    IN acnv_rec_type) IS

  BEGIN

    okc_acn_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_acnv_rec);

  END VALIDATE_ACTIONS;
  PROCEDURE VALIDATE_ACTIONS(
    p_api_version		   IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acnv_tbl		    IN acnv_tbl_type) IS

  BEGIN

    okc_acn_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_acnv_tbl);

  END VALIDATE_ACTIONS;
  -- Procedures for Action Attributes
  PROCEDURE CREATE_ACT_ATTS(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aaev_rec		    IN aaev_rec_type,
    x_aaev_rec              OUT NOCOPY aaev_rec_type) IS
    l_app_id                NUMBER;
    l_aaev_rec		    aaev_rec_type := p_aaev_rec;

  BEGIN
   SELECT application_id into l_app_id
   FROM OKC_ACTIONS_B
   WHERE ID = l_aaev_rec.acn_id;
    l_aaev_rec.application_id := l_app_id;
    okc_aae_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_aaev_rec,
    x_aaev_rec);

  END CREATE_ACT_ATTS;

  PROCEDURE CREATE_ACT_ATTS(
    p_api_version		   IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aaev_tbl		    IN aaev_tbl_type,
    x_aaev_tbl              OUT NOCOPY aaev_tbl_type) IS
  BEGIN
    okc_aae_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aaev_tbl,
    x_aaev_tbl);

  END CREATE_ACT_ATTS;

  PROCEDURE LOCK_ACT_ATTS(
    p_api_version		   IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aaev_rec		    IN aaev_rec_type) IS

  BEGIN
    okc_aae_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aaev_rec);

  END LOCK_ACT_ATTS;

  PROCEDURE LOCK_ACT_ATTS(
    p_api_version		   IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aaev_tbl		    IN aaev_tbl_type) IS

  BEGIN
    okc_aae_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aaev_tbl);

  END LOCK_ACT_ATTS;

  PROCEDURE UPDATE_ACT_ATTS(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aaev_rec		    IN aaev_rec_type,
    x_aaev_rec              OUT NOCOPY aaev_rec_type) IS
  BEGIN
    okc_aae_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aaev_rec,
    x_aaev_rec);

  END UPDATE_ACT_ATTS;

  PROCEDURE UPDATE_ACT_ATTS(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aaev_tbl		    IN aaev_tbl_type,
    x_aaev_tbl              OUT NOCOPY aaev_tbl_type) IS

  BEGIN
    okc_aae_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aaev_tbl,
    x_aaev_tbl);

  END UPDATE_ACT_ATTS;

  PROCEDURE DELETE_ACT_ATTS(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aaev_rec		    IN aaev_rec_type) IS

  BEGIN
    okc_aae_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aaev_rec);

  END DELETE_ACT_ATTS;

  PROCEDURE DELETE_ACT_ATTS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aaev_tbl		    IN aaev_tbl_type) IS

  BEGIN
    okc_aae_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aaev_tbl);

  END DELETE_ACT_ATTS;

  PROCEDURE VALIDATE_ACT_ATTS(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aaev_rec		    IN aaev_rec_type) IS

  BEGIN
    okc_aae_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aaev_rec);

  END VALIDATE_ACT_ATTS;

  PROCEDURE VALIDATE_ACT_ATTS(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aaev_tbl		    IN aaev_tbl_type) IS

  BEGIN
    okc_aae_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aaev_tbl);

  END VALIDATE_ACT_ATTS;

  END OKC_ACTIONS_PVT;

/
