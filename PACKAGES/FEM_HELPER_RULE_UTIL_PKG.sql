--------------------------------------------------------
--  DDL for Package FEM_HELPER_RULE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_HELPER_RULE_UTIL_PKG" AUTHID CURRENT_USER as
--$Header: fem_helper_rule_utl.pls 120.2 2008/02/20 06:58:48 jcliving noship $

c_false            CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
c_true             CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;
c_success          CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
c_error            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
c_unexp            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
c_api_version      CONSTANT  NUMBER       := 1.0;



PROCEDURE register_helper_rule (
   p_rule_obj_def_id         IN NUMBER,
   p_helper_obj_def_id       IN NUMBER,
   p_helper_object_type_code IN VARCHAR2,
   p_api_version             IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list           IN VARCHAR2   DEFAULT c_false,
   p_commit                  IN VARCHAR2   DEFAULT c_false,
   p_encoded                 IN VARCHAR2   DEFAULT c_true,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2);

PROCEDURE get_helper_rule (
   p_rule_obj_def_id         IN NUMBER,
   p_helper_object_type_code IN VARCHAR2,
   p_api_version             IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list           IN VARCHAR2   DEFAULT c_false,
   p_commit                  IN VARCHAR2   DEFAULT c_false,
   p_encoded                 IN VARCHAR2   DEFAULT c_true,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,
   x_helper_obj_def_id       OUT NOCOPY NUMBER   );



END fem_helper_rule_util_pkg;

/
