--------------------------------------------------------
--  DDL for Package Body OKL_LEGAL_ENTITY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEGAL_ENTITY_UTIL" AS
/* $Header: OKLRXLEB.pls 120.1 2006/11/17 12:49:17 kthiruva noship $ */

  PROCEDURE get_legal_entity_info
               (p_legal_entity_id IN NUMBER,
                x_legal_entity_rec OUT NOCOPY legal_entity_rec,
                x_return_status  OUT NOCOPY VARCHAR2,
                x_msg_data       OUT NOCOPY VARCHAR2,
                x_msg_count      OUT NOCOPY NUMBER)
  IS

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    XLE_UTILITIES_GRP.Get_LegalEntity_Info
             (x_return_status         => x_return_status ,
  		      x_msg_count		      => x_msg_count,
		      x_msg_data		      => x_msg_data,
        	  P_PARTY_ID    		  => NULL,
        	  P_LegalEntity_ID	      => p_legal_entity_id,
        	  X_LEGALENTITY_INFO 	  => x_legal_entity_rec);

    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
      raise OKL_API.G_EXCEPTION_ERROR;
    End If;

  EXCEPTION
	when OKL_API.G_EXCEPTION_ERROR then
		null;

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
        null;

	when OTHERS then
        null;
  END get_legal_entity_info;

  FUNCTION get_legal_entity_name(p_legal_entity_id IN NUMBER)
  RETURN VARCHAR2
  IS

    CURSOR get_le_name_csr(p_le_id IN NUMBER)
    IS
    SELECT name legal_entity_name
    FROM XLE_ENTITY_PROFILES
    WHERE legal_entity_id = p_le_id;

    l_legal_entity_name   XLE_ENTITY_PROFILES.NAME%TYPE := NULL;

  BEGIN

    OPEN get_le_name_csr(p_le_id   => p_legal_entity_id);
    FETCH get_le_name_csr INTO l_legal_entity_name;
    CLOSE get_le_name_csr;

    RETURN l_legal_entity_name;

  END get_legal_entity_name;

  FUNCTION get_khr_le_id (p_khr_id IN NUMBER)
  RETURN NUMBER
  IS
    CURSOR get_le_id_csr(p_khr_id IN NUMBER)
    IS
    SELECT khr.legal_entity_id
    FROM okl_k_headers khr
    WHERE khr.id = p_khr_id;

    l_legal_entity_id    XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE := NULL;

  BEGIN
    OPEN get_le_id_csr(p_khr_id  => p_khr_id);
    FETCH get_le_id_csr INTO l_legal_entity_id;
    CLOSE get_le_id_csr;

    RETURN l_legal_entity_id;

  END get_khr_le_id;

  FUNCTION get_khr_line_le_id (p_kle_id IN NUMBER)
  RETURN NUMBER
  IS
    CURSOR get_le_id_csr(p_kle_id1 IN NUMBER)
    IS
    SELECT khr.legal_entity_id
    FROM okl_k_headers khr,okc_k_lines_b okc_ln
    WHERE khr.id = okc_ln.dnz_chr_id
--          AND okc_ln.chr_id =okc_ln.dnz_chr_id
          AND okc_ln.id = p_kle_id1;

    l_legal_entity_id    XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE := NULL;

  BEGIN
    OPEN get_le_id_csr(p_kle_id);
    FETCH get_le_id_csr INTO l_legal_entity_id;
    CLOSE get_le_id_csr;

    RETURN l_legal_entity_id;

  END get_khr_line_le_id;

  FUNCTION check_le_id_exists (p_le_id IN NUMBER)
  RETURN NUMBER
  IS
    CURSOR get_le_id_csr(p_le_id1 IN NUMBER)
    IS
    SELECT 1
    FROM XLE_ENTITY_PROFILES
    WHERE legal_entity_id = p_le_id1;

    l_le_exist    Number(1);

  BEGIN
    OPEN get_le_id_csr(p_le_id);
    FETCH get_le_id_csr INTO l_le_exist;
    CLOSE get_le_id_csr;

    RETURN l_le_exist;

  END check_le_id_exists;

END okl_legal_entity_util;

/
