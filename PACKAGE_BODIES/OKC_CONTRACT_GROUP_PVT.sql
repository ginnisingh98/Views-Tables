--------------------------------------------------------
--  DDL for Package Body OKC_CONTRACT_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONTRACT_GROUP_PVT" as
/* $Header: OKCCCGPB.pls 120.0 2005/05/30 04:11:24 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  PROCEDURE add_language IS
  BEGIN
    okc_cgp_pvt.add_language;
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
    l_cgcv_tbl		cgcv_tbl_type := p_cgcv_tbl;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER := 0;
  BEGIN
    create_contract_group(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_rec,
	    x_cgpv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      raise G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
      END IF;
    END IF;

    IF (l_cgcv_tbl.COUNT > 0) THEN
      i := l_cgcv_tbl.FIRST;
      LOOP
        l_cgcv_tbl(i).cgp_parent_id := x_cgpv_rec.id;
        EXIT WHEN (i = l_cgcv_tbl.LAST);
        i := l_cgcv_tbl.NEXT(i);
      END LOOP;
    END IF;
    create_contract_grpngs(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    l_cgcv_tbl,
	    x_cgcv_tbl);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      raise G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
      END IF;
    END IF;
    x_return_status := l_return_status;
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
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    update_contract_group(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_rec,
	    x_cgpv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      raise G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
      END IF;
    END IF;

    update_contract_grpngs(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgcv_tbl,
	    x_cgcv_tbl);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      raise G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
      END IF;
    END IF;
    x_return_status := l_return_status;
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
  END update_ctr_group;

  PROCEDURE validate_ctr_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type,
    p_cgcv_tbl                     IN cgcv_tbl_type) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    validate_contract_group(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      raise G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
      END IF;
    END IF;

    validate_contract_grpngs(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgcv_tbl);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      raise G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
      END IF;
    END IF;
    x_return_status := l_return_status;
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
  END validate_ctr_group;

  PROCEDURE create_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type,
    x_cgpv_rec                     OUT NOCOPY cgpv_rec_type) IS
  BEGIN
    okc_cgp_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_rec,
	    x_cgpv_rec);
  END create_contract_group;

  PROCEDURE create_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_tbl                     IN cgpv_tbl_type,
    x_cgpv_tbl                     OUT NOCOPY cgpv_tbl_type) IS
  BEGIN
    okc_cgp_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_tbl,
	    x_cgpv_tbl);
  END create_contract_group;

  PROCEDURE update_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type,
    x_cgpv_rec                     OUT NOCOPY cgpv_rec_type) IS
  BEGIN
    okc_cgp_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_rec,
	    x_cgpv_rec);
  END update_contract_group;

  PROCEDURE update_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_tbl                     IN cgpv_tbl_type,
    x_cgpv_tbl                     OUT NOCOPY cgpv_tbl_type) IS
  BEGIN
    okc_cgp_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_tbl,
	    x_cgpv_tbl);
  END update_contract_group;

  PROCEDURE delete_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type) IS
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ----------------------------------------------------
    -- FUNCTION delete_parentgroups --
    ----------------------------------------------------
    FUNCTION delete_parentgroups(
      p_cgpv_rec IN cgpv_rec_type
    ) RETURN VARCHAR2 IS
      CURSOR okc_cgcv_included_csr (p_included_cgp_id IN NUMBER) IS
        SELECT id
        FROM  OKC_K_GRPINGS
        WHERE included_cgp_id = p_included_cgp_id;
      l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_index               NUMBER := 1;
      l_cgcv_tbl            okc_contract_group_pub.cgcv_tbl_type;
    BEGIN
      IF p_cgpv_rec.id IS NOT NULL THEN
        FOR c1 IN okc_cgcv_included_csr(p_cgpv_rec.id) LOOP
          l_cgcv_tbl(l_index).id := c1.id;
          l_index := l_index + 1;
        END LOOP;
        IF l_cgcv_tbl.COUNT > 0 THEN
          okc_contract_group_pub.delete_contract_grpngs(
                        p_api_version => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => l_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
                        p_cgcv_tbl => l_cgcv_tbl);
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN OTHERS THEN
         OKC_API.set_message(p_app_name      => g_app_name,
                             p_msg_name      => g_unexpected_error,
                             p_token1        => g_sqlcode_token,
                             p_token1_value  => sqlcode,
                             p_token2        => g_sqlerrm_token,
                             p_token2_value  => sqlerrm);
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RETURN (l_return_status);
    END delete_parentgroups;
    ----------------------------------------------------
    -- FUNCTION delete_subgroups --
    ----------------------------------------------------
    FUNCTION delete_subgroups(
      p_cgpv_rec IN cgpv_rec_type
    ) RETURN VARCHAR2 IS
      child_record_error          EXCEPTION;
      CURSOR okc_cgcv_parent_csr (p_cgp_parent_id IN NUMBER) IS
        SELECT id
        FROM  OKC_K_GRPINGS
        WHERE cgp_parent_id = p_cgp_parent_id;
      l_dummy               VARCHAR2(1);
      l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_found           BOOLEAN := FALSE;
      l_index               NUMBER := 1;
      l_cgcv_tbl            okc_contract_group_pub.cgcv_tbl_type;
    BEGIN
      IF p_cgpv_rec.id IS NOT NULL THEN
        FOR c1 IN okc_cgcv_parent_csr(p_cgpv_rec.id) LOOP
          l_cgcv_tbl(l_index).id := c1.id;
          l_index := l_index + 1;
        END LOOP;
        IF l_cgcv_tbl.COUNT > 0 THEN
          okc_contract_group_pub.delete_contract_grpngs(
                        p_api_version => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => l_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
                        p_cgcv_tbl => l_cgcv_tbl);
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN OTHERS THEN
         OKC_API.set_message(p_app_name      => g_app_name,
                             p_msg_name      => g_unexpected_error,
                             p_token1        => g_sqlcode_token,
                             p_token1_value  => sqlcode,
                             p_token2        => g_sqlerrm_token,
                             p_token2_value  => sqlerrm);
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RETURN (l_return_status);
    END delete_subgroups;
    ----------------------------------------------------
  BEGIN
    l_return_status := delete_subgroups(p_cgpv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_return_status := delete_parentgroups(p_cgpv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    okc_cgp_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_rec);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_contract_group;

  PROCEDURE delete_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_tbl                     IN cgpv_tbl_type) IS
    i				   NUMBER := 0;
    l_return_status 		   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_cgpv_tbl.COUNT > 0) THEN
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
    okc_cgp_pvt.lock_row(
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
  BEGIN
    okc_cgp_pvt.lock_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_tbl);
  END lock_contract_group;

  PROCEDURE validate_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type) IS
  BEGIN
    okc_cgp_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_rec);
  END validate_contract_group;

  PROCEDURE validate_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_tbl                     IN cgpv_tbl_type) IS
  BEGIN
    okc_cgp_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgpv_tbl);
  END validate_contract_group;
    ------------------------------------
    -- FUNCTION validate_recursion --
    ------------------------------------
    FUNCTION validate_recursion(
      p_cgcv_rec IN cgcv_rec_type
    ) RETURN VARCHAR2 IS
      recursive_error          EXCEPTION;
      CURSOR okc_cgcv_csr (p_cgp_parent_id IN NUMBER,
                           p_included_cgp_id IN NUMBER) IS
        SELECT 'x'
        FROM  OKC_K_GRPINGS
        WHERE included_cgp_id = p_cgp_parent_id
        START WITH cgp_parent_id = p_included_cgp_id
        CONNECT BY PRIOR included_cgp_id = cgp_parent_id;
      l_dummy               VARCHAR2(1);
      l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_found           BOOLEAN := FALSE;
    BEGIN
      IF (p_cgcv_rec.cgp_parent_id IS NOT NULL AND
          p_cgcv_rec.included_cgp_id IS NOT NULL) THEN
        IF p_cgcv_rec.cgp_parent_id = p_cgcv_rec.included_cgp_id THEN
		 OKC_API.SET_MESSAGE('OKC', 'OKC_INVALID_CGP_PARENT_ID');
          ----OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'CGP_PARENT_ID');
          RAISE recursive_error;
        END IF;
        OPEN okc_cgcv_csr(p_cgcv_rec.cgp_parent_id,
                          p_cgcv_rec.included_cgp_id);
        FETCH okc_cgcv_csr INTO l_dummy;
        l_row_found := okc_cgcv_csr%FOUND;
        CLOSE okc_cgcv_csr;
        IF (l_row_found) THEN
		  OKC_API.SET_MESSAGE('OKC', 'OKC_INVALID_CGP_PARENT_ID');
            --- OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'CGP_PARENT_ID');
          RAISE recursive_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN recursive_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_recursion;
    ----------------------------------------------------
    ------------------------------------
    -- FUNCTION check_group_type --
    ------------------------------------
    -- Make sure that a public group consists only of public
    -- groups. It cannot have private groups as its member.
    FUNCTION check_group_type(
      p_cgcv_rec IN cgcv_rec_type
    ) RETURN VARCHAR2 IS
      invalid_group_error   EXCEPTION;
      CURSOR okc_cgpv_csr (p_id IN NUMBER) IS
        SELECT public_yn,
               user_id
        FROM  OKC_K_GROUPS_B
        WHERE id = p_id;
      l_group_public_yn     OKC_K_GROUPS_B.PUBLIC_YN%TYPE;
      l_subgroup_public_yn  OKC_K_GROUPS_B.PUBLIC_YN%TYPE;
      l_group_user_id       OKC_K_GROUPS_B.USER_ID%TYPE;
      l_subgroup_user_id    OKC_K_GROUPS_B.USER_ID%TYPE;
      l_user_id             NUMBER(15) := TO_NUMBER(fnd_profile.value('USER_ID'));
      l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      OPEN okc_cgpv_csr(p_cgcv_rec.cgp_parent_id);
      FETCH okc_cgpv_csr
	  INTO l_group_public_yn,
		  l_group_user_id;
      CLOSE okc_cgpv_csr;
      IF p_cgcv_rec.included_cgp_id IS NOT NULL THEN
        OPEN okc_cgpv_csr(p_cgcv_rec.included_cgp_id);
        FETCH okc_cgpv_csr
	    INTO l_subgroup_public_yn,
		    l_subgroup_user_id;
        CLOSE okc_cgpv_csr;
        IF l_group_public_yn = 'Y' THEN
          -- The parent is a public group
          IF l_subgroup_public_yn = 'N' THEN
            -- The member is not a public group
            OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'INCLUDED_CGP_ID');
            RAISE invalid_group_error;
          END IF;
        ELSE
		IF l_subgroup_public_yn = 'N' THEN
		  -- Make sure that only the current user can manipulate his private groups and
		  -- private subgroups.
		  IF (l_group_user_id <> l_subgroup_user_id) OR
			(l_group_user_id <> l_user_id) OR
			(l_subgroup_user_id <> l_user_id) THEN
              OKC_API.set_message(G_APP_NAME, 'OKC_PRIVATE_GROUP_ERROR');
              RAISE invalid_group_error;
            END IF;
          END IF;
        END IF;
      ELSIF p_cgcv_rec.included_chr_id IS NOT NULL THEN
	   IF (l_group_public_yn = 'N') AND
		 (l_group_user_id <> l_user_id) THEN
          OKC_API.set_message(G_APP_NAME, 'OKC_PRIVATE_GROUP_ERROR');
          RAISE invalid_group_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN invalid_group_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END check_group_type;
    ----------------------------------------------------
  PROCEDURE create_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type,
    x_cgcv_rec                     OUT NOCOPY cgcv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := validate_recursion(p_cgcv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    okc_cgc_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgcv_rec,
	    x_cgcv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_return_status := check_group_type(p_cgcv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
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
    IF (p_cgcv_tbl.COUNT > 0) THEN
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
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := validate_recursion(p_cgcv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    okc_cgc_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgcv_rec,
	    x_cgcv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_return_status := check_group_type(p_cgcv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_contract_grpngs;

  PROCEDURE update_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type,
    x_cgcv_tbl                     OUT NOCOPY cgcv_tbl_type) IS
    i			NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_cgcv_tbl.COUNT > 0) THEN
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
  BEGIN
    okc_cgc_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgcv_rec);
  END delete_contract_grpngs;

  PROCEDURE delete_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type) IS
  BEGIN
    okc_cgc_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgcv_tbl);
  END delete_contract_grpngs;

  PROCEDURE lock_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type) IS
  BEGIN
    okc_cgc_pvt.lock_row(
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
  BEGIN
    okc_cgc_pvt.lock_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgcv_tbl);
  END lock_contract_grpngs;

  PROCEDURE validate_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type) IS
    l_return_status		   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := validate_recursion(p_cgcv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    okc_cgc_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cgcv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_return_status := check_group_type(p_cgcv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_contract_grpngs;

  PROCEDURE validate_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type) IS
    i			NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_cgcv_tbl.COUNT > 0) THEN
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
    okc_cgp_pvt.Validate_name(x_return_status, p_cgpv_rec);
  END Validate_Name;

  PROCEDURE Validate_Public_YN(x_return_status OUT NOCOPY VARCHAR2,
                               p_cgpv_rec IN cgpv_rec_type) IS
  BEGIN
    okc_cgp_pvt.Validate_Public_YN(x_return_status, p_cgpv_rec);
  END Validate_Public_YN;

  PROCEDURE Validate_Short_Description(x_return_status OUT NOCOPY VARCHAR2,
                                       p_cgpv_rec IN cgpv_rec_type) IS
  BEGIN
    okc_cgp_pvt.Validate_Short_Description(x_return_status, p_cgpv_rec);
  END Validate_Short_Description;

  FUNCTION Validate_Record(p_cgpv_rec IN cgpv_rec_type)
    RETURN VARCHAR2 IS
  BEGIN
    Return(okc_cgp_pvt.Validate_Record(p_cgpv_rec));
  END;

END okc_contract_group_pvt;

/
