--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_PARTY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_PARTY_PVT" AS
/* $Header: OKLRCPCB.pls 120.2 2005/10/20 09:38:41 sjalasut noship $ */
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_PARTY_PVT';
  G_REQUIRED_VALUE   CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN   CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
-- Start of comments
--
-- Procedure Name  : create_contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE create_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type,
                              x_ctcv_rec	OUT NOCOPY	ctcv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'create_contact';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

CURSOR cur_ctcv IS
SELECT 'x'
FROM   okc_contacts
WHERE  cpl_id                     = p_ctcv_rec.CPL_ID
AND    cro_code                   = p_ctcv_rec.CRO_CODE
AND    NVL(jtot_object1_code,'X') = NVL(p_ctcv_rec.JTOT_OBJECT1_CODE,'X')
AND    NVL(object1_id1,'X')       = NVL(p_ctcv_rec.OBJECT1_ID1,'X')
AND    NVL(object1_id2,'X')       = NVL(p_ctcv_rec.OBJECT1_ID2,'X')
AND    id                        <> NVL(p_ctcv_rec.ID,-9999);

l_row_found       BOOLEAN     := FALSE;
l_dummy           VARCHAR2(1);

BEGIN
l_return_status := OKL_API.START_ACTIVITY(p_api_name      => l_api_name
                                          ,p_init_msg_list => p_init_msg_list
                                          ,p_api_type      => '_PVT'
                                          ,x_return_status => x_return_status
                                          );
IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

x_return_status := OKL_API.G_RET_STS_SUCCESS;

-- Not null Validation for Contact Role
IF ((p_ctcv_rec.cro_code = OKL_API.G_MISS_CHAR) OR (p_ctcv_rec.cro_code IS NULL)) THEN
  OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_CONTACT_ROLE_REQUIRED');
  l_return_status :=okl_api.g_ret_sts_error;
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

-- Not null Validation for Contact Name
IF ((p_ctcv_rec.object1_id1 = OKL_API.G_MISS_CHAR) OR (p_ctcv_rec.object1_id1 IS NULL)) OR
    ((p_ctcv_rec.object1_id2 = OKL_API.G_MISS_CHAR) OR (p_ctcv_rec.object1_id2 IS NULL)) THEN
  OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_CONTACT_NAME_REQUIRED');
  l_return_status :=okl_api.g_ret_sts_error;
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

IF ( (p_ctcv_rec.CPL_ID IS NOT NULL) AND (p_ctcv_rec.CPL_ID <> OKC_API.G_MISS_NUM) )
     AND ( (p_ctcv_rec.CRO_CODE IS NOT NULL) AND (p_ctcv_rec.CRO_CODE <> OKC_API.G_MISS_CHAR) ) THEN
  OPEN  cur_ctcv;
  FETCH cur_ctcv INTO l_dummy;
  l_row_found := cur_ctcv%FOUND;
  CLOSE cur_ctcv;
  IF (l_row_found) THEN
    -- Display the newly defined error message
    OKL_API.set_message(G_APP_NAME, 'OKL_DUP_CONTACT_ROLE');
    x_return_status := OKL_API.G_RET_STS_ERROR;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
END IF;

OKL_OKC_MIGRATION_PVT.create_contact(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_ctcv_rec,
                              x_ctcv_rec);

    /* Manu 29-Jun-2005 Begin */
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(p_api_version    => p_api_version
                         ,p_init_msg_list => p_init_msg_list
                         ,x_return_status => x_return_status
                         ,x_msg_count     => x_msg_count
                         ,x_msg_data      => x_msg_data
                         ,p_program_id    => x_ctcv_rec.dnz_chr_id
                        );
  END IF;
    /* Manu 29-Jun-2005 END */

OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
                            (p_api_name  => l_api_name
                             ,p_pkg_name  => G_PKG_NAME
                             ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                             ,x_msg_count => x_msg_count
                             ,x_msg_data  => x_msg_data
                             ,p_api_type  => '_PVT'
                             );
end create_contact;
-- Start of comments
--
-- Procedure Name  : create_contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE create_contact(p_api_version	IN NUMBER,
                         p_init_msg_list IN	VARCHAR2 default OKC_API.G_FALSE,
                         x_return_status OUT NOCOPY	VARCHAR2,
                         x_msg_count OUT NOCOPY	NUMBER,
                         x_msg_data OUT NOCOPY	VARCHAR2,
                         p_ctcv_tbl IN	ctcv_tbl_type,
                         x_ctcv_tbl OUT NOCOPY	ctcv_tbl_type) IS
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      IF (p_ctcv_tbl.COUNT>0) THEN
        i := p_ctcv_tbl.FIRST;
        LOOP
	    create_contact(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_ctcv_rec=>p_ctcv_tbl(i),
                              x_ctcv_rec=>x_ctcv_tbl(i));
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          EXIT WHEN (i=p_ctcv_tbl.LAST);
          i := p_ctcv_tbl.NEXT(i);
        END LOOP;
      END IF;
EXCEPTION
WHEN OTHERS THEN NULL;

END create_contact;
-- Start of comments
--
-- Procedure Name  : update_contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE update_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_rec	IN	ctcv_rec_type,
                              x_ctcv_rec	OUT NOCOPY	ctcv_rec_type) IS
l_api_name                     CONSTANT VARCHAR2(30) := 'update_contact';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
l_return_status := OKL_API.START_ACTIVITY(p_api_name      => l_api_name
                                          ,p_init_msg_list => p_init_msg_list
                                          ,p_api_type      => '_PVT'
                                          ,x_return_status => x_return_status
                                          );
IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

x_return_status := OKL_API.G_RET_STS_SUCCESS;
  OKL_OKC_MIGRATION_PVT.update_contact(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_ctcv_rec,
                              x_ctcv_rec);

    /* Manu 29-Jun-2005 Begin */
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(p_api_version    => p_api_version
                         ,p_init_msg_list => p_init_msg_list
                         ,x_return_status => x_return_status
                         ,x_msg_count     => x_msg_count
                         ,x_msg_data      => x_msg_data
                         ,p_program_id    => x_ctcv_rec.dnz_chr_id
                        );
  END IF;
    /* Manu 29-Jun-2005 END */

OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
                            (p_api_name  => l_api_name
                             ,p_pkg_name  => G_PKG_NAME
                             ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                             ,x_msg_count => x_msg_count
                             ,x_msg_data  => x_msg_data
                             ,p_api_type  => '_PVT'
                             );
END update_contact;

-- Start of comments
--
-- Procedure Name  : update_contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE update_contact(p_api_version	IN	NUMBER,
                         p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                         x_return_status	OUT NOCOPY	VARCHAR2,
                         x_msg_count	OUT NOCOPY	NUMBER,
                         x_msg_data	OUT NOCOPY	VARCHAR2,
                         p_ctcv_tbl	IN	ctcv_tbl_type,
                         x_ctcv_tbl	OUT NOCOPY	ctcv_tbl_type) IS
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      IF (p_ctcv_tbl.COUNT>0) THEN
        i := p_ctcv_tbl.FIRST;
        LOOP
	    update_contact(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_ctcv_rec=>p_ctcv_tbl(i),
                              x_ctcv_rec=>x_ctcv_tbl(i));
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          EXIT WHEN (i=p_ctcv_tbl.LAST);
          i := p_ctcv_tbl.NEXT(i);
        END LOOP;
      END IF;
EXCEPTION
WHEN OTHERS THEN NULL;
END update_contact;

-- Start of comments
--
-- Procedure Name  : delete_contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE delete_contact(p_api_version	IN	NUMBER,
                         p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                         x_return_status	OUT NOCOPY	VARCHAR2,
                         x_msg_count	OUT NOCOPY	NUMBER,
                         x_msg_data	OUT NOCOPY	VARCHAR2,
                         p_ctcv_rec	IN	ctcv_rec_type) IS
l_api_name                     CONSTANT VARCHAR2(30) := 'delete_contact';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_dnz_chr_id                   OKC_CONTACTS.DNZ_CHR_ID%TYPE;

CURSOR cur_get_dnz_chr_id IS
SELECT dnz_chr_id
FROM   okc_contacts
WHERE  id = p_ctcv_rec.id;

BEGIN
l_return_status := OKL_API.START_ACTIVITY(p_api_name      => l_api_name
                                          ,p_init_msg_list => p_init_msg_list
                                          ,p_api_type      => '_PVT'
                                          ,x_return_status => x_return_status
                                          );
IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

    /* Manu 29-Jun-2005 Begin */
  OPEN  cur_get_dnz_chr_id;
  FETCH cur_get_dnz_chr_id INTO l_dnz_chr_id;
  CLOSE cur_get_dnz_chr_id;
    /* Manu 29-Jun-2005 END */

x_return_status := OKL_API.G_RET_STS_SUCCESS;
  OKL_OKC_MIGRATION_PVT.delete_contact(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_ctcv_rec);



    /* Manu 29-Jun-2005 Begin */
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(p_api_version    => p_api_version
                         ,p_init_msg_list => p_init_msg_list
                         ,x_return_status => x_return_status
                         ,x_msg_count     => x_msg_count
                         ,x_msg_data      => x_msg_data
                         ,p_program_id    => l_dnz_chr_id
                        );
  END IF;
    /* Manu 29-Jun-2005 END */

OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
                            (p_api_name  => l_api_name
                             ,p_pkg_name  => G_PKG_NAME
                             ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                             ,x_msg_count => x_msg_count
                             ,x_msg_data  => x_msg_data
                             ,p_api_type  => '_PVT'
                             );
END delete_contact;

-- Start of comments
--
-- Procedure Name  : delete_contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE delete_contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_ctcv_tbl	IN	ctcv_tbl_type) IS
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      IF (p_ctcv_tbl.COUNT>0) THEN
        i := p_ctcv_tbl.FIRST;
        LOOP
	    delete_contact(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_ctcv_rec=>p_ctcv_tbl(i));
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          END IF;
          EXIT WHEN (i=p_ctcv_tbl.LAST);
          i := p_ctcv_tbl.NEXT(i);
        END LOOP;
      END IF;
EXCEPTION
WHEN OTHERS THEN NULL;
END delete_contact;

-- Start of comments
--
-- Procedure Name  : create_k_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE create_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_rec	IN	cplv_rec_type,
                              x_cplv_rec	OUT NOCOPY	cplv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'create_k_party_role';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

CURSOR C1(p_chr_id okc_k_party_roles_b.chr_id%TYPE,
          p_rle_code okc_k_party_roles_b.rle_code%TYPE,
          p_jtot_object1_code okc_k_party_roles_b.jtot_object1_code%TYPE,
          p_object1_id1 okc_k_party_roles_b.object1_id1%TYPE,
          p_object1_id2 okc_k_party_roles_b.object1_id2%TYPE) is
SELECT id
FROM okc_k_party_roles_b
WHERE chr_id = p_chr_id
AND rle_code = p_rle_code
AND jtot_object1_code = p_jtot_object1_code
AND object1_id1 = p_object1_id1
AND object1_id2 = p_object1_id2;

l_id NUMBER;
l_row_found BOOLEAN := FALSE;

BEGIN


l_return_status := OKL_API.START_ACTIVITY(p_api_name      => l_api_name
                                          ,p_init_msg_list => p_init_msg_list
                                          ,p_api_type      => '_PVT'
                                          ,x_return_status => x_return_status
                                          );
IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

x_return_status := OKL_API.G_RET_STS_SUCCESS;

-- Not null Validation for Party Role
IF ((p_cplv_rec.rle_code = OKL_API.G_MISS_CHAR) OR (p_cplv_rec.rle_code IS NULL)) THEN
  OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_PARTY_ROLE_REQUIRED');
  l_return_status :=okl_api.g_ret_sts_error;
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

-- Not null Validation for Party Name
IF ((p_cplv_rec.object1_id1 = OKL_API.G_MISS_CHAR) OR (p_cplv_rec.object1_id1 IS NULL)) OR
    ((p_cplv_rec.object1_id2 = OKL_API.G_MISS_CHAR) OR (p_cplv_rec.object1_id2 IS NULL)) THEN
  OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_PARTY_NAME_REQUIRED');
  l_return_status :=okl_api.g_ret_sts_error;
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

IF p_cplv_rec.chr_id IS NOT NULL AND p_cplv_rec.chr_id <> OKC_API.G_MISS_NUM THEN
  OPEN c1(p_cplv_rec.chr_id,
          p_cplv_rec.rle_code,
          p_cplv_rec.jtot_object1_code,
          p_cplv_rec.object1_id1,
          p_cplv_rec.object1_id2);
  FETCH c1 INTO l_id;
  l_row_found := c1%FOUND;
  CLOSE c1;
END IF;

IF l_row_found THEN
  IF l_id <> p_cplv_rec.id THEN
    OKL_API.set_message(p_app_name      => g_app_name,
                      p_msg_name      => 'OKL_DUP_PARTY'
                      );
    x_return_status := OKL_API.G_RET_STS_ERROR;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
END IF;

OKL_OKC_MIGRATION_PVT.create_k_party_role(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_cplv_rec,
                              x_cplv_rec);

    /* Manu 29-Jun-2005 Begin */
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(p_api_version    => p_api_version
                         ,p_init_msg_list => p_init_msg_list
                         ,x_return_status => x_return_status
                         ,x_msg_count     => x_msg_count
                         ,x_msg_data      => x_msg_data
                         ,p_program_id    => x_cplv_rec.dnz_chr_id
                        );
  END IF;
    /* Manu 29-Jun-2005 END */

OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
                            (p_api_name  => l_api_name
                             ,p_pkg_name  => G_PKG_NAME
                             ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                             ,x_msg_count => x_msg_count
                             ,x_msg_data  => x_msg_data
                             ,p_api_type  => '_PVT'
                             );
WHEN OTHERS THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
                            (p_api_name  => l_api_name
                             ,p_pkg_name  => G_PKG_NAME
                             ,p_exc_name  => 'OTHERS'
                             ,x_msg_count => x_msg_count
                             ,x_msg_data  => x_msg_data
                             ,p_api_type  => '_PVT'
                             );
END create_k_party_role;

-- Start of comments
--
-- Procedure Name  : create_k_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE create_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_tbl	IN	cplv_tbl_type,
                              x_cplv_tbl	OUT NOCOPY	cplv_tbl_type) IS
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      IF (p_cplv_tbl.COUNT>0) THEN
        i := p_cplv_tbl.FIRST;
        LOOP
	    create_k_party_role(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_cplv_rec=>p_cplv_tbl(i),
                              x_cplv_rec=>x_cplv_tbl(i));
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          EXIT WHEN (i=p_cplv_tbl.LAST);
          i := p_cplv_tbl.NEXT(i);
        END LOOP;
      END IF;
EXCEPTION
WHEN OTHERS THEN NULL;
END create_k_party_role;

-- Start of comments
--
-- Procedure Name  : update_k_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE update_k_party_role(p_api_version	IN  NUMBER,
                              p_init_msg_list	IN  VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY VARCHAR2,
                              x_msg_count	OUT NOCOPY NUMBER,
                              x_msg_data	OUT NOCOPY VARCHAR2,
                              p_cplv_rec	IN  cplv_rec_type,
                              x_cplv_rec	OUT NOCOPY  cplv_rec_type) IS
l_api_name                    CONSTANT VARCHAR2(30) := 'update_k_party_role';
l_api_version                 CONSTANT NUMBER := 1;
l_return_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
l_return_status := OKL_API.START_ACTIVITY(p_api_name      => l_api_name
                                          ,p_init_msg_list => p_init_msg_list
                                          ,p_api_type      => '_PVT'
                                          ,x_return_status => x_return_status
                                          );
IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

x_return_status := OKL_API.G_RET_STS_SUCCESS;
  OKL_OKC_MIGRATION_PVT.update_k_party_role(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_cplv_rec,
                              x_cplv_rec);

    /* Manu 29-Jun-2005 Begin */

  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(p_api_version    => p_api_version
                         ,p_init_msg_list => p_init_msg_list
                         ,x_return_status => x_return_status
                         ,x_msg_count     => x_msg_count
                         ,x_msg_data      => x_msg_data
                         ,p_program_id    => x_cplv_rec.dnz_chr_id
                        );
  END IF;

    /* Manu 29-Jun-2005 END */

OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
                            (p_api_name  => l_api_name
                             ,p_pkg_name  => G_PKG_NAME
                             ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                             ,x_msg_count => x_msg_count
                             ,x_msg_data  => x_msg_data
                             ,p_api_type  => '_PVT'
                             );
END update_k_party_role;

-- Start of comments
--
-- Procedure Name  : update_k_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_tbl	IN	cplv_tbl_type,
                              x_cplv_tbl	OUT NOCOPY	cplv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      IF (p_cplv_tbl.COUNT>0) THEN
        i := p_cplv_tbl.FIRST;
        LOOP
	    update_k_party_role(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_cplv_rec=>p_cplv_tbl(i),
                              x_cplv_rec=>x_cplv_tbl(i));
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          EXIT WHEN (i=p_cplv_tbl.LAST);
          i := p_cplv_tbl.NEXT(i);
        END LOOP;
      END IF;
EXCEPTION
WHEN OTHERS THEN NULL;
END update_k_party_role;

-- Start of comments
--
-- Procedure Name  : delete_k_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE delete_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_rec	IN	cplv_rec_type) IS

  l_api_name                     CONSTANT VARCHAR2(30) := 'delete_k_party_role';
  l_api_version                  CONSTANT NUMBER := 1;
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;


  l_dummy_var VARCHAR2(1) := '?';
  l_rle_code_var VARCHAR2(30) DEFAULT NULL;
  l_dnz_chr_id okc_k_party_roles_v.dnz_chr_id%TYPE;

  CURSOR l_cpl_csr IS
  SELECT 'x'
  FROM OKC_CONTACTS_V
  WHERE CPL_ID = p_cplv_rec.id;

  CURSOR l_rle_code_csr IS
  SELECT rle_code
  FROM OKC_K_PARTY_ROLES_B
  WHERE ID = p_cplv_rec.id;

  CURSOR cur_get_dnz_chr_id IS
  SELECT dnz_chr_id
  FROM   okc_k_party_roles_v
  WHERE  id = p_cplv_rec.id;

  CURSOR c_party_share_exist_csr(cp_chr_id okc_k_headers_b.id%TYPE, cp_cpl_id okc_k_party_roles_b.id%TYPE)IS
  SELECT okl_vp_jtf_party_name_pub.get_party_name(pr.rle_code,chr.buy_or_sell,pr.object1_id1,pr.object1_id2) party_name
    FROM okc_k_party_roles_b pr
        ,okc_k_headers_b chr
        ,okc_rules_b rule
   WHERE pr.id = cp_cpl_id
     AND rule.rule_information1 = pr.id
     AND rule.rule_information_category = 'VGLRSP'
     AND rule.dnz_chr_id = cp_chr_id
     AND pr.dnz_chr_id = chr.id
     AND chr.id = cp_chr_id;
  lv_party_name hz_parties.party_name%TYPE;

BEGIN
  l_return_status := OKL_API.START_ACTIVITY(p_api_name      => l_api_name
                                            ,p_init_msg_list => p_init_msg_list
                                            ,p_api_type      => '_PVT'
                                            ,x_return_status => x_return_status
                                            );
  IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  open l_cpl_csr;
  fetch l_cpl_csr into l_dummy_var;
  close l_cpl_csr;
  IF (l_dummy_var = 'x') then
    OKL_API.set_message(p_app_name      => g_app_name,
                        p_msg_name      => 'OKL_PARTY_CONTACTS_EXIST'
                        );
    x_return_status := OKL_API.G_RET_STS_ERROR;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  --bug#2455475
  OPEN l_rle_code_csr;
  FETCH l_rle_code_csr INTO l_rle_code_var;
  CLOSE l_rle_code_csr;
  IF (l_rle_code_var = 'LESSOR' OR l_rle_code_var = 'OKL_VENDOR' OR l_rle_code_var IS NULL) THEN
    OKL_API.set_message(p_app_name      => g_app_name,
                        p_msg_name      => 'OKL_CANNOT_DEL_LESSOR_VENDOR'
                        );
    x_return_status := OKL_API.G_RET_STS_ERROR;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

    /* Manu 29-Jun-2005 Begin */
  OPEN cur_get_dnz_chr_id;
  FETCH cur_get_dnz_chr_id INTO l_dnz_chr_id;
  CLOSE cur_get_dnz_chr_id;
    /* Manu 29-Jun-2005 END */

  -- sjalasut, added logic to restrict deletion of party role when the party is involved in residual share
  -- check to see if cpl_id exists in okc_rules_b (even if his percentage is 0 ??) and error out in such a case
  OPEN c_party_share_exist_csr(cp_chr_id => l_dnz_chr_id, cp_cpl_id => p_cplv_rec.id);
  FETCH c_party_share_exist_csr INTO lv_party_name;
  IF(c_party_share_exist_csr%FOUND)THEN
    CLOSE c_party_share_exist_csr;
    okl_api.set_message(p_app_name => G_APP_NAME
                       ,p_msg_name => 'OKL_VN_NODELPARTY_SHARE_EXISTS'
                       ,p_token1 => 'PARTY_NAME'
                       ,p_token1_value => lv_party_name
                       );
    x_return_status := OKL_API.G_RET_STS_ERROR;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSE
    CLOSE c_party_share_exist_csr;
  END IF;
  -- sjalasut. end code changes for Vendor Residual Share Enhancement

  OKL_OKC_MIGRATION_PVT.delete_k_party_role(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_cplv_rec);


    /* Manu 29-Jun-2005 Begin */
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(p_api_version    => p_api_version
                         ,p_init_msg_list => p_init_msg_list
                         ,x_return_status => x_return_status
                         ,x_msg_count     => x_msg_count
                         ,x_msg_data      => x_msg_data
                         ,p_program_id    => l_dnz_chr_id
                        );
  END IF;
    /* Manu 29-Jun-2005 END */

OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
                            (p_api_name  => l_api_name
                             ,p_pkg_name  => G_PKG_NAME
                             ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                             ,x_msg_count => x_msg_count
                             ,x_msg_data  => x_msg_data
                             ,p_api_type  => '_PVT'
                             );
END delete_k_party_role;

-- Start of comments
--
-- Procedure Name  : delete_k_party_role
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE delete_k_party_role(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cplv_tbl	IN	cplv_tbl_type) IS
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      IF (p_cplv_tbl.COUNT>0) THEN
        i := p_cplv_tbl.FIRST;
        LOOP
	    delete_k_party_role(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_cplv_rec=>p_cplv_tbl(i));
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          EXIT WHEN (i=p_cplv_tbl.LAST);
          i := p_cplv_tbl.NEXT(i);
        END LOOP;
      END IF;
EXCEPTION
WHEN OTHERS THEN NULL;
END delete_k_party_role;

END; -- Package Body OKL_CONTRACT_PARTY_PVT

/
