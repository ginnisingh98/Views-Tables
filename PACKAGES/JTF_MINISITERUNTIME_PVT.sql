--------------------------------------------------------
--  DDL for Package JTF_MINISITERUNTIME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_MINISITERUNTIME_PVT" AUTHID CURRENT_USER AS
/* $Header: JTFVMSRS.pls 115.7 2004/07/09 18:51:58 applrt ship $ */
g_pkg_name   CONSTANT VARCHAR2(30):='JTF_MinisiteRuntime_PVT_TMP';
g_api_version CONSTANT NUMBER       := 1.0;

TYPE lang_cur_type IS REF CURSOR;
TYPE currency_cur_type IS REF CURSOR;
TYPE sections_cur_type IS REF CURSOR;
TYPE items_cur_type IS REF CURSOR;
TYPE minisite_cur_type IS REF CURSOR;
TYPE attr_cur_type IS REF CURSOR;
TYPE name_cur_type IS REF CURSOR;
TYPE master_msite_cur_type IS REF CURSOR;
TYPE msite_resp_cur_type IS REF CURSOR;
TYPE msite_prty_access_cur_type IS REF CURSOR;

PROCEDURE Get_Msite_Details
  (
   p_api_version         IN NUMBER,
   p_msite_id            IN NUMBER,
   p_access_name	 IN VARCHAR2,
   x_master_msite_id     OUT NUMBER,
   x_minisite_cur        OUT minisite_cur_type,
   x_lang_cur            OUT lang_cur_type,
   x_currency_cur        OUT currency_cur_type,
   x_sections_cur        OUT sections_cur_type,
   x_items_cur           OUT items_cur_type,
   x_name_cur            OUT name_cur_type ,
   x_msite_resps_cur     OUT msite_resp_cur_type ,
   x_party_access_cur    OUT msite_prty_access_cur_type,
   x_return_status       OUT VARCHAR2,
   x_msg_count           OUT NUMBER,
   x_msg_data            OUT VARCHAR2
  );

PROCEDURE Load_Msite_List_Details
  (
   p_api_version         IN  NUMBER,
   p_msite_ids           IN  JTF_NUMBER_TABLE,
   x_msite_ids           OUT JTF_NUMBER_TABLE,
   x_master_msite_id     OUT NUMBER,
   x_minisite_cur        OUT MINISITE_CUR_TYPE,
   x_name_cur            OUT NAME_CUR_TYPE,
   x_lang_cur            OUT LANG_CUR_TYPE,
   x_currency_cur        OUT CURRENCY_CUR_TYPE,
   x_msite_resps_cur     OUT MSITE_RESP_CUR_TYPE,
   x_party_access_cur    OUT MSITE_PRTY_ACCESS_CUR_TYPE,
   x_section_msite_ids   OUT JTF_NUMBER_TABLE,
   x_section_ids         OUT JTF_NUMBER_TABLE,
   x_item_msite_ids      OUT JTF_NUMBER_TABLE,
   x_item_ids            OUT JTF_NUMBER_TABLE,
   x_return_status       OUT VARCHAR2,
   x_msg_count           OUT NUMBER,
   x_msg_data            OUT VARCHAR2
  );

END JTF_MinisiteRuntime_PVT;

 

/
