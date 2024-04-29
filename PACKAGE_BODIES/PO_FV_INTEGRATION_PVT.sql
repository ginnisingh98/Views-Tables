--------------------------------------------------------
--  DDL for Package Body PO_FV_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_FV_INTEGRATION_PVT" AS
/* $Header: POXVFVIB.pls 120.2 2005/06/29 18:49:26 shsiung noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_FV_INTEGRATION_PVT';
g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.'|| g_pkg_name || '.';

g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

 --<JFMIP Vendor Registration FPJ Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: val_vendor_site_ccr_regis
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
-- This function checks if a vendor site has a valid Central Contractor
-- Registration (CCR). It returns TRUE if the registration is valid, or if
-- the instanse is not a federal instance; otherwise, it returns FALSE
--Parameters:
--IN:
--p_vendor_id
--  Vendor ID
--p_vendor_site_id
--  Vendor site ID
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
FUNCTION val_vendor_site_ccr_regis(
  p_vendor_id           IN NUMBER,
  p_vendor_site_id      IN NUMBER
)
RETURN BOOLEAN
IS

  l_api_name   CONSTANT VARCHAR2(30) := 'VAL_VENDOR_SITE_CCR_REGIS';
  l_progress            VARCHAR2(3);

  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_ccr_status          VARCHAR2(1);
  l_error_code          NUMBER;

  -- If the profile option 'Enable Transaction Code' is set to Yes, then it
  -- is a federal instance
  l_federal_instance VARCHAR2(1) := NVL(PO_CORE_S.Check_Federal_Instance(PO_MOAC_UTILS_PVT.Get_Current_Org_Id),'N');

BEGIN
  l_progress := '000';
  IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
         || l_progress, ' Begin');
     END IF;
  END IF;

  IF l_federal_instance = 'N' THEN
     l_progress := '005';
     IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name
            ||'.'|| l_progress,
            ' Not a federal instance. No need to check. Return True.');
        END IF;
      END IF;

     RETURN TRUE;
  END IF;

  l_progress := '010';

  -- Call Federal Financials' API to check the Central Contractor Registration
  -- status of the vendor site
  FV_CCR_GRP.fv_ccr_reg_status(
              p_api_version    => 1.0,
              p_init_msg_list  => 'F',
              p_vendor_site_id => p_vendor_site_id,
              x_return_status  => l_return_status,
              x_msg_count      => l_msg_count,
              x_msg_data       => l_msg_data,
              x_ccr_status     => l_ccr_status,
              x_error_code     => l_error_code);

  l_progress := '020';
  IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
         || l_progress, ' After calling FV_CCR_GRP.fv_ccr_reg_status');
     END IF;
  END IF;

  -- Return FALSE if
  -- (1) return status is error and vendor site is not exempt from CCR;
  IF (l_return_status = FND_API.G_RET_STS_ERROR AND l_error_code <> G_SITE_NOT_CCR_SITE)
     OR
  -- (2) return status is success but registration status is not ACTIVE;
     (l_return_status = FND_API.G_RET_STS_SUCCESS AND l_ccr_status <> G_SITE_REG_ACTIVE)
     OR
  -- (3) return status is unexpected error
     (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

      l_progress := '030';
      IF g_debug_stmt THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
          l_api_name||'.' || l_progress,
          ' Vendor site registration is not valid. CCR status: '|| l_ccr_status
          ||' Error code: '|| l_error_code ||' Return status: '|| l_return_status);
         END IF;
      END IF;

      RETURN FALSE;

  ELSE --  l_return_status check
      l_progress := '040';
         IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                l_api_name||'.' || l_progress,
                ' Vendor site registration is valid');
            END IF;
         END IF;

      RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
          l_api_name||'.' || l_progress, ' Exception has occured.' ||
          ' l_msg_data: ' || l_msg_data || ' l_msg_count: ' || l_msg_count );
        END IF;
     END IF;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name,
          SUBSTRB (SQLERRM , 1 , 200) || ' at location ' || l_progress);
     END IF;

     RETURN FALSE;
END val_vendor_site_ccr_regis;
--<JFMIP Vendor Registration FPJ End>

END PO_FV_INTEGRATION_PVT;

/
