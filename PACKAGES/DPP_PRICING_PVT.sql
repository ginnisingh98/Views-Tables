--------------------------------------------------------
--  DDL for Package DPP_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_PRICING_PVT" AUTHID CURRENT_USER AS
/* $Header: dppvqpns.pls 120.1.12010000.3 2009/08/25 14:57:56 rvkondur ship $ */
  TYPE dpp_pl_notify_rec_type IS RECORD
  (
   PP_Transaction_No 	VARCHAR2(40),
   Effectivity_Date 	DATE,
   Org_ID 						NUMBER,
   Vendor_ID 					NUMBER,
   Vendor_Site_ID 		NUMBER,
   Vendor_Number 			VARCHAR2(40),
   Vendor_Name 				VARCHAR2(240),
   Vendor_Site_Code 	VARCHAR2(15),
   Operating_Unit 		VARCHAR2(240)
   );

  g_dpp_pl_notify_rec dpp_pl_notify_rec_type;

  TYPE dpp_object_name_tbl_type IS TABLE OF QP_SECU_LIST_HEADERS_V.NAME%TYPE INDEX BY BINARY_INTEGER;

  TYPE dpp_pl_notify_line_rec_type IS RECORD
  (
   Inventory_Item_ID 	NUMBER,
   Item_Number 				VARCHAR2(240),
   object_name_tbl 		DPP_PRICING_PVT.dpp_object_name_tbl_type,
   New_Price 					NUMBER,
   Currency_Code 			VARCHAR2(15)
   );

  g_dpp_pl_notify_line_rec dpp_pl_notify_line_rec_type;
  TYPE dpp_pl_notify_line_tbl_type IS TABLE OF dpp_pl_notify_line_rec_type INDEX BY BINARY_INTEGER;
  g_dpp_pl_notify_line_tbl dpp_pl_notify_line_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name :   Notify_OutboundPricelists
--   Type     :   Private
--   Pre-Req  :		None
--	 Function :		Derives outbound pricelists information for pricing notification
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_NONE
--       p_pl_notify_line_tbl      IN OUT   dpp_pl_notify_line_tbl_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--   ==============================================================================


  PROCEDURE Notify_OutboundPricelists(
                                       p_api_version IN NUMBER
                                       , p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
                                       , p_commit IN VARCHAR2 := FND_API.G_FALSE
                                       , p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_NONE
                                       , x_return_status OUT NOCOPY VARCHAR2
                                       , x_msg_count OUT NOCOPY NUMBER
                                       , x_msg_data OUT NOCOPY VARCHAR2
                                       , p_pl_notify_hdr_rec IN OUT  NOCOPY dpp_pl_notify_rec_type
                                       , p_pl_notify_line_tbl IN OUT  NOCOPY dpp_pl_notify_line_tbl_type
                                       );
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name :   Notify_InboundPricelists
--   Type     :   Private
--   Pre-Req  :		None
--	 Function :		Derives inbound pricelists information for pricing notification
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_NONE
--       p_pl_notify_hdr_rec       IN OUT  dpp_pl_notify_rec_type  Required
--       p_pl_notify_line_tbl      IN OUT  dpp_pl_notify_line_tbl_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--   ==============================================================================


  PROCEDURE Notify_InboundPricelists(
                                      p_api_version IN NUMBER
                                      , p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
                                      , p_commit IN VARCHAR2 := FND_API.G_FALSE
                                      , p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_NONE
                                      , x_return_status OUT NOCOPY VARCHAR2
                                      , x_msg_count OUT NOCOPY NUMBER
                                      , x_msg_data OUT NOCOPY VARCHAR2
                                      , p_pl_notify_hdr_rec IN OUT  NOCOPY dpp_pl_notify_rec_type
                                      , p_pl_notify_line_tbl IN OUT  NOCOPY dpp_pl_notify_line_tbl_type
                                      );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name :   Notify_Promotions
--   Type     :   Private
--   Pre-Req  :		None
--	 Function :		Derives information for promotions notification
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_NONE
--       p_pl_notify_line_tbl            IN OUT  dpp_pl_notify_line_tbl_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--   ==============================================================================


  PROCEDURE Notify_Promotions(
                               p_api_version IN NUMBER
                               , p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
                               , p_commit IN VARCHAR2 := FND_API.G_FALSE
                               , p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_NONE
                               , x_return_status OUT NOCOPY VARCHAR2
                               , x_msg_count OUT NOCOPY NUMBER
                               , x_msg_data OUT NOCOPY VARCHAR2
                               , p_pl_notify_hdr_rec IN OUT  NOCOPY dpp_pl_notify_rec_type
                               , p_pl_notify_line_tbl IN OUT  NOCOPY dpp_pl_notify_line_tbl_type
                               );

END DPP_PRICING_PVT;

/
