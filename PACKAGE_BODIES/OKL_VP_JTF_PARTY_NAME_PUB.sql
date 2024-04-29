--------------------------------------------------------
--  DDL for Package Body OKL_VP_JTF_PARTY_NAME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_JTF_PARTY_NAME_PUB" AS
/* $Header: OKLPCTSB.pls 120.1 2005/09/08 12:49:29 sjalasut noship $ */
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_JTF_CONTACT_EXTRACT_PUB';
----------------------------------------------------------------------------
--Start of Comments
--Procedure   : Get Party
--Description : Returns Name, Description for a given role or all the roles
--              attached to a contract
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE Get_Party (p_api_version         IN	NUMBER,
                     p_init_msg_list	  IN	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                     x_return_status	  OUT NOCOPY	VARCHAR2,
                     x_msg_count	        OUT NOCOPY	NUMBER,
                     x_msg_data	        OUT NOCOPY	VARCHAR2,
                     p_chr_id		IN  VARCHAR2,
                     p_cle_id      IN  VARCHAR2,
                     p_role_code   IN  OKC_K_PARTY_ROLES_V.rle_code%TYPE,
                     p_intent      IN  VARCHAR2 DEFAULT 'S',
                     x_party_tab   OUT NOCOPY party_tab_type) IS
l_api_name                     CONSTANT VARCHAR2(30) := 'get_party';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
  l_return_status := OKC_API.START_ACTIVITY(SUBSTR(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call Before Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
 Okl_Vp_Jtf_Party_Name_Pvt.Get_Party (p_api_version,
                                       p_init_msg_list,
                                       x_return_status,
                                       x_msg_count,
                                       x_msg_data,
                                       p_chr_id,
                                       p_cle_id,
                                       p_role_code,
                                       p_intent,
                                       x_party_tab => x_party_tab);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
END Get_Party;
----------------------------------------------------------------------------
--Start of Comments
--Procedure     : Get_Party
--Description   : Fetches Name, Description of a Party role for a given
--                object1_id1 and object2_id2
--End of comments
-----------------------------------------------------------------------------
PROCEDURE Get_Party (p_api_version         IN	NUMBER,
                     p_init_msg_list	  IN	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                     x_return_status	  OUT NOCOPY	VARCHAR2,
                     x_msg_count	        OUT NOCOPY	NUMBER,
                     x_msg_data	        OUT NOCOPY	VARCHAR2,
                     p_role_code           IN  VARCHAR2,
                     p_intent              IN  VARCHAR2,
                     p_id1                 IN  VARCHAR2,
                     p_id2                 IN  VARCHAR2,
                     x_id1                 OUT NOCOPY VARCHAR2,
                     x_id2                 OUT NOCOPY VARCHAR2,
                     x_name                OUT NOCOPY VARCHAR2,
                     x_description         OUT NOCOPY VARCHAR2) IS
l_api_name                     CONSTANT VARCHAR2(30) := 'get_party';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
  l_return_status := OKC_API.START_ACTIVITY(SUBSTR(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call Before Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
Okl_Vp_Jtf_Party_Name_Pvt.Get_Party (p_api_version,
                     p_init_msg_list,
                     x_return_status,
                     x_msg_count,
                     x_msg_data,
                     p_role_code,
                     p_intent,
                     p_id1,
                     p_id2,
                     x_id1,
                     x_id2,
                     x_name,
                     x_description);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
END Get_Party;
---------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : get_contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE get_contact(p_api_version	   IN	NUMBER,
                      p_init_msg_list	   IN	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                      x_return_status	   OUT NOCOPY	VARCHAR2,
                      x_msg_count	   OUT NOCOPY	NUMBER,
                      x_msg_data	   OUT NOCOPY	VARCHAR2,
                      p_rle_code           IN VARCHAR2,
                      p_cro_code           IN  VARCHAR2,
                      p_intent             IN  VARCHAR2,
                      p_id1                IN  VARCHAR2,
                      p_id2                IN  VARCHAR2,
                      x_id1                OUT NOCOPY VARCHAR2,
                      x_id2                OUT NOCOPY VARCHAR2,
                      x_name               OUT NOCOPY VARCHAR2,
                      x_description        OUT NOCOPY VARCHAR2) IS
l_api_name                     CONSTANT VARCHAR2(30) := 'get_contact';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
  l_return_status := OKC_API.START_ACTIVITY(SUBSTR(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call Before Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  Okl_Vp_Jtf_Party_Name_Pvt.get_contact(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_rle_code,
                              p_cro_code,
                              p_intent,
                              p_id1,
                              p_id2,
                              x_id1,
                              x_id2,
                              x_name,
                              x_description);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
END get_contact;

FUNCTION get_party_name (p_role_code IN VARCHAR2
                        ,p_intent IN VARCHAR2
                        ,p_id1 IN VARCHAR2
                        ,p_id2 IN VARCHAR2) RETURN VARCHAR2
AS

l_party_name          VARCHAR2(500);

BEGIN

          l_party_name := OKL_VP_JTF_PARTY_NAME_PVT.Get_Party_name(p_role_code    => p_role_code,
                                        	p_intent          => p_intent,
                                        	p_id1             => p_id1,
                                        	p_id2             => p_id2);

	RETURN l_party_name;
END get_party_name;



FUNCTION get_party_contact_name (p_rle_code IN VARCHAR2
                        	,p_cro_code IN VARCHAR2
                        	,p_intent IN VARCHAR2
                        	,p_id1 IN VARCHAR2
                        	,p_id2 IN VARCHAR2) RETURN VARCHAR2
AS

l_party_name          VARCHAR2(500);

BEGIN

          l_party_name := OKL_VP_JTF_PARTY_NAME_PVT.Get_Party_Contact_name(p_rle_code    => p_rle_code,
                                        	p_cro_code         => p_cro_code,
                                        	p_intent          => p_intent,
                                        	p_id1             => p_id1,
                                        	p_id2             => p_id2);

	RETURN l_party_name;

END get_party_contact_name;



PROCEDURE get_party_lov_sql (p_role_code IN VARCHAR2
                            ,p_intent IN VARCHAR2
                            ,x_jtot_object_code OUT  NOCOPY VARCHAR2
                            ,x_lov_sql OUT  NOCOPY VARCHAR2)
AS

BEGIN

  Okl_Vp_Jtf_Party_Name_Pvt.get_party_lov_sql(p_role_code,
                              p_intent,
                              x_jtot_object_code,
                              x_lov_sql);

END get_party_lov_sql;


PROCEDURE get_party_contact_lov_sql (p_rle_code IN VARCHAR2
                            ,p_cro_code     IN VARCHAR2
                            ,p_intent IN VARCHAR2
                            ,x_jtot_object_code OUT  NOCOPY VARCHAR2
                            ,x_lov_sql OUT  NOCOPY VARCHAR2)
AS

BEGIN

  Okl_Vp_Jtf_Party_Name_Pvt.get_party_contact_lov_sql(p_rle_code => p_rle_code,
                              p_cro_code => p_cro_code,
                              p_intent => p_intent,
                              x_jtot_object_code => x_jtot_object_code,
                              x_lov_sql => x_lov_sql);

END get_party_contact_lov_sql;

END; -- Package Body OKL_VP_JTF_PARTY_NAME_PUB

/
