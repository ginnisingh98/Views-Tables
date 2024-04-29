--------------------------------------------------------
--  DDL for Package FEM_ENGINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_ENGINES_PKG" AUTHID CURRENT_USER AS
-- $Header: fem_engs_spec.pls 120.1 2005/06/22 15:00:55 appldev ship $

/***************************************************************************
                    Copyright (c) 2003 Oracle Corporation
                           Redwood Shores, CA, USA
                             All rights reserved.
 ***************************************************************************
  FILENAME
    fem_engs_spec.pls

  DESCRIPTION
    See fem_engs_body.pls for description

  HISTORY
    Tim Moore   20-Dec-2002  Original script
    Greg Hall   21-Jun-2005  Bug# 4445212: Added procedure Get_PB_Param_Value,
                             for retrieving a process behavior parameter value
                             from the database.
 **************************************************************************/

c_false        CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
c_true         CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;
c_success      CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
c_error        CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
c_unexp        CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
c_api_version  CONSTANT  NUMBER       := 1.0;

PROCEDURE Put_Message
  (p_app_name     IN   VARCHAR2,
   p_msg_name     IN   VARCHAR2,
   p_token1       IN   VARCHAR2 DEFAULT NULL,
   p_value1       IN   VARCHAR2 DEFAULT NULL,
   p_trans1       IN   VARCHAR2 DEFAULT NULL,
   p_token2       IN   VARCHAR2 DEFAULT NULL,
   p_value2       IN   VARCHAR2 DEFAULT NULL,
   p_trans2       IN   VARCHAR2 DEFAULT NULL,
   p_token3       IN   VARCHAR2 DEFAULT NULL,
   p_value3       IN   VARCHAR2 DEFAULT NULL,
   p_trans3       IN   VARCHAR2 DEFAULT NULL,
   p_token4       IN   VARCHAR2 DEFAULT NULL,
   p_value4       IN   VARCHAR2 DEFAULT NULL,
   p_trans4       IN   VARCHAR2 DEFAULT NULL,
   p_token5       IN   VARCHAR2 DEFAULT NULL,
   p_value5       IN   VARCHAR2 DEFAULT NULL,
   p_trans5       IN   VARCHAR2 DEFAULT NULL,
   p_token6       IN   VARCHAR2 DEFAULT NULL,
   p_value6       IN   VARCHAR2 DEFAULT NULL,
   p_trans6       IN   VARCHAR2 DEFAULT NULL,
   p_token7       IN   VARCHAR2 DEFAULT NULL,
   p_value7       IN   VARCHAR2 DEFAULT NULL,
   p_trans7       IN   VARCHAR2 DEFAULT NULL,
   p_token8       IN   VARCHAR2 DEFAULT NULL,
   p_value8       IN   VARCHAR2 DEFAULT NULL,
   p_trans8       IN   VARCHAR2 DEFAULT NULL,
   p_token9       IN   VARCHAR2 DEFAULT NULL,
   p_value9       IN   VARCHAR2 DEFAULT NULL,
   p_trans9       IN   VARCHAR2 DEFAULT NULL);

PROCEDURE Tech_Message
   (p_severity     IN   NUMBER,
    p_module       IN   VARCHAR2,
    p_msg_text     IN   VARCHAR2 DEFAULT NULL,
    p_app_name     IN   VARCHAR2 DEFAULT NULL,
    p_msg_name     IN   VARCHAR2 DEFAULT NULL,
    p_token1       IN   VARCHAR2 DEFAULT NULL,
    p_value1       IN   VARCHAR2 DEFAULT NULL,
    p_trans1       IN   VARCHAR2 DEFAULT NULL,
    p_token2       IN   VARCHAR2 DEFAULT NULL,
    p_value2       IN   VARCHAR2 DEFAULT NULL,
    p_trans2       IN   VARCHAR2 DEFAULT NULL,
    p_token3       IN   VARCHAR2 DEFAULT NULL,
    p_value3       IN   VARCHAR2 DEFAULT NULL,
    p_trans3       IN   VARCHAR2 DEFAULT NULL,
    p_token4       IN   VARCHAR2 DEFAULT NULL,
    p_value4       IN   VARCHAR2 DEFAULT NULL,
    p_trans4       IN   VARCHAR2 DEFAULT NULL,
    p_token5       IN   VARCHAR2 DEFAULT NULL,
    p_value5       IN   VARCHAR2 DEFAULT NULL,
    p_trans5       IN   VARCHAR2 DEFAULT NULL,
    p_token6       IN   VARCHAR2 DEFAULT NULL,
    p_value6       IN   VARCHAR2 DEFAULT NULL,
    p_trans6       IN   VARCHAR2 DEFAULT NULL,
    p_token7       IN   VARCHAR2 DEFAULT NULL,
    p_value7       IN   VARCHAR2 DEFAULT NULL,
    p_trans7       IN   VARCHAR2 DEFAULT NULL,
    p_token8       IN   VARCHAR2 DEFAULT NULL,
    p_value8       IN   VARCHAR2 DEFAULT NULL,
    p_trans8       IN   VARCHAR2 DEFAULT NULL,
    p_token9       IN   VARCHAR2 DEFAULT NULL,
    p_value9       IN   VARCHAR2 DEFAULT NULL,
    p_trans9       IN   VARCHAR2 DEFAULT NULL);

PROCEDURE User_Message
   (p_msg_text     IN   VARCHAR2 DEFAULT NULL,
    p_app_name     IN   VARCHAR2 DEFAULT NULL,
    p_msg_name     IN   VARCHAR2 DEFAULT NULL,
    p_token1       IN   VARCHAR2 DEFAULT NULL,
    p_value1       IN   VARCHAR2 DEFAULT NULL,
    p_trans1       IN   VARCHAR2 DEFAULT NULL,
    p_token2       IN   VARCHAR2 DEFAULT NULL,
    p_value2       IN   VARCHAR2 DEFAULT NULL,
    p_trans2       IN   VARCHAR2 DEFAULT NULL,
    p_token3       IN   VARCHAR2 DEFAULT NULL,
    p_value3       IN   VARCHAR2 DEFAULT NULL,
    p_trans3       IN   VARCHAR2 DEFAULT NULL,
    p_token4       IN   VARCHAR2 DEFAULT NULL,
    p_value4       IN   VARCHAR2 DEFAULT NULL,
    p_trans4       IN   VARCHAR2 DEFAULT NULL,
    p_token5       IN   VARCHAR2 DEFAULT NULL,
    p_value5       IN   VARCHAR2 DEFAULT NULL,
    p_trans5       IN   VARCHAR2 DEFAULT NULL,
    p_token6       IN   VARCHAR2 DEFAULT NULL,
    p_value6       IN   VARCHAR2 DEFAULT NULL,
    p_trans6       IN   VARCHAR2 DEFAULT NULL,
    p_token7       IN   VARCHAR2 DEFAULT NULL,
    p_value7       IN   VARCHAR2 DEFAULT NULL,
    p_trans7       IN   VARCHAR2 DEFAULT NULL,
    p_token8       IN   VARCHAR2 DEFAULT NULL,
    p_value8       IN   VARCHAR2 DEFAULT NULL,
    p_trans8       IN   VARCHAR2 DEFAULT NULL,
    p_token9       IN   VARCHAR2 DEFAULT NULL,
    p_value9       IN   VARCHAR2 DEFAULT NULL,
    p_trans9       IN   VARCHAR2 DEFAULT NULL);

PROCEDURE Get_PB_Param_Value
  (p_api_version        IN         NUMBER     DEFAULT c_api_version,
   p_init_msg_list      IN         VARCHAR2   DEFAULT c_false,
   p_commit             IN         VARCHAR2   DEFAULT c_false,
   p_encoded            IN         VARCHAR2   DEFAULT c_true,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_parameter_name     IN         VARCHAR2,
   p_object_type_code   IN         VARCHAR2,
   p_step_name          IN         VARCHAR2,
   p_object_id          IN         NUMBER,
   x_pb_param_data_type OUT NOCOPY VARCHAR2,
   x_pb_param_value     OUT NOCOPY VARCHAR2);


END FEM_Engines_Pkg;

 

/
