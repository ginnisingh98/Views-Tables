--------------------------------------------------------
--  DDL for Package OKE_VERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_VERSION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKEVVERS.pls 115.5 2002/11/20 20:44:41 who ship $ */
PROCEDURE version_contract
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
,  x_msg_count              OUT   NOCOPY NUMBER
,  x_msg_data               OUT   NOCOPY VARCHAR2
,  x_return_status          OUT   NOCOPY VARCHAR2
,  p_chr_id                 IN    NUMBER
,  p_chg_request_id	    IN    NUMBER
,  p_version_reason_code    IN    VARCHAR2
,  x_prev_vers              OUT   NOCOPY NUMBER
,  x_new_vers               OUT   NOCOPY NUMBER
);


PROCEDURE restore_contract_version
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
,  x_msg_count              OUT   NOCOPY NUMBER
,  x_msg_data               OUT   NOCOPY VARCHAR2
,  x_return_status          OUT   NOCOPY VARCHAR2
,  p_chr_id                 IN    NUMBER
,  p_rstr_from_ver          IN    NUMBER
,  p_chg_request_id         IN    NUMBER
,  p_version_reason_code    IN    VARCHAR2
,  x_new_vers               OUT   NOCOPY NUMBER
);

END oke_version_pvt;

 

/
