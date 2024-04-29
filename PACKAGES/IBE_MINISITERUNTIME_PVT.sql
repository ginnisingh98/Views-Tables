--------------------------------------------------------
--  DDL for Package IBE_MINISITERUNTIME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_MINISITERUNTIME_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVMSRS.pls 120.2.12010000.3 2014/07/14 11:07:18 kdosapat ship $ */

  -- HISTORY
  --   12/12/02           SCHAK         Modified for NOCOPY (Bug # 2691704) Changes.
  --   07/20/02           JQU           Added Get_Quote_Details procedure
  --   01/16/09  scnagara bug 7676477, Added Get_Msite_Excluded_Items and Get_Msite_Excluded_Sections
  --   07/14/14  kdosapat Bug 19064720 - UPGRADED ITEMS ARE SHOWN AS EXCLUDED FROM THE MINISITE IN LOGGING DETAIL
  -- *********************************************************************************

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
TYPE pm_cc_sm_cur_type IS REF CURSOR;
TYPE ship_method_cur_type IS REF CURSOR;
TYPE payment_method_cur_type IS REF CURSOR;
TYPE quote_detail_cur_type IS REF CURSOR;

PROCEDURE Get_Msite_Excluded_Items    -- bug 7676477, scnagara
 	   (
 	    p_api_version         IN NUMBER,
 	    p_msite_id            IN NUMBER,
 	    p_access_name         IN VARCHAR2,
 	    x_item_ids            OUT NOCOPY JTF_NUMBER_TABLE,
 	    x_return_status       OUT NOCOPY VARCHAR2,
 	    x_msg_count           OUT NOCOPY NUMBER,
 	    x_msg_data            OUT NOCOPY VARCHAR2
 	   );
-- overloaded Get_Msite_Excluded_Items with extra input parameter p_org_id for bug 19064720 fix
PROCEDURE Get_Msite_Excluded_Items    -- bug 7676477, scnagara
 	   (
 	    p_api_version         IN NUMBER,
 	    p_msite_id            IN NUMBER,
 	    p_access_name         IN VARCHAR2,
      p_org_id              IN NUMBER,   -- bug 19064720
 	    x_item_ids            OUT NOCOPY JTF_NUMBER_TABLE,
 	    x_return_status       OUT NOCOPY VARCHAR2,
 	    x_msg_count           OUT NOCOPY NUMBER,
 	    x_msg_data            OUT NOCOPY VARCHAR2
 	   );
 PROCEDURE Get_Msite_Excluded_Sections		-- bug 7676477, scnagara
 	   (
 	    p_api_version         IN NUMBER,
 	    p_msite_id            IN NUMBER,
 	    p_access_name         IN VARCHAR2,
	    x_section_ids         OUT NOCOPY JTF_NUMBER_TABLE,
 	    x_return_status       OUT NOCOPY VARCHAR2,
 	    x_msg_count           OUT NOCOPY NUMBER,
 	    x_msg_data            OUT NOCOPY VARCHAR2
 	   );

PROCEDURE Get_Msite_Details
  (
   p_api_version         IN NUMBER,
   p_msite_id            IN NUMBER,
   p_access_name	 IN VARCHAR2,
   x_master_msite_id     OUT NOCOPY NUMBER,
   x_minisite_cur        OUT NOCOPY minisite_cur_type,
   x_lang_cur            OUT NOCOPY lang_cur_type,
   x_currency_cur        OUT NOCOPY currency_cur_type,
   x_sections_cur        OUT NOCOPY sections_cur_type,
   x_items_cur           OUT NOCOPY items_cur_type,
   x_name_cur            OUT NOCOPY name_cur_type ,
   x_msite_resps_cur     OUT NOCOPY msite_resp_cur_type ,
   x_party_access_cur    OUT NOCOPY msite_prty_access_cur_type,
   x_pm_cc_sm_cur        OUT NOCOPY pm_cc_sm_cur_type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
  );

PROCEDURE Get_Quote_Details
  (
   p_api_version         IN NUMBER,
   p_quote_id            IN NUMBER,
   x_ship_method_cur     OUT NOCOPY ship_method_cur_type,
   x_payment_method_cur  OUT NOCOPY payment_method_cur_type,
   x_quote_detail_cur    OUT NOCOPY quote_detail_cur_type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
  );

PROCEDURE Load_Msite_List_Details
  (
   p_api_version         IN  NUMBER,
   p_msite_ids           IN  JTF_NUMBER_TABLE,
   x_msite_ids           OUT NOCOPY JTF_NUMBER_TABLE,
   x_master_msite_id     OUT NOCOPY NUMBER,
   x_minisite_cur        OUT NOCOPY minisite_cur_type,
   x_name_cur            OUT NOCOPY name_cur_type,
   x_lang_cur            OUT NOCOPY lang_cur_type,
   x_currency_cur        OUT NOCOPY currency_cur_type,
   x_msite_resps_cur     OUT NOCOPY msite_resp_cur_type,
   x_party_access_cur    OUT NOCOPY msite_prty_access_cur_type,
   x_section_msite_ids   OUT NOCOPY JTF_NUMBER_TABLE,
   x_section_ids         OUT NOCOPY JTF_NUMBER_TABLE,
   x_item_msite_ids      OUT NOCOPY JTF_NUMBER_TABLE,
   x_item_ids            OUT NOCOPY JTF_NUMBER_TABLE,
   x_pm_cc_sm_cur        OUT NOCOPY pm_cc_sm_cur_type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
  );

END IBE_MinisiteRuntime_PVT;

/
