--------------------------------------------------------
--  DDL for Package PV_K_REL_OBJS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_K_REL_OBJS_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvkros.pls 115.1 2002/12/10 20:55:12 ktsao ship $ */


  TYPE crj_rel_hdr_full_rec_type IS RECORD (
          chr_id                   NUMBER
         ,object1_id1              VARCHAR2(40)
         ,object1_id2              VARCHAR2(200)
         ,jtot_object1_code        VARCHAR2(30)
         ,line_jtot_object1_code   VARCHAR2(30)
         ,rty_code                 VARCHAR2(30));

  PROCEDURE create_k_rel_obj(
    p_api_version_number         IN    NUMBER,
    p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status              OUT   NOCOPY VARCHAR2,
    x_msg_count                  OUT   NOCOPY NUMBER,
    x_msg_data                   OUT   NOCOPY VARCHAR2,
    p_crj_rel_hdr_full_rec	      IN		crj_rel_hdr_full_rec_type,
    x_crj_rel_hdr_full_rec	      OUT NOCOPY   crj_rel_hdr_full_rec_type);

  END PV_K_REL_OBJS_PVT;


 

/
