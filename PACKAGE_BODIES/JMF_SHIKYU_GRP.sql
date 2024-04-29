--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_GRP" as
--$Header: JMFGSHKB.pls 120.13 2007/12/28 09:18:18 kdevadas ship $

--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFGSHKB.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          Body file of the group package for the Charge      |
--|                        Based SHIKYU project.  Other teams such as CST,    |
--|                        RCV, PO and Financials Globalization will be       |
--|                        calling this package to support SHIKYU.            |
--|                                                                           |
--|  FUNCTION/PROCEDURE:   Variance_Account                        |
--|                        Get_Po_Shipment_Osa_Flag                           |
--|                        Is_Tp_Organization                                 |
--|                        Is_AP_Invoice_Shikyu_Nettable                      |
--|                        Is_AP_Inv_Shikyu_Nettable_Func                     |
--|                        Is_So_Line_Shikyu_Enabled                          |
--|                        Validate_Osa_Flag                                  |
--|                        Get_Shikyu_Attributes                              |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   20-APR-2005          vchu  Created.                                     |
--|   07-JUL-2005          vchu  Fixed GSCC errors.                           |
--|   19-SEP-2005          vchu  Added Is_AP_Inv_Shikyu_Nettable_Func per     |
--|                              request from Financials Globalization.       |
--|                              Stubbed out all other procedures to avoid    |
--|                              uptake of other dependencies for their local |
--|                              dev and testing environments.  Will leap     |
--|                              frog the actual code for those stubbed out   |
--|                              procedures in the next version.              |
--|   21-SEP-2005          vchu  Leapfrog from revision 120.4 since revision  |
--|                              120.5 is a stubbed our version for           |
--|                              Finanicials Globalization that contains the  |
--|                              actual implementation of the                 |
--|                              Is_AP_Invoice_Shikyu_Nettable procedure      |
--|                              only.  Is_AP_Inv_Shikyu_Nettable_Func is     |
--|                              also added to this version.                  |
--|   31-MAY-2006          vchu  Fixed 5212998: Performance fix for SQL ID    |
--|                              #17703504.  Modified the query in            |
--|                              Is_So_Line_Shikyu_Enabled to avoid FTS.      |
--|                              It's OK to remove the CONNECT BY PRIOR logic |
--|                              since RMA lines do not go beyond one level,  |
--|                              and they never reference another RMA line    |
--|                              (according to Manish Chavan from OM).        |
--|   29-SEP-2006          vchu  Bug fix for 5574912: Added the distinct      |
--|                              keyword to the query in                      |
--|                              Is_AP_Invoice_Shikyu_Nettable since there    |
--|                              could be multiple PO Shipments associated to |
--|                              a single AP Invoice Distribution.  We can    |
--|                              assume the Outsourced_Assembly flag of all   |
--|                              of these PO Shipments would be either 1 (Yes)|
--|                              or 2 (No), since the ERS program creates     |
--|                              separate AP invoices for PO Shipments with   |
--|                              the Outsourced_Assembly flag checked, and    |
--|                              those with the flag unchecked.               |
--|   03-OCT-2007      kdevadas  12.1 Buy/Sell Subcontracting Changes         |
--|                              Reference - GBL_BuySell_TDD.doc              |
--|                              Reference - GBL_BuySell_FDD.doc              |
--|   27-DEC-2007      kdevadas  Bug: 6679369 - Get_shikyu_variance_account   |
--|                              modified to pass the subcontracting type     |
--|                              to Costing for OSA receipts in Std Cost orgs |
--+===========================================================================+

--=============================================
-- CONSTANTS
--=============================================
G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'jmf.plsql.' || G_PKG_NAME || '.';

--=============================================
-- GLOBAL VARIABLES
--=============================================
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

--===========================================================================
--  API NAME   : Get_Shikyu_Variance_Account
--
--  DESCRIPTION:
--
--  PARAMETERS :
--  IN         :
--  OUT        :
--
--  DESIGN REFERENCES: SHIKYU_GRP_API_TD.doc
--
--  CHANGE HISTORY:	21-Apr-05	VCHU   Created.
--===========================================================================
PROCEDURE Get_Shikyu_Variance_Account
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_po_shipment_id          IN  NUMBER
, x_variance_account        OUT NOCOPY NUMBER
, x_subcontracting_type     OUT NOCOPY NUMBER    -- Bug 6679369
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Get_Shikyu_Variance_Account';
l_api_version CONSTANT NUMBER       := 1.0;

/* 12.1 Buy/Sell Subcontracting Changes */
l_subcontracting_type             VARCHAR2(1);
l_oem_organization_id             NUMBER;
l_tp_organization_id              NUMBER;
l_ppv_account                     NUMBER;

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Entry');
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- End API initialization

  x_variance_account := NULL;

  -- Joining the subcontracting orders table with the Shipping Networks table
  -- table to get the Code Combination ID of the SHIKYU Variance Account.
  -- The Shipping Networks table stores relationships from OEM Organizations
  -- to MP Organizations

   /* 12.1 - Buy/Sell Subcontracting - Changes */
   /* For Buy/Sell subcontracting - return the purchase price variance account*/
	SELECT mip.subcontracting_type, jso.oem_organization_id
	INTO l_subcontracting_type , l_oem_organization_id
	FROM mtl_interorg_parameters mip, jmf_subcontract_orders jso
	 WHERE jso.subcontract_po_shipment_id = p_po_shipment_id
	  AND jso.oem_organization_id = mip.from_organization_id
	  AND jso.tp_organization_id = mip.to_organization_id;


    /* Bug : 6679369
    Note : IF Subcontracting TYPE IS Chargeable, x_subcontracting_type will be SET AS 1
             IF Subcontracting TYPE IS Buy/Sell, x_subcontracting_type will be SET AS 2
    x_subcontracting_type will be returned to CST as a number rather than a VARCHAR2 as the
    CST code is written in pro-C and there are technical limitations in passsing the OUT
    paramter as VARCHAR2. This change has been incorporated after recommendations from
    the CST team */

	If (l_subcontracting_type = 'B')   /* Buy Sell relationship betn OEM and MP */
	THEN
     x_subcontracting_type := 2 ; -- Bug 6679369
	   SELECT purchase_price_var_account
	   INTO l_ppv_account
	  FROM mtl_parameters
	 WHERE organization_id = l_oem_organization_id ;

	X_variance_account := l_ppv_account;

	ELSIF (l_subcontracting_type = 'C')
  THEN
  /* return the chargeable subcontracting variance account */
    x_subcontracting_type := 1 ; -- Bug 6679369
    SELECT mip.shikyu_oem_var_account_id
    INTO   x_variance_account
    FROM   mtl_interorg_parameters mip,
          jmf_subcontract_orders jso
    WHERE  jso.subcontract_po_shipment_id = p_po_shipment_id
    AND    jso.oem_organization_id = mip.from_organization_id
    AND    jso.tp_organization_id = mip.to_organization_id;

  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name || '.no_data_found'
                    , 'No relationship exists for the OEM Organization and Manufacturing Organization of the Subcontracting PO');
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_exception'
                    , 'Exception');
    END IF;

  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Get_Shikyu_Variance_Account;

--===========================================================================
--  API NAME   :  Get_Po_Shipment_Osa_Flag
--
--  DESCRIPTION:
--
--  PARAMETERS :
--  IN         :
--  OUT        :
--
--  DESIGN REFERENCES: SHIKYU_GRP_API_TD.doc
--
--  CHANGE HISTORY:	21-Apr-05	VCHU   Created.
--===========================================================================
PROCEDURE Get_Po_Shipment_Osa_Flag
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_po_shipment_id          IN  NUMBER
, x_osa_flag                OUT NOCOPY VARCHAR2
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Get_Po_Shipment_Osa_Flag';
l_api_version CONSTANT NUMBER       := 1.0;

l_outsourced_assembly  NUMBER       := NULL;

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Entry');
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

/*
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
*/

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- End API initialization

  x_osa_flag := 'N';

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Before the query: p_po_shipment_id = "' || p_po_shipment_id || '"');
  END IF;

  -- Selecting the shikyu_osa_item_flag of PO Line
  -- with the passed in PO Line ID
  SELECT nvl(outsourced_assembly, 2)
  INTO   l_outsourced_assembly
  FROM   po_line_locations_all poll
  WHERE  poll.line_location_id = p_po_shipment_id;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'After the query: l_outsourced_assembly = ' || l_outsourced_assembly);
  END IF;

  IF l_outsourced_assembly = 1
    THEN
    x_osa_flag := 'Y';
  ELSE
    x_osa_flag := 'N';
  END IF;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Exit: Returning x_osa_flag = "' || x_osa_flag || '", x_return_status = "' || x_return_status || '"');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
	FND_MSG_PUB.Count_And_Get
	              ( p_count => x_msg_count
	              , p_data  => x_msg_data
	              );
	 x_msg_data := 'NO_DATA_FOUND: p_po_shipment_id = ' || p_po_shipment_id;
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 IF g_fnd_debug = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
	 THEN
	   FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
	                 , G_MODULE_PREFIX || l_api_name || '.no_data_found'
	                 , 'The PO Line does not exist.');
	 END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );
	x_msg_data := 'FND_API.G_EXC_UNEXPECTED_ERROR: p_po_shipment_id = ' || p_po_shipment_id;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_exception'
                    , 'Exception');
    END IF;

  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );
	x_msg_data := 'OTHER EXCEPTIONS: p_po_shipment_id = ' || p_po_shipment_id;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Get_Po_Shipment_Osa_Flag;

--===========================================================================
--  API NAME   :  Is_Tp_Organization
--
--  DESCRIPTION:
--
--  PARAMETERS :
--  IN         :
--  OUT        :
--
--  DESIGN REFERENCES: SHIKYU_GRP_API_TD.doc
--
--  CHANGE HISTORY:	21-Apr-05	VCHU   Created.
--===========================================================================
PROCEDURE Is_Tp_Organization
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN  NUMBER
, x_is_tp_org_flag          OUT NOCOPY VARCHAR2
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Is_Tp_Organization';
l_api_version CONSTANT NUMBER       := 1.0;

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Entry');
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- End API initialization

  SELECT nvl(trading_partner_org_flag, 'N')
  INTO   x_is_tp_org_flag
  FROM   MTL_PARAMETERS
  WHERE  organization_id = p_organization_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
	FND_MSG_PUB.Count_And_Get
	              ( p_count => x_msg_count
	              , p_data  => x_msg_data
	              );
	x_return_status := FND_API.G_RET_STS_ERROR;
	IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
	THEN
	FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
	              , G_MODULE_PREFIX || l_api_name || '.no_data_found'
	              , 'The Inventory Organization does not exist.');
	END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_exception'
                    , 'Exception');
    END IF;

  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Is_Tp_Organization;

--===========================================================================
--  API NAME   : Is_AP_Invoice_Shikyu_Nettable
--
--  DESCRIPTION: This is the backtracking API to determine if an AP invoice
--               is eligible for SHIKYU Netting.  It looks at one of the
--               distribution lines of the invoice and backtrack to the
--               corresponding PO Shipment to get the OSA_FLAG flag.
--               Since ERS would not comingle SHIKYU and non-SHIKYU lines
--               into the same AP invoice, an AP invoice would be containing
--               all SHIKYU distribution lines and thus would be SHIKYU
--               netting eligible if any one of the AP invoice distribution
--               lines can be backtracked to a PO Shipment created for an
--               Outsourced Assembly item.
--
--  PARAMETERS :
--  IN         :
--  OUT        :
--
--  DESIGN REFERENCES: SHIKYU_GRP_API_TD.doc
--
--  CHANGE HISTORY:	21-Apr-05	VCHU   Created.
--===========================================================================
PROCEDURE Is_AP_Invoice_Shikyu_Nettable
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_ap_invoice_id           IN  NUMBER
, x_nettable                OUT NOCOPY VARCHAR2
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Is_AP_Invoice_Shikyu_Nettable';
l_api_version CONSTANT NUMBER       := 1.0;

l_outsourced_assembly  NUMBER       := NULL;

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Entry');
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- End API initialization

  x_nettable := 'N';

  -- Selecting the shikyu_osa_item_flag of the underlying PO Line
  -- of the AP distribution line of the invoice with the passed in
  -- invoice ID having the smallest distribution_line_number.
  -- We can conclude whether an invoice is SHIKYU netting
  -- eligible by examining one of the distribution line of the
  -- invoice, since ERS would not comingle SHIKYU and
  -- non-SHIKYU lines.

  -- Bug 5574912: Added the distinct keyword since there can be
  -- multiple PO Shipments associated to a single AP Invoice
  -- Distribution.  We can assume the Outsourced_Assembly flag
  -- of all of these PO Shipments would be either 1 (Yes) or
  -- 2 (No), since the ERS program creates separate AP invoices
  -- for PO Shipments PO Shipments with the Outsourced_Assembly
  -- flag checked, and those with the flag unchecked.

  SELECT DISTINCT NVL(plla.outsourced_assembly, 2)
  INTO   l_outsourced_assembly
  FROM   ap_invoice_distributions_all apd,
         po_distributions_all pda,
         po_line_locations_all plla
  WHERE  apd.po_distribution_id = pda.po_distribution_id
  AND    pda.line_location_id = plla.line_location_id
  AND    apd.invoice_id = p_ap_invoice_id
  AND    apd.distribution_line_number =
           (SELECT MIN(distribution_line_number)
            FROM   ap_invoice_distributions_all
            WHERE  invoice_id = p_ap_invoice_id);

  IF l_outsourced_assembly = 1
    THEN
    x_nettable := 'Y';
  ELSE
    x_nettable := 'N';
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
	FND_MSG_PUB.Count_And_Get
	              ( p_count => x_msg_count
	              , p_data  => x_msg_data
	              );
	x_return_status := FND_API.G_RET_STS_ERROR;
	IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
	THEN
	  FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
	                , G_MODULE_PREFIX || l_api_name || '.no_data_found'
	                , 'The AP Invoice does not exist.');
	END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_exception'
                    , 'Exception');
    END IF;

  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Is_AP_Invoice_Shikyu_Nettable;

--===========================================================================
--  API NAME   : Is_AP_Inv_Shikyu_Nettable_Func
--
--  DESCRIPTION: This function calls the Is_AP_Invoice_Shikyu_Nettable
--               procedure and return the value passed back to the OUT
--               parameter x_nettable.
--
--  PARAMETERS :
--  IN         :
--  OUT        :
--
--  DESIGN REFERENCES: SHIKYU_GRP_API_TD.doc
--
--  CHANGE HISTORY:	19-Sep-05	VCHU   Created.
--===========================================================================
FUNCTION Is_AP_Inv_Shikyu_Nettable_Func
( p_ap_invoice_id            IN  NUMBER
)
RETURN VARCHAR2
IS
  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
  l_nettable       VARCHAR2(1);
BEGIN

  Is_AP_Invoice_Shikyu_Nettable
  ( p_api_version     => 1.0
  , p_init_msg_list   => NULL
  , x_return_status   => l_return_status
  , x_msg_count       => l_msg_count
  , x_msg_data        => l_msg_data
  , p_ap_invoice_id   => p_ap_invoice_id
  , x_nettable        => l_nettable
  );
  RETURN l_nettable;

END Is_AP_Inv_Shikyu_Nettable_Func;

--===========================================================================
--  API NAME   :  Is_So_Line_Shikyu_Enabled
--
--  DESCRIPTION:
--
--  PARAMETERS :
--  IN         :
--  OUT        :
--
--  DESIGN REFERENCES: SHIKYU_GRP_API_TD.doc
--
--  CHANGE HISTORY:	21-Apr-05	VCHU   Created.
--===========================================================================
PROCEDURE Is_So_Line_Shikyu_Enabled
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_sales_order_line_id     IN  NUMBER
, x_is_enabled              OUT NOCOPY VARCHAR2
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Is_So_Line_Shikyu_Enabled';
l_api_version CONSTANT NUMBER       := 1.0;

l_shikyu_enabled_so_line_count NUMBER := 0;

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Entry');
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- End API initialization

  -- Returns 1 if the passed in Sales Order Line ID corresponds to a SHIKYU
  -- enabled Replenishment SO Line stored in the JMF_SHIKYU_REPLENISHMENTS
  -- table, or an SO Line splitted from a Replenishment SO Line
  SELECT count('x')
  INTO   l_shikyu_enabled_so_line_count
  FROM   dual
  WHERE  exists
  (SELECT 'X'
   FROM    oe_order_lines_all oola,
           mtl_system_items_b msib,
           jmf_shikyu_replenishments jsr
   WHERE   oola.inventory_item_id = msib.inventory_item_id
   AND     msib.organization_id = jsr.oem_organization_id
   AND     msib.subcontracting_component in (1, 2)
   AND     jsr.replenishment_so_line_id = oola.line_id
   AND     jsr.replenishment_so_line_id IN
           (SELECT reference_line_id
            FROM   oe_order_lines_all
            WHERE  line_id = p_sales_order_line_id
           )
  );

  -- Assign the boolean value depending on the return count
  IF l_shikyu_enabled_so_line_count >= 1 THEN
    x_is_enabled := 'Y';
  ELSE
    x_is_enabled := 'N';
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_exception'
                    , 'Exception');
    END IF;

  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Is_So_Line_Shikyu_Enabled;

--===========================================================================
--  API NAME   :  Validate_OSA_Flag
--
--  DESCRIPTION:
--
--  PARAMETERS :
--  IN         :
--  OUT        :
--
--
--  DESIGN REFERENCES: SHIKYU_GRP_API_TD.doc
--
--  CHANGE HISTORY:	21-Apr-05	VCHU   Created.
--===========================================================================
PROCEDURE Validate_Osa_Flag
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_inventory_item_id       IN  NUMBER
, p_vendor_id               IN  NUMBER
, p_vendor_site_id          IN  NUMBER
, p_ship_to_organization_id IN  NUMBER
, x_osa_flag                OUT NOCOPY VARCHAR2
)

IS

l_api_name       CONSTANT VARCHAR2(30) := 'Validate_OSA_Flag';
l_api_version    CONSTANT NUMBER       := 1.0;
l_return_status  varchar2(1)           := NULL;
l_msg_count      number                := NULL;
l_msg_data       varchar2(2000)        := NULL;

l_last_billing_date       DATE         := NULL;
l_consigned_billing_cycle NUMBER       := NULL;

l_tp_organization_id
  MTL_PARAMETERS.organization_id%TYPE                    := NULL;
l_consigned_from_supplier_flag
  PO_ASL_ATTRIBUTES.CONSIGNED_FROM_SUPPLIER_FLAG%TYPE := NULL;
l_enable_vmi_flag
  PO_ASL_ATTRIBUTES.ENABLE_VMI_FLAG%TYPE              := NULL;
l_ship_to_org_item_osa_flag
  MTL_SYSTEM_ITEMS_B.OUTSOURCED_ASSEMBLY%TYPE            := NULL;
l_tp_org_item_osa_flag
  MTL_SYSTEM_ITEMS_B.OUTSOURCED_ASSEMBLY%TYPE            := NULL;

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- End API initialization

  -- Initializes the output osa flag to 'Y'
  x_osa_flag := 'Y';

  -- Get the outsourced_assembly flag of the item having the passed
  -- in item id and ship to organization id
  SELECT msib.outsourced_assembly
  INTO   l_ship_to_org_item_osa_flag
  FROM   mtl_system_items_b msib
  WHERE  msib.inventory_item_id = p_inventory_item_id
  AND    msib.organization_id = p_ship_to_organization_id;

  /* Validation of the item level OSA flag in the Ship to Organization */
  IF l_ship_to_org_item_osa_flag <> 1
    THEN
    x_osa_flag := 'N';
  END IF;

  IF x_osa_flag <> 'N' AND
     p_vendor_id IS NOT NULL AND
     p_vendor_site_id IS NOT NULL
  THEN

    /* Validation of the item level OSA flag in the Trading Partner Organization */
    SELECT DISTINCT hoi.organization_id,
                    msib.outsourced_assembly
    INTO   l_tp_organization_id,
           l_tp_org_item_osa_flag
    FROM   HR_ORGANIZATION_INFORMATION hoi,
           MTL_SYSTEM_ITEMS_B msib
    WHERE  hoi.org_information_context = 'Customer/Supplier Association'
    AND    hoi.org_information3 = p_vendor_id
    AND    hoi.org_information4 = p_vendor_site_id
    AND    msib.organization_id = hoi.organization_id
    AND    msib.inventory_item_id = p_inventory_item_id;

    IF l_tp_org_item_osa_flag <> 1
      THEN
      x_osa_flag := 'N';
    END IF;

    IF x_osa_flag <> 'N'
    THEN

      /* Consigned Validation */
      -- Check if the Supplier/Supplier Site/Ship to Organization/Item
      -- combination corresponds to a consigned enabled ASL, if yes, set
      -- the osa_flag to be 'N'
      PO_THIRD_PARTY_STOCK_GRP.Get_Asl_Attributes
      ( p_api_version                  => 1.0
      , p_init_msg_list                => NULL
      , x_return_status                => l_return_status
      , x_msg_count                    => l_msg_count
      , x_msg_data                     => l_msg_data
      , p_inventory_item_id            => p_inventory_item_id
      , p_vendor_id                    => p_vendor_id
      , p_vendor_site_id               => p_vendor_site_id
      , p_using_organization_id        => p_ship_to_organization_id
      , x_consigned_from_supplier_flag => l_consigned_from_supplier_flag
      , x_enable_vmi_flag              => l_enable_vmi_flag
      , x_last_billing_date            => l_last_billing_date
      , x_consigned_billing_cycle      => l_consigned_billing_cycle
      );

      IF l_consigned_from_supplier_flag = 'Y'
        THEN
        x_osa_flag := 'N';
      END IF;

    END IF;

  END IF;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name || '.no_data_found'
                    , 'No Data Found ');
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_exception'
                    , 'Exception');
    END IF;

  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Validate_Osa_Flag;


--===========================================================================
--  API NAME   :  Get_Shikyu_Attributes
--
--  DESCRIPTION:
--
--  PARAMETERS :
--  IN         :
--  OUT        :
--
--
--  DESIGN REFERENCES: SHIKYU_GRP_API_TD.doc
--
--  CHANGE HISTORY:	21-Apr-05	VCHU   Created.
--===========================================================================
PROCEDURE Get_Shikyu_Attributes
( p_api_version              IN  NUMBER
, p_init_msg_list            IN  VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_organization_id          IN  NUMBER
, p_item_id                  IN  NUMBER
, x_outsourced_assembly      OUT NOCOPY NUMBER
, x_subcontracting_component OUT NOCOPY NUMBER
)
IS

l_api_name       CONSTANT VARCHAR2(30) := 'Get_Shikyu_Attributes';
l_api_version    CONSTANT NUMBER       := 1.0;

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Entry');
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- End API initialization

  SELECT outsourced_assembly, subcontracting_component
  INTO   X_outsourced_assembly, x_subcontracting_component
  FROM   mtl_system_items_b
  WHERE  organization_id = p_organization_id
  AND    inventory_item_id = p_item_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name || '.no_data_found'
                    , 'No Data Found ');
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_exception'
                    , 'Exception');
    END IF;

  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Get_Shikyu_Attributes;

/* 12.1 Buy/Sell Subcontracting Changes */
--===========================================================================
--  API NAME   :  Get_subcontracting_type
--
--  DESCRIPTION:  This parameters returns the subcontracting type established
--                  the OEM AND the MP organizations
--
--  PARAMETERS :
--  IN         :
--  OUT        :   Returns 'B' for Buy/Sell Subcontracting
--                 Returns 'C' for Chargeable Subcontracting
--                 NULL otherwise
--
--  DESIGN REFERENCES: GBL_BUYSELL_TDD.doc
--
--  CHANGE HISTORY:	03-OCT-07	KDEVADAS   Created.
--===========================================================================
FUNCTION Get_Subcontracting_Type
( p_oem_org_id IN NUMBER
, p_mp_org_id IN NUMBER	)
RETURN VARCHAR2 IS

l_subcontracting_type VARCHAR2(1)   ;
l_api_name    CONSTANT VARCHAR2(30) := 'Get_Subcontracting_Type';
l_api_version CONSTANT NUMBER       := 1.0;
l_msg_data VARCHAR2(4000);
l_msg_count NUMBER;

BEGIN

  IF g_fnd_debug = 'Y' AND
    FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Entry');
  END IF;

  l_subcontracting_type := NULL;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Before the query: subcontracting_type = "' || l_subcontracting_type || '"');
  END IF;

    -- Start API initialization
    FND_MSG_PUB.initialize;


	SELECT mip.subcontracting_type
	INTO l_subcontracting_type
	FROM mtl_interorg_parameters  mip
	WHERE mip.from_organization_id = p_oem_org_id
	AND mip.to_organization_id = p_mp_org_id;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'After the query: subcontracting_type = "' || l_subcontracting_type || '"');
  END IF;


  RETURN l_subcontracting_type;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name || '.no_data_found'
                    , 'No subcontracting relationship exists between the OEM and the MP');
    END IF;
	  RETURN NULL;
  WHEN OTHERS    THEN
         FND_MSG_PUB.Count_And_Get
              ( p_encoded => FND_API.G_FALSE
              , p_count => l_msg_count
              , p_data  => l_msg_data
              );
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , l_msg_data);
    END IF;
    RETURN NULL;

END Get_Subcontracting_Type;



END JMF_SHIKYU_GRP;

/
