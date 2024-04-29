--------------------------------------------------------
--  DDL for Package JTF_LOG_TO_PHY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_LOG_TO_PHY_PVT" AUTHID CURRENT_USER AS
/* $Header: JTFVDPOS.pls 120.2 2005/10/25 05:07:02 psanyal ship $ */

  G_API_VERSION CONSTANT NUMBER := 1.0;

  PROCEDURE get_obj_by_id(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */ NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    p_logicalid         IN jtf_dsp_obj_lgl_ctnt.item_id%TYPE,
    p_siteid            IN jtf_dsp_lgl_phys_map.msite_id%TYPE,
    p_langcode          IN jtf_dsp_lgl_phys_map.language_code%TYPE,
    x_filename          OUT NOCOPY /* file.sql.39 change */ jtf_amv_attachments.file_name%TYPE,
    x_description       OUT NOCOPY /* file.sql.39 change */ jtf_amv_items_vl.description%TYPE,
    x_fileid            OUT NOCOPY /* file.sql.39 change */ jtf_amv_attachments.file_id%TYPE);

  PROCEDURE get_obj_by_name(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */ NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    p_access_name       IN jtf_amv_items_vl.access_name%TYPE,
    p_siteid            IN jtf_dsp_lgl_phys_map.msite_id%TYPE,
    p_langcode          IN jtf_dsp_lgl_phys_map.language_code%TYPE,
    x_filename          OUT NOCOPY /* file.sql.39 change */ jtf_amv_attachments.file_name%TYPE,
    x_description       OUT NOCOPY /* file.sql.39 change */ jtf_amv_items_vl.description%TYPE,
    x_fileid            OUT NOCOPY /* file.sql.39 change */ jtf_amv_attachments.file_id%TYPE);

END JTF_LOG_TO_PHY_PVT;

 

/
