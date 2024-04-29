--------------------------------------------------------
--  DDL for Package CN_PLANCOPY_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PLANCOPY_UTIL_PVT" AUTHID CURRENT_USER AS
 /*$Header: cnpcutls.pls 120.3 2007/08/07 17:44:55 sbadami noship $*/

PROCEDURE get_unique_name_for_component (
    p_id    IN  NUMBER,
    p_org_id IN NUMBER,
    p_type   IN VARCHAR2,
    p_suffix IN VARCHAR2,
    p_prefix IN VARCHAR2,
    x_name   OUT NOCOPY VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count  OUT NOCOPY NUMBER,
    x_msg_data   OUT NOCOPY VARCHAR2
);


PROCEDURE convert_blob_to_clob
(  p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_exp_imp_id			IN	CN_COPY_REQUESTS_ALL.EXP_IMP_REQUEST_ID%TYPE,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count  OUT NOCOPY NUMBER,
   x_msg_data   OUT NOCOPY VARCHAR2
);

PROCEDURE convert_clob_to_xmltype
(  p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_exp_imp_id			IN	CN_COPY_REQUESTS_ALL.EXP_IMP_REQUEST_ID%TYPE,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count  OUT NOCOPY NUMBER,
   x_msg_data   OUT NOCOPY VARCHAR2
);

PROCEDURE convert_blob_to_xmltype
(  p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_exp_imp_id			IN	CN_COPY_REQUESTS_ALL.EXP_IMP_REQUEST_ID%TYPE,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count  OUT NOCOPY NUMBER,
   x_msg_data   OUT NOCOPY VARCHAR2
);


FUNCTION  check_name_length (p_name VARCHAR2, p_org_id NUMBER,p_type varchar2,p_prefix varchar2)
  RETURN VARCHAR2;

END CN_PLANCOPY_UTIL_PVT;

/
