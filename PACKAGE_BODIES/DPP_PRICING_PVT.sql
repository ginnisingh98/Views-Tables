--------------------------------------------------------
--  DDL for Package Body DPP_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_PRICING_PVT" AS
/* $Header: dppvqpnb.pls 120.7.12010000.3 2010/04/26 07:09:09 pvaramba ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          DPP_PRICING_PVT
-- Purpose
--					Contains all APIs for Pricing Notifications
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'DPP_PRICING_PVT';

  G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
  G_FILE_NAME     CONSTANT VARCHAR2(14) := 'dppvqpnb.pls';
  g_trunc_sysdate  DATE := trunc(sysdate);

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

  PROCEDURE Notify_OutboundPricelists(
                                       p_api_version IN NUMBER
                                       , p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
                                       , p_commit IN VARCHAR2 := FND_API.G_FALSE
                                       , p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_NONE
                                       , x_return_status OUT NOCOPY VARCHAR2
                                       , x_msg_count OUT NOCOPY NUMBER
                                       , x_msg_data OUT NOCOPY VARCHAR2
                                       , p_pl_notify_hdr_rec IN OUT NOCOPY dpp_pl_notify_rec_type
                                       , p_pl_notify_line_tbl IN OUT NOCOPY dpp_pl_notify_line_tbl_type
                                       )
  IS
  l_api_name CONSTANT VARCHAR2(30) := 'Notify_OutboundPricelists';
  l_api_version CONSTANT NUMBER := 1.0;
  l_full_name CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

  l_result NUMBER;
  l_return_status VARCHAR2(30);
  l_pl_notify_hdr_rec    dpp_pl_notify_rec_type := p_pl_notify_hdr_rec;
  l_pl_notify_line_tbl DPP_PRICING_PVT.dpp_pl_notify_line_tbl_type := p_pl_notify_line_tbl;
  l_pricelist_tbl DPP_PRICING_PVT.dpp_object_name_tbl_type;

  CURSOR get_pricelist_csr(p_inventory_item_id IN NUMBER, p_org_id IN NUMBER)
  IS

  SELECT
        qlh.name Pricelist_Name
  FROM
        qp_secu_list_headers_v qlh,
        qp_list_lines_v qll
  WHERE
				qlh.active_flag = 'Y' AND
				g_trunc_sysdate BETWEEN nvl(qlh.start_date_active, g_trunc_sysdate) AND
				nvl(qlh.end_date_active, g_trunc_sysdate) AND
				qlh.source_system_code = 'QP' AND
				qll.product_id = p_inventory_item_id AND
				qll.list_header_id = qlh.list_header_id AND
				qll.product_attribute_context = 'ITEM' AND
				qll.list_line_type_code = 'PLL' AND
				g_trunc_sysdate BETWEEN nvl(qll.start_date_active, g_trunc_sysdate) AND
				nvl(qll.end_date_active, g_trunc_sysdate) AND
				(qlh.orig_org_id = p_org_id OR NVL(qlh.global_flag,'N') = 'Y');

  CURSOR get_item_number_csr(p_inventory_item_id IN NUMBER)
  IS
  SELECT
			msi.concatenated_segments
  FROM
			mtl_system_items_kfv msi
  WHERE
			inventory_item_id = p_inventory_item_id
		AND ROWNUM = 1;


  CURSOR get_vendor_csr(p_vendor_id IN NUMBER)
  IS
  SELECT
	  vendor_name,
	  segment1 vendor_num
	FROM
	  ap_suppliers
	WHERE
  vendor_id = p_vendor_id;

CURSOR get_vendor_site_csr(p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER, p_org_id IN NUMBER)
	  IS
  SELECT
	  vendor_site_code
	FROM
	  ap_supplier_sites_all
	WHERE
	  vendor_site_id = p_vendor_site_id    and
	  vendor_id = p_vendor_id   and
    org_id = p_org_id;

CURSOR get_ou_csr(p_org_id IN NUMBER)
	  IS
  SELECT
	  name
	FROM
	  hr_operating_units
	WHERE
	  organization_id = p_org_id;

  BEGIN

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;


   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_PROCEDURE, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- API body
--
    IF l_pl_notify_hdr_rec.vendor_id IS NULL THEN
         DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Vendor ID cannot be NULL');
	               FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
					 FND_MESSAGE.set_token('ID', 'Vendor ID');
		       FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
    ELSIF l_pl_notify_hdr_rec.vendor_site_id IS NULL THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Vendor Site ID cannot be NULL');
		       FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
					 FND_MESSAGE.set_token('ID', 'Vendor Site ID');
		       FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
    ELSE
        FOR get_vendor_rec IN get_vendor_csr(p_pl_notify_hdr_rec.vendor_id)
          LOOP

          p_pl_notify_hdr_rec.vendor_name := get_vendor_rec.vendor_name;
          p_pl_notify_hdr_rec.vendor_number := get_vendor_rec.vendor_num;

        END LOOP;

        FOR get_vendor_site_rec IN get_vendor_site_csr(p_pl_notify_hdr_rec.vendor_id, p_pl_notify_hdr_rec.vendor_site_id,
        p_pl_notify_hdr_rec.org_id)
          LOOP

          p_pl_notify_hdr_rec.vendor_site_code := get_vendor_site_rec.vendor_site_code;

        END LOOP;

				FOR get_ou_rec IN get_ou_csr(p_pl_notify_hdr_rec.org_id)
					LOOP

					p_pl_notify_hdr_rec.operating_unit := get_ou_rec.name;

        END LOOP;

    END IF;

      FOR i IN l_pl_notify_line_tbl.FIRST..l_pl_notify_line_tbl.LAST
        LOOP

       IF l_pl_notify_line_tbl(i).inventory_item_id IS NULL THEN
	                  DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Inventory Item ID cannot be NULL');

	 		       FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
	 					 FND_MESSAGE.set_token('ID', 'Inventory Item ID');
	 		       FND_MSG_PUB.add;
	           RAISE FND_API.G_EXC_ERROR;

       ELSE
        OPEN get_pricelist_csr(l_pl_notify_line_tbl(i).inventory_item_id, l_pl_notify_hdr_rec.org_id);
        LOOP
          FETCH get_pricelist_csr BULK COLLECT INTO l_pricelist_tbl;
          EXIT WHEN get_pricelist_csr%NOTFOUND;
        END LOOP;
        CLOSE get_pricelist_csr;

        -- Initializing Nested Table
        IF NOT l_pricelist_tbl.EXISTS(1) THEN
           l_pricelist_tbl(1) := NULL;
        END IF;

        p_pl_notify_line_tbl(i).object_name_tbl := l_pricelist_tbl;

        FOR get_item_number_rec IN get_item_number_csr(l_pl_notify_line_tbl(i).inventory_item_id)
          LOOP

          p_pl_notify_line_tbl(i).item_number := get_item_number_rec.concatenated_segments;

        END LOOP;

       END IF;

      END LOOP;

    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'return status for API =>'||l_return_status);


    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (p_count => x_msg_count,
     p_data => x_msg_data
     );

   x_return_status := l_return_status;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data
                               );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data
                               );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;


    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
			fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
			fnd_message.set_token('ROUTINE', 'DPP_PRICING_PVT.Notify_OutboundPricelists');
			fnd_message.set_token('ERRNO', sqlcode);
			fnd_message.set_token('REASON', sqlerrm);
    END IF;
   -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data
                               );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;


  END Notify_OutboundPricelists;

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
                                      , p_pl_notify_hdr_rec IN OUT NOCOPY dpp_pl_notify_rec_type
                                      , p_pl_notify_line_tbl IN OUT NOCOPY dpp_pl_notify_line_tbl_type
                                      )
  IS
  l_api_name CONSTANT VARCHAR2(30) := 'Notify_InboundPricelists';
  l_api_version CONSTANT NUMBER := 1.0;
  l_full_name CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

  l_result NUMBER;
  l_pl_notify_hdr_rec DPP_PRICING_PVT.dpp_pl_notify_rec_type := p_pl_notify_hdr_rec;
  l_pl_notify_line_tbl DPP_PRICING_PVT.dpp_pl_notify_line_tbl_type := p_pl_notify_line_tbl;
  l_pricelist_tbl DPP_PRICING_PVT.dpp_object_name_tbl_type;

    CURSOR get_pricelist_csr(p_inventory_item_id IN NUMBER, p_vendor_id IN NUMBER,p_vendor_site_id IN NUMBER, p_org_id IN NUMBER)
	  IS
		SELECT	qlh.name Pricelist_Name
		FROM	qp_secu_list_headers_v qlh,
			qp_qualifiers_v qqv,
			qp_list_lines_v qll
		WHERE	qlh.active_flag='Y'
                  and	g_trunc_sysdate between nvl(qlh.start_date_active,g_trunc_sysdate)
                  and	nvl(qlh.end_date_active,g_trunc_sysdate)
                  and	qlh.list_header_id=qqv.list_header_id
                  and	qlh.source_system_code='PO'
                  and	qqv.qualifier_context='PO_SUPPLIER'
                  and	(qualifier_attribute = 'QUALIFIER_ATTRIBUTE1' and qqv.qualifier_attr_value=NVL(p_vendor_id,qqv.qualifier_attr_value))
                  and	qll.product_id = p_inventory_item_id
                  and	qll.list_header_id=qlh.list_header_id
                  and	qll.product_attribute_context='ITEM'
                  and	qll.list_line_type_code='PLL'
                  and	g_trunc_sysdate between nvl(qll.start_date_active,g_trunc_sysdate)
                  and	nvl(qll.end_date_active,g_trunc_sysdate)
                  AND  (qlh.orig_org_id = p_org_id OR NVL(qlh.global_flag,'N') = 'Y')
                UNION
                SELECT	qlh.name Pricelist_Name
		FROM	qp_secu_list_headers_v qlh,
			qp_qualifiers_v qqv,
			qp_list_lines_v qll
		WHERE	qlh.active_flag='Y'
                  and	g_trunc_sysdate between nvl(qlh.start_date_active,g_trunc_sysdate)
                  and	nvl(qlh.end_date_active,g_trunc_sysdate)
                  and	qlh.list_header_id=qqv.list_header_id
                  and	qlh.source_system_code='PO'
                  and	qqv.qualifier_context='PO_SUPPLIER'
                  and    (qualifier_attribute = 'QUALIFIER_ATTRIBUTE2' and qqv.qualifier_attr_value=NVL(p_vendor_site_id,qqv.qualifier_attr_value))             and	qll.product_id = p_inventory_item_id
                  and	qll.list_header_id=qlh.list_header_id
                  and	qll.product_attribute_context='ITEM'
                  and	qll.list_line_type_code='PLL'
                  and	g_trunc_sysdate between nvl(qll.start_date_active,g_trunc_sysdate)
                  and	nvl(qll.end_date_active,g_trunc_sysdate)
                  AND  (qlh.orig_org_id = p_org_id OR NVL(qlh.global_flag,'N') = 'Y');

    CURSOR get_item_number_csr(p_inventory_item_id IN NUMBER)
	  IS
	  SELECT
				msi.concatenated_segments
	  FROM
				mtl_system_items_kfv msi
	  WHERE
				inventory_item_id = p_inventory_item_id
		AND ROWNUM = 1;


  CURSOR get_vendor_csr(p_vendor_id IN NUMBER)
  IS
  SELECT
	  vendor_name,
	  segment1 vendor_num
	FROM
	  ap_suppliers
	WHERE
  vendor_id = p_vendor_id;

CURSOR get_vendor_site_csr(p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER, p_org_id IN NUMBER)
	  IS
  SELECT
	  vendor_site_code
	FROM
	  ap_supplier_sites_all
	WHERE
	  vendor_site_id = p_vendor_site_id    and
	  vendor_id = p_vendor_id   and
    org_id = p_org_id;

CURSOR get_ou_csr(p_org_id IN NUMBER)
	  IS
  SELECT
	  name
	FROM
	  hr_operating_units
	WHERE
	  organization_id = p_org_id;

  BEGIN

-- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;


   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_PROCEDURE, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_full_name || 'start');

-- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

--
-- API body
--
    IF l_pl_notify_hdr_rec.vendor_id IS NULL THEN
           DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Vendor ID cannot be NULL');
		       FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
					 FND_MESSAGE.set_token('ID', 'Vendor ID');
		       FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
    ELSIF l_pl_notify_hdr_rec.vendor_site_id IS NULL THEN
           DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Vendor Site ID cannot be NULL');
		       FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
					 FND_MESSAGE.set_token('ID', 'Vendor Site ID');
		       FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
    ELSE
        FOR get_vendor_rec IN get_vendor_csr(p_pl_notify_hdr_rec.vendor_id)
          LOOP

          p_pl_notify_hdr_rec.vendor_name := get_vendor_rec.vendor_name;
          p_pl_notify_hdr_rec.vendor_number := get_vendor_rec.vendor_num;

        END LOOP;

        FOR get_vendor_site_rec IN get_vendor_site_csr(p_pl_notify_hdr_rec.vendor_id, p_pl_notify_hdr_rec.vendor_site_id,
        p_pl_notify_hdr_rec.org_id)
          LOOP

          p_pl_notify_hdr_rec.vendor_site_code := get_vendor_site_rec.vendor_site_code;

        END LOOP;

				FOR get_ou_rec IN get_ou_csr(p_pl_notify_hdr_rec.org_id)
					LOOP

					p_pl_notify_hdr_rec.operating_unit := get_ou_rec.name;

        END LOOP;

      FOR i IN l_pl_notify_line_tbl.FIRST..l_pl_notify_line_tbl.LAST
        LOOP

       IF l_pl_notify_line_tbl(i).inventory_item_id IS NULL THEN
           DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Inventory Item ID cannot be NULL');
		       FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
					 FND_MESSAGE.set_token('ID', 'Inventory Item ID');
		       FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;

       ELSE

        OPEN get_pricelist_csr(l_pl_notify_line_tbl(i).inventory_item_id, l_pl_notify_hdr_rec.vendor_id,l_pl_notify_hdr_rec.vendor_site_id, l_pl_notify_hdr_rec.org_id);
        LOOP
          FETCH get_pricelist_csr BULK COLLECT INTO l_pricelist_tbl;
          EXIT WHEN get_pricelist_csr%NOTFOUND;
        END LOOP;
        CLOSE get_pricelist_csr;

        -- Initializing Nested Table
				IF NOT l_pricelist_tbl.EXISTS(1) THEN
				   l_pricelist_tbl(1) := NULL;
        END IF;

        p_pl_notify_line_tbl(i).object_name_tbl := l_pricelist_tbl;

        FOR get_item_number_rec IN get_item_number_csr(l_pl_notify_line_tbl(i).inventory_item_id)
          LOOP

          p_pl_notify_line_tbl(i).item_number := get_item_number_rec.concatenated_segments;

        END LOOP;

        END IF;

      END LOOP;

    END IF;

    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'return status for API =>'||x_return_status);

    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_full_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (p_count => x_msg_count,
     p_data => x_msg_data
     );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data
                               );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data
                               );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
			   fnd_message.set_token('ROUTINE', 'DPP_PRICING_PVT.Notify_InboundPricelists');
			   fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;
         DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'Error in notify inbound pricelists: '||SQLERRM);
    END IF;
   -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data
                               );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

  END Notify_InboundPricelists;

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
                               , p_pl_notify_hdr_rec IN OUT NOCOPY dpp_pl_notify_rec_type
                               , p_pl_notify_line_tbl IN OUT NOCOPY dpp_pl_notify_line_tbl_type
                               )
  IS
  l_api_name CONSTANT VARCHAR2(30) := 'Notify_Promotions';
  l_api_version CONSTANT NUMBER := 1.0;
  l_full_name CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

  l_result NUMBER;
  l_count  NUMBER;

  l_pl_notify_hdr_rec DPP_PRICING_PVT.dpp_pl_notify_rec_type := p_pl_notify_hdr_rec;
  l_pl_notify_line_tbl   DPP_PRICING_PVT.dpp_pl_notify_line_tbl_type := p_pl_notify_line_tbl;
  l_offer_tbl            DPP_PRICING_PVT.dpp_object_name_tbl_type;

CURSOR get_offers_csr(p_inventory_item_id IN NUMBER) IS
    SELECT oov.name offer_name
      FROM ozf_offers_v oov,
           qp_modifier_summary_v qmsv
     WHERE qmsv.list_header_id = oov.list_header_id
       AND g_trunc_sysdate between nvl(oov.start_date_active,g_trunc_sysdate)  AND  nvl(oov.end_date_active,g_trunc_sysdate)
       AND g_trunc_sysdate between nvl(qmsv.start_date_active,g_trunc_sysdate) AND  nvl(qmsv.end_date_active,g_trunc_sysdate)
       AND product_attribute_context = 'ITEM'
       AND qmsv.prod_attr_segment_name = 'INVENTORY_ITEM_ID'
       AND qmsv.product_attr_val = to_char(p_inventory_item_id)
       AND oov.active_flag = 'Y'
  GROUP BY oov.name
UNION
 SELECT oov.name offer_name
   FROM ozf_offers_v oov,
        qp_modifier_summary_v qmsv,
        mtl_item_categories mic
  WHERE qmsv.list_header_id = oov.list_header_id
    AND g_trunc_sysdate between nvl(oov.start_date_active,g_trunc_sysdate) AND nvl(oov.end_date_active,g_trunc_sysdate)
    AND product_attribute_context = 'ITEM'
    AND qmsv.prod_attr_segment_name = 'PRODUCT_CATEGORY'
    AND mic.inventory_item_id = p_inventory_item_id
    AND mic.category_id= product_attr_value
    AND oov.active_flag = 'Y'
GROUP BY oov.name
UNION
SELECT NVL(qpl.description, qpl.name) offer_name
  FROM ozf_activity_products oap,
       qp_list_headers_all qpl
 WHERE oap.OBJECT_TYPE IN('SCAN_DATA','LUMPSUM','NET_ACCRUAL','VOLUME_OFFER')
   AND oap.ITEM = p_inventory_item_id
   AND oap.object_id =  qpl.list_header_id
   AND g_trunc_sysdate between nvl(oap.start_date,g_trunc_sysdate)   AND  nvl(oap.end_date,g_trunc_sysdate)
   AND oap.active_flag = 'Y'
   GROUP BY NVL(qpl.description, qpl.name)
 UNION
 SELECT NVL(qpl.description, qpl.name) offer_name
   FROM ams_act_products oap,
        qp_list_headers_all qpl,
        ozf_offers oo
WHERE oap.arc_act_product_used_by ='OFFR'
 AND  oap.inventory_item_id = p_inventory_item_id
 AND  oap.act_product_used_by_id =  qpl.list_header_id
 AND  oap.enabled_flag = 'Y'
 AND  oo.offer_code = qpl.name
 AND  oo.status_code = 'ACTIVE'
 AND  trunc(nvl(oo.start_date,sysdate)) <= trunc(sysdate)
 GROUP BY NVL(qpl.description, qpl.name);

CURSOR get_item_number_csr(p_inventory_item_id IN NUMBER)
  IS
  SELECT msi.concatenated_segments
    FROM mtl_system_items_kfv msi
   WHERE inventory_item_id = p_inventory_item_id
     AND ROWNUM = 1;

  CURSOR get_vendor_csr(p_vendor_id IN NUMBER)
  IS
  SELECT
	  vendor_name,
	  segment1 vendor_num
	FROM
	  ap_suppliers
	WHERE
  vendor_id = p_vendor_id;

CURSOR get_vendor_site_csr(p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER, p_org_id IN NUMBER)
	  IS
  SELECT
	  vendor_site_code
	FROM
	  ap_supplier_sites_all
	WHERE
	  vendor_site_id = p_vendor_site_id    and
	  vendor_id = p_vendor_id   and
    org_id = p_org_id;

CURSOR get_ou_csr(p_org_id IN NUMBER)
	  IS
  SELECT
	  name
	FROM
	  hr_operating_units
	WHERE
	  organization_id = p_org_id;

  BEGIN

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;


   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_PROCEDURE, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

--
-- API body
--

    IF l_pl_notify_hdr_rec.vendor_id IS NULL THEN
       DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Vendor ID cannot be NULL');
		       FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
					 FND_MESSAGE.set_token('ID', 'Vendor ID');
		       FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
    ELSIF l_pl_notify_hdr_rec.vendor_site_id IS NULL THEN
           DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Vendor Site ID cannot be NULL');
		       FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
					 FND_MESSAGE.set_token('ID', 'Vendor Site ID');
		       FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
    ELSIF l_pl_notify_hdr_rec.org_id IS NULL THEN
           DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Org ID cannot be NULL');
		       FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
					 FND_MESSAGE.set_token('ID', 'Org ID');
		       FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
    ELSE
        FOR get_vendor_rec IN get_vendor_csr(p_pl_notify_hdr_rec.vendor_id) LOOP
          p_pl_notify_hdr_rec.vendor_name := get_vendor_rec.vendor_name;
          p_pl_notify_hdr_rec.vendor_number := get_vendor_rec.vendor_num;
        END LOOP;

        FOR get_vendor_site_rec IN get_vendor_site_csr(p_pl_notify_hdr_rec.vendor_id, p_pl_notify_hdr_rec.vendor_site_id,
        p_pl_notify_hdr_rec.org_id)  LOOP
          p_pl_notify_hdr_rec.vendor_site_code := get_vendor_site_rec.vendor_site_code;
        END LOOP;

        FOR get_ou_rec IN get_ou_csr(p_pl_notify_hdr_rec.org_id) LOOP
               	p_pl_notify_hdr_rec.operating_unit := get_ou_rec.name;
        END LOOP;
    IF l_pl_notify_line_tbl.EXISTS(1) THEN
       FOR i in l_pl_notify_line_tbl.FIRST..l_pl_notify_line_tbl.LAST LOOP
           IF l_pl_notify_line_tbl(i).inventory_item_id IS NULL THEN
                 DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Inventory Item ID cannot be NULL');
              FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
              FND_MESSAGE.set_token('ID', 'Inventory Item ID');
              FND_MSG_PUB.add;
              RAISE FND_API.G_EXC_ERROR;
           ELSE
              FOR get_item_number_rec IN get_item_number_csr(l_pl_notify_line_tbl(i).Inventory_Item_ID) LOOP
                 l_pl_notify_line_tbl(i).Item_Number := get_item_number_rec.concatenated_segments ;
              END LOOP;

              OPEN get_offers_csr(l_pl_notify_line_tbl(i).inventory_item_id);  LOOP
                FETCH get_offers_csr BULK COLLECT INTO l_offer_tbl;
                EXIT WHEN get_offers_csr%NOTFOUND;
              END LOOP;
              CLOSE get_offers_csr;
              -- Initializing Nested Table
	      IF NOT l_offer_tbl.EXISTS(1) THEN
	         l_offer_tbl(1) := NULL;
              END IF;
              l_pl_notify_line_tbl(i).object_name_tbl := l_offer_tbl;
           END IF;
       END LOOP;
    ELSE
         DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Line detals cannot be NULL');
      FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
      FND_MESSAGE.set_token('ID', 'Line Details');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  --Reassign the local variable to the out variable
  p_pl_notify_line_tbl := l_pl_notify_line_tbl  ;

   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'return status for API =>'||x_return_status);

   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'end');
   -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (p_count => x_msg_count,
     p_data => x_msg_data
     );
 EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data
                               );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data
                               );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
			   fnd_message.set_token('ROUTINE', 'DPP_PRICING_PVT.Notify_Promotions');
			   fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;
         DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'Error in notify promotions: '||SQLERRM);
    END IF;
   -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data
                               );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

  END Notify_Promotions;

END DPP_PRICING_PVT;

/
