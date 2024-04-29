--------------------------------------------------------
--  DDL for Package IGS_EN_NSC_FILE_PRNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_NSC_FILE_PRNT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEN89S.pls 115.3 2002/11/29 00:12:46 nsidana noship $ */

PROCEDURE Generate_file(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count         OUT NOCOPY  NUMBER,
  x_msg_data          OUT NOCOPY  VARCHAR2,
  p_obj_type_id       IN   NUMBER,
  p_doc_inst_id       IN   NUMBER,
  p_dirpath           IN   VARCHAR2 ,
  p_file_name         IN   VARCHAR2 ,
  p_form_id           IN   NUMBER ,
  p_debug_mode        IN   VARCHAR2 := FND_API.G_FALSE
);

END IGS_EN_NSC_FILE_PRNT_PKG;

 

/
