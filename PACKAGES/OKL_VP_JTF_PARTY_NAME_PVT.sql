--------------------------------------------------------
--  DDL for Package OKL_VP_JTF_PARTY_NAME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_JTF_PARTY_NAME_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCTSS.pls 120.1 2005/09/08 12:44:58 sjalasut noship $ */
TYPE party_rec_type is record (rle_code    OKC_K_PARTY_ROLES_V.RLE_CODE%TYPE := OKC_API.G_MISS_CHAR,
                               id1         OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
                               id2         OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
                               name        VARCHAR2(250) := OKC_API.G_MISS_CHAR,
                               description VARCHAR2(250) := OKC_API.G_MISS_CHAR,
                               object_code VARCHAR2(30)  := OKC_API.G_MISS_CHAR);
TYPE party_tab_type is table of party_rec_type INDEX BY BINARY_INTEGER;
TYPE rle_code_rec_type is record (scs_code OKC_SUBCLASS_ROLES.SCS_CODE%TYPE := OKC_API.G_MISS_CHAR,
                                  rle_code OKC_SUBCLASS_ROLES.RLE_CODE%TYPE := OKC_API.G_MISS_CHAR);
TYPE rle_code_tbl_type is table of rle_code_rec_type INDEX BY BINARY_INTEGER;

--Start of Comments
--API Name    : Get_Party
--Description : Fetches all parties attahced to a contract or line in a table
--End of Comments
Procedure Get_Party (p_api_version         IN	NUMBER,
                     p_init_msg_list	  IN	VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	  OUT NOCOPY	VARCHAR2,
                     x_msg_count	        OUT NOCOPY	NUMBER,
                     x_msg_data	        OUT NOCOPY	VARCHAR2,
                     p_chr_id		IN  VARCHAR2,
                     p_cle_id      IN  VARCHAR2,
                     p_role_code   IN  OKC_K_PARTY_ROLES_V.rle_code%Type,
                     p_intent      IN  VARCHAR2 default 'S',
                     x_party_tab   OUT NOCOPY party_tab_type);
--Start of Comments
--Procedure     : Get_Party
--Description   : Fetches Name, Description of a Party role for a given
--                object1_id1 and object2_id2
--End of comments
Procedure Get_Party (p_api_version         IN	NUMBER,
                     p_init_msg_list	  IN	VARCHAR2 default OKC_API.G_FALSE,
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
                     x_description         OUT NOCOPY VARCHAR2);
Procedure Get_SubClass_Def_Roles
          (p_scs_code       IN  OKC_SUBCLASSES_V.CODE%TYPE,
           x_rle_code_tbl   OUT NOCOPY rle_code_tbl_type);
Procedure Get_Contract_Def_Roles
          (p_chr_id       IN  VARCHAR2,
           x_rle_code_tbl     OUT NOCOPY rle_code_tbl_type);

--Start of Comments
--Procedure   : Get contact
--Description : Returns the SQL string for LOV of a contact
--End of Comments
TYPE contact_rec_type is record (cro_code    OKC_CONTACTS_V.cro_code%TYPE := OKC_API.G_MISS_CHAR,
                                 id1         OKC_CONTACTS_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
                                 id2         OKC_CONTACTS_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
                                 name        VARCHAR2(250) := OKC_API.G_MISS_CHAR,
                                 description VARCHAR2(250) := OKC_API.G_MISS_CHAR,
                                 object_code VARCHAR2(30)  := OKC_API.G_MISS_CHAR);
TYPE contact_tab_type is table of contact_rec_type INDEX BY BINARY_INTEGER;
Procedure Get_Contact(p_api_version         IN	NUMBER,
                      p_init_msg_list	  IN	VARCHAR2 default OKC_API.G_FALSE,
                      x_return_status	  OUT NOCOPY	VARCHAR2,
                      x_msg_count	        OUT NOCOPY	NUMBER,
                      x_msg_data	        OUT NOCOPY	VARCHAR2,
                      p_rle_code            IN  VARCHAR2,
                      p_cro_code            IN  VARCHAR2,
                      p_intent              IN  VARCHAR2,
                      p_id1                 IN  VARCHAR2,
                      p_id2                 IN  VARCHAR2,
                      x_id1                 OUT NOCOPY VARCHAR2,
                      x_id2                 OUT NOCOPY VARCHAR2,
                      x_name                OUT NOCOPY VARCHAR2,
                      x_description         OUT NOCOPY VARCHAR2);

FUNCTION get_party_name (p_role_code IN VARCHAR2
                        ,p_intent IN VARCHAR2
                        ,p_id1 IN VARCHAR2
                        ,p_id2 IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_party_contact_name (p_rle_code IN VARCHAR2
                        	,p_cro_code IN VARCHAR2
                        	,p_intent IN VARCHAR2
                        	,p_id1 IN VARCHAR2
                        	,p_id2 IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE get_party_lov_sql (p_role_code IN VARCHAR2
                            ,p_intent IN VARCHAR2
                            ,x_jtot_object_code OUT NOCOPY VARCHAR2
                            ,x_lov_sql OUT NOCOPY VARCHAR2);

PROCEDURE get_party_contact_lov_sql (p_rle_code IN VARCHAR2
                            ,p_cro_code IN VARCHAR2
                            ,p_intent IN VARCHAR2
                            ,x_jtot_object_code OUT NOCOPY VARCHAR2
                            ,x_lov_sql OUT NOCOPY VARCHAR2);

END; -- Package Specification OKL_VP_JTF_PARTY_NAME_PVT

 

/
