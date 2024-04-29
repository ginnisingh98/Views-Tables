--------------------------------------------------------
--  DDL for Package OKL_VP_JTF_PARTY_NAME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_JTF_PARTY_NAME_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCTSS.pls 120.1 2005/09/08 12:48:41 sjalasut noship $ */
SUBTYPE party_tab_type  IS OKL_VP_JTF_PARTY_NAME_PVT.party_tab_type;

--Start of Comments
--API Name    : Get_Party
--Description : Fetches all parties attahced to a contract or line in a table
--End of Comments
PROCEDURE Get_Party (p_api_version         IN	NUMBER,
                     p_init_msg_list	  IN	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                     x_return_status	  OUT NOCOPY	VARCHAR2,
                     x_msg_count	        OUT NOCOPY	NUMBER,
                     x_msg_data	        OUT NOCOPY	VARCHAR2,
                     p_chr_id		IN  VARCHAR2,
                     p_cle_id      IN  VARCHAR2,
                     p_role_code   IN  OKC_K_PARTY_ROLES_V.rle_code%TYPE,
                     p_intent      IN  VARCHAR2 DEFAULT 'S',
                     x_party_tab   OUT NOCOPY party_tab_type);
--Start of Comments
--Procedure     : Get_Party
--Description   : Fetches Name, Description of a Party role for a given
--                object1_id1 and object2_id2
--End of comments
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
                     x_description         OUT NOCOPY VARCHAR2);

PROCEDURE get_Contact (p_api_version	IN	NUMBER,
                       p_init_msg_list	IN	VARCHAR2 DEFAULT OKC_API.G_FALSE,
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
                            ,p_cro_code     IN VARCHAR2
                            ,p_intent IN VARCHAR2
                            ,x_jtot_object_code OUT NOCOPY VARCHAR2
                            ,x_lov_sql OUT NOCOPY VARCHAR2);

END; -- Package Specification OKL_VP_JTF_PARTY_NAME_PUB

 

/
