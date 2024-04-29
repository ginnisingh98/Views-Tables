--------------------------------------------------------
--  DDL for Package OKL_JTOT_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_JTOT_EXTRACT" AUTHID CURRENT_USER as
/* $Header: OKLRJEXS.pls 115.7 2003/09/23 14:21:19 kthiruva noship $ */
--------------------------------------------------------------------------------
--Global Variables
--------------------------------------------------------------------------------
G_PKG_NAME     CONSTANT VARCHAR2(200) := 'OKL_JTOT_EXTRACT';
G_API_TYPE     CONSTANT VARCHAR2(200) := '_PVT';
G_APP_NAME     CONSTANT VARCHAR2(200) := 'OKL';

TYPE party_rec_type is record (rle_code    OKC_K_PARTY_ROLES_V.RLE_CODE%TYPE := OKL_API.G_MISS_CHAR,
                               id1         OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE := OKL_API.G_MISS_CHAR,
                               id2         OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE := OKL_API.G_MISS_CHAR,
                               name        VARCHAR2(250) := OKL_API.G_MISS_CHAR,
                               description VARCHAR2(250) := OKL_API.G_MISS_CHAR,
                               object_code VARCHAR2(30)  := OKL_API.G_MISS_CHAR);
TYPE party_tab_type is table of party_rec_type INDEX BY BINARY_INTEGER;
TYPE rle_code_rec_type is record (scs_code OKC_SUBCLASS_ROLES.SCS_CODE%TYPE := OKL_API.G_MISS_CHAR,
                                  rle_code OKC_SUBCLASS_ROLES.RLE_CODE%TYPE := OKL_API.G_MISS_CHAR);
TYPE rle_code_tbl_type is table of rle_code_rec_type INDEX BY BINARY_INTEGER;

--Start of Comments
--API Name    : Get_Party
--Description : Fetches all parties attahced to a contract or line in a table
--End of Comments
Procedure Get_Party (
          p_api_version        IN NUMBER,
          p_init_msg_list      IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
          x_return_status      OUT NOCOPY VARCHAR2,
          x_msg_count          OUT NOCOPY NUMBER,
          x_msg_data           OUT NOCOPY VARCHAR2,
          p_chr_id		       IN  VARCHAR2,
          p_cle_id             IN  VARCHAR2,
          p_role_code          IN  OKC_K_PARTY_ROLES_V.rle_code%Type,
          p_intent             IN  VARCHAR2 default 'S',
          x_party_tab          OUT NOCOPY party_tab_type
          );
--Start of Comments
--Procedure     : Get_Party
--Description   : Fetches Name, Description of a Party role for a given
--                object1_id1 and object2_id2
--End of comments
Procedure Get_Party (p_api_version        IN NUMBER,
                     p_init_msg_list      IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
                     x_return_status      OUT NOCOPY VARCHAR2,
                     x_msg_count          OUT NOCOPY NUMBER,
                     x_msg_data           OUT NOCOPY VARCHAR2,
                     p_role_code          IN  VARCHAR2,
                     p_intent             IN  VARCHAR2,
                     p_id1                IN  VARCHAR2,
                     p_id2                IN  VARCHAR2,
                     x_id1                OUT NOCOPY VARCHAR2,
                     x_id2                OUT NOCOPY VARCHAR2,
                     x_name               OUT NOCOPY VARCHAR2,
                     x_description        OUT NOCOPY VARCHAR2);
--Start of Comments
--Procedure   : Get_Subclass_Def_Roles
--Description : fetches Party Roles for a Subclass
--End of Comments
Procedure Get_SubClass_Def_Roles
          (p_api_version        IN NUMBER,
           p_init_msg_list      IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status      OUT NOCOPY VARCHAR2,
           x_msg_count          OUT NOCOPY NUMBER,
           x_msg_data           OUT NOCOPY VARCHAR2,
           p_scs_code           IN  OKC_SUBCLASSES_V.CODE%TYPE,
           x_rle_code_tbl       OUT NOCOPY rle_code_tbl_type);
--Start of Comments
--Procedure   : Get_Contract_Def
--Description : fetches Party Roles for a contract
--End of Comments
Procedure Get_Contract_Def_Roles
          (p_api_version        IN NUMBER,
           p_init_msg_list      IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status      OUT NOCOPY VARCHAR2,
           x_msg_count          OUT NOCOPY NUMBER,
           x_msg_data           OUT NOCOPY VARCHAR2,
           p_chr_id             IN  VARCHAR2,
           x_rle_code_tbl       OUT NOCOPY rle_code_tbl_type);
--Start of Comments
--Procedure   : Get_Contract
--Description : fetches Contact Role Clause for a contract
--End of Comments
Procedure Get_Contact(
          p_api_version        IN NUMBER,
          p_init_msg_list      IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
          x_return_status      OUT NOCOPY VARCHAR2,
          x_msg_count          OUT NOCOPY NUMBER,
          x_msg_data           OUT NOCOPY VARCHAR2,
          p_role_code           IN  VARCHAR2,
          p_contact_code        IN  VARCHAR2,
          p_intent              IN  VARCHAR2 DEFAULT 'S',
          p_id1                 IN  VARCHAR2,
          p_id2                 IN  VARCHAR2,
          p_name                IN  VARCHAR2,
          x_select_clause       OUT NOCOPY VARCHAR2,
          x_from_clause         OUT NOCOPY VARCHAR2,
          x_where_clause        OUT NOCOPY VARCHAR2,
          x_order_by_clause     OUT NOCOPY VARCHAR2,
          x_object_code         OUT NOCOPY VARCHAR2);
End OKL_JTOT_EXTRACT;

 

/