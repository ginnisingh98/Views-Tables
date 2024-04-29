--------------------------------------------------------
--  DDL for Package OKL_JTOT_CONTACT_EXTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_JTOT_CONTACT_EXTRACT_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPJCXS.pls 115.5 2003/09/24 06:13:55 kthiruva noship $ */
TYPE party_rec_type is record (rle_code    OKC_K_PARTY_ROLES_V.RLE_CODE%TYPE := OKC_API.G_MISS_CHAR,

                               id1         OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
                               id2         OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
                               name        VARCHAR2(250) := OKC_API.G_MISS_CHAR,
                               description VARCHAR2(250) := OKC_API.G_MISS_CHAR,
                               object_code VARCHAR2(30)  := OKC_API.G_MISS_CHAR);
TYPE party_tab_type is table of party_rec_type INDEX BY BINARY_INTEGER;

G_API_TYPE  CONSTANT VARCHAR2(4) := '_PVT';

--Start of Comments
--API Name    : Get_Party
--Description : Fetched the select clause related to a party for a role code and intent
--End of Comments


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


Procedure Get_Contact(p_api_version         IN	NUMBER,
                      p_init_msg_list	  IN	VARCHAR2 default OKC_API.G_FALSE,
                      x_return_status	  OUT NOCOPY	VARCHAR2,
                      x_msg_count	        OUT NOCOPY	NUMBER,
                      x_msg_data	        OUT NOCOPY	VARCHAR2,
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



   -- global variables
  --g_ctsv_rec 			ctsv_rec_type;

  -- public procedure declarations
procedure get_Contact (p_api_version	IN	NUMBER,
                       p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                       x_return_status	OUT NOCOPY	VARCHAR2,
                       x_msg_count	OUT NOCOPY	NUMBER,
                       x_msg_data	OUT NOCOPY	VARCHAR2,
                       p_rle_code       IN VARCHAR2,
                       p_cro_code       IN  VARCHAR2,
                       p_intent         IN  VARCHAR2,
                       p_id1            IN  VARCHAR2,
                       p_id2            IN  VARCHAR2,
                       x_id1            OUT NOCOPY VARCHAR2,
                       x_id2            OUT NOCOPY VARCHAR2,
                       x_name           OUT NOCOPY VARCHAR2,
                       x_description    OUT NOCOPY VARCHAR2);

Procedure Validate_Party (p_api_version     IN	NUMBER,
                     p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	   OUT  NOCOPY	VARCHAR2,
                     x_msg_count	   OUT  NOCOPY	NUMBER,
                     x_msg_data	           OUT  NOCOPY	VARCHAR2,
                     p_chr_id       	   IN	NUMBER,
                     p_cle_id       	   IN	NUMBER,
                     p_cpl_id       	   IN	NUMBER,
                     p_lty_code            IN	VARCHAR2,
                     p_rle_code            IN	VARCHAR2,
                     p_id1            	   IN OUT  NOCOPY VARCHAR2,
                     p_id2                 IN OUT  NOCOPY VARCHAR2,
                     p_name                IN   VARCHAR2,
                     p_object_code         IN   VARCHAR2);


Procedure Delete_Party (p_api_version  IN   NUMBER,
                     p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	   OUT  NOCOPY	VARCHAR2,
                     x_msg_count	   OUT  NOCOPY	NUMBER,
                     x_msg_data	           OUT  NOCOPY	VARCHAR2,
                     p_chr_id       	   IN	NUMBER,
                     p_cpl_id       	   IN	NUMBER
                     );



end OKL_JTOT_CONTACT_EXTRACT_PUB;

 

/
