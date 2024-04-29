--------------------------------------------------------
--  DDL for Package FEM_MAPPING_PREVIEW_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_MAPPING_PREVIEW_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_mapping_preview_util_pkg.pls 120.1 2008/02/20 07:00:08 jcliving ship $ */

--------------------------------------------------------------------------------
-- PUBLIC CONSTANTS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- PUBLIC SPECIFICATIONS
--------------------------------------------------------------------------------

PROCEDURE Remove_Results(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
  p_commit              IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
  p_encoded             IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_preview_obj_def_id  IN  NUMBER);

PROCEDURE Pre_Process(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
  p_commit              IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
  p_encoded             IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_preview_obj_def_id  IN  NUMBER,
  p_request_id          IN  NUMBER);

PROCEDURE Post_Process(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
  p_commit              IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
  p_encoded             IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_preview_obj_def_id  IN  NUMBER,
  p_request_id          IN  NUMBER);


END FEM_MAPPING_PREVIEW_UTIL_PKG;

/
