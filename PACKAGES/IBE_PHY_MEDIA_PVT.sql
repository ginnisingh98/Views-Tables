--------------------------------------------------------
--  DDL for Package IBE_PHY_MEDIA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_PHY_MEDIA_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVDPMS.pls 115.1 2002/12/14 07:53:10 schak ship $ */

  -- HISTORY
  --   12/12/02           SCHAK         Modified for NOCOPY (Bug # 2691704) Changes.
  -- *********************************************************************************

  G_API_VERSION CONSTANT NUMBER := 1.0;

  PROCEDURE get_media(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2,
    p_pid               IN ibe_dsp_obj_lgl_ctnt.object_id%TYPE,
    p_catgid            IN ibe_dsp_obj_lgl_ctnt.object_id%TYPE,
    p_dcname            IN ibe_dsp_context_b.access_name%TYPE,
    p_siteid            IN ibe_dsp_lgl_phys_map.msite_id%TYPE,
    p_langcode          IN ibe_dsp_lgl_phys_map.language_code%TYPE,
    x_filename          OUT NOCOPY jtf_amv_attachments.file_name%TYPE,
    x_description       OUT NOCOPY jtf_amv_items_vl.description%TYPE,

    -- added by Guigen Zhang 04-04-2001 16:46
    x_fileid            OUT NOCOPY jtf_amv_attachments.file_id%TYPE);

END IBE_PHY_MEDIA_PVT;

 

/
