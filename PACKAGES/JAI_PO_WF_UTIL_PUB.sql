--------------------------------------------------------
--  DDL for Package JAI_PO_WF_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PO_WF_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: jainpowfut.pls 120.0.12010000.2 2009/08/03 09:05:14 erma noship $ */
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     jainpowfut.pls                                                    |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     This is the utility package for IL po notification.               |
--|                                                                       |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Get_Req_Curr_Conv_Rate                                 |
--|      PROCEDURE Get_Currency_Convertion_Rate                           |
--|      PROCEDURE Get_Jai_Tax_Amount                                     |
--|      PROCEDURE Get_Jai_New_Tax_Amount                                 |
--|      PROCEDURE Populate_Session_GT                                    |
--|      FUNCTION  Get_Tax_Region                                         |
--|      FUNCTION  Get_Poreq_Tax                                          |
--|      FUNCTION  Get_Jai_Req_Tax_Disp                                   |
--|      FUNCTION  Get_Jai_Tax_Disp                                       |
--|      FUNCTION  Get_Jai_Open_Form_Command                              |
--|                                                                       |
--| HISTORY                                                               |
--|     2009/02/11 Eric Ma   Created                                      |
--|                                                                       |
--+======================================================================*/

  -- Public constant declarations
  GV_MODULE_PREFIX             VARCHAR2 (100) := 'jai.plsql.JAI_PO_WF_UTIL_PUB';
  G_PO_DOC_TYPE       CONSTANT VARCHAR2  (20) := 'PO';
  G_REQ_DOC_TYPE      CONSTANT VARCHAR2  (20) := 'REQUISITION';
  G_REL_DOC_TYPE      CONSTANT VARCHAR2  (20) := 'RELEASE';

  -- Public function and procedure declarations

  --==========================================================================
  --    PROCEDURE   NAME:
  --
  --    Get_Req_Curr_Conv_Rate                     Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to get the conversion rate for a Requsition line
  --
  --  PARAMETERS:
  --      In: pn_req_header_id      IN   NUMBER               req header id
  --          pn_req_line_id        IN   NUMBER               req line id
  --          pv_tax_currency       IN   VARCHAR2             tax currency code
  --          xn_conversion_rate    OUT  NUMBER               conversion  rate
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           15-APR-2009   Eric Ma  created
  --==========================================================================

  PROCEDURE Get_Req_Curr_Conv_Rate
  ( pn_req_header_id     IN NUMBER
  , pn_req_line_id       IN NUMBER
  , pv_tax_currency      IN VARCHAR2
  , xn_conversion_rate   OUT NOCOPY NUMBER
  );

  --==========================================================================
  --    PROCEDURE   NAME:
  --
  --    Get_Currency_Convertion_Rate                     Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to get the conversion rate for PO/PA
  --
  --  PARAMETERS:
  --      In: pn_document_id      IN   NUMBER               PO/PA header id
  --          pv_tax_currency     IN   VARCHAR2             tax currency code
  --          xn_conversion_rate  OUT  NUMBER               conversion  rate
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           15-APR-2009   Eric Ma  created
  --==========================================================================
  PROCEDURE Get_Currency_Convertion_Rate
  ( pn_document_id   IN NUMBER
  , pv_tax_currency  IN VARCHAR2
  , xn_conversion_rate OUT NOCOPY NUMBER
  );

 --==========================================================================
  --    PROCEDURE   NAME:
  --
  --    Get_Jai_Tax_Amount                     Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to get the exclusive tax amount and non recoverable exclusive tax
  --    amount for a PO,PR or a RELEASE
  --
  --  PARAMETERS:
  --      In: pv_document_type         IN VARCHAR2,                       document type  : requisition,po,release
  --          pn_document_id           IN NUMBER,                         document_id    : req header id,po header id
  --          pn_release_num           IN NUMBER DEFAULT NULL,            release nmuber : for release,it receive release number
  --          xn_excl_tax_amount      OUT NOCOPY NUMBER,                  exclusive tax amount for the document
  --          xn_excl_nr_tax_amount   OUT NOCOPY NUMBER                   exclusive non recoverable tax amount for the document
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           10-FEB-2009   Eric Ma  created
  --==========================================================================
  PROCEDURE Get_Jai_Tax_Amount
  ( pv_document_type       IN VARCHAR2,
    pn_document_id         IN NUMBER,
    pn_requisition_line_id IN NUMBER DEFAULT NULL,
    xn_excl_tax_amount     OUT NOCOPY NUMBER,
    xn_excl_nr_tax_amount  OUT NOCOPY NUMBER
  );

  --==========================================================================
  --    PROCEDURE   NAME:
  --
  --    Get_Tax_Amount_Info                     Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to get the exclusive tax amount and non recoverable exclusive tax
  --    amount for a given tax id and tax amount
  --
  --  PARAMETERS:
  --      In: pn_tax_id            IN   NUMBER               tax identifier
  --          pn_tax_amount        IN   NUMBER               tax amount
  --          pn_conver_rate       IN   NUMBER DEFAULT 1     converstion rate between different currency
  --          pn_rounding_factor   IN   NUMBER DEFAULT NULL  rounding factor
  --          x_excl_tax_amount    OUT  NUMBER               exclusive tax amount
  --          x_excl_nr_tax_amount OUT  NUMBER               exclusive non recoverable tax amount
  --          pn_trx_rec_flag      IN   VARCHAR2             The modvat flat in tax transaction level
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           10-FEB-2009   Eric Ma  created
  --==========================================================================
  PROCEDURE  Get_Tax_Amount_Info
  ( pn_tax_id             IN NUMBER
  , pn_tax_amount         IN NUMBER
  , pn_conver_rate        IN NUMBER DEFAULT 1
  , pn_rounding_factor    IN NUMBER DEFAULT NULL
  , xn_excl_tax_amount    OUT NOCOPY NUMBER
  , xn_excl_nr_tax_amount OUT NOCOPY NUMBER
  , pn_trx_rec_flag	      IN VARCHAR2 DEFAULT 'N' -- add by Xiao Lv for MADVAT flag on 25-Mar-2009
  );

  --==========================================================================
  --    PROCEDURE   NAME:
  --
  --    Get_Tax_Region                     Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to return the tax region code
  --
  --  PARAMETERS:
  --      In: pv_document_type      IN   VARCHAR2     document type
  --          pn_document_id        IN   NUMBER       document header id
  --          pn_org_id             IN   NUMBER       organization id
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           15-APR-2009   Eric Ma  created
  --==========================================================================
  FUNCTION Get_Tax_Region
  ( pv_document_type      IN VARCHAR2  DEFAULT NULL
  , pn_document_id        IN NUMBER    DEFAULT NULL
  , pn_org_id             IN NUMBER    DEFAULT NULL
  ) RETURN VARCHAR2;


 --==========================================================================
  --    FUNCTION   NAME:
  --
  --    Get_Poreq_Tax                     Public
  --
  --  DESCRIPTION:
  --    get po requisition tax
  --
  --  PARAMETERS:
  --      In: pv_document_type          IN   VARCHAR2        po type
  --          pn_document_id            IN   NUMBER      req header id,po header id
  --          pn_release_num            IN   NUMBER      release num
  --          pn_line_id                IN   NUMBER        po line id
  --          pn_line_location_id       IN   NUMBER        po line location id
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           13-Apr-2009   Xiao Lv  created
  --==========================================================================
  FUNCTION Get_Poreq_Tax
	( pv_document_type       IN VARCHAR2
  , pn_document_id         IN NUMBER
  , pn_release_num         IN NUMBER DEFAULT NULL
  , pn_line_id		         IN NUMBER DEFAULT NULL
  , pn_line_location_id    IN NUMBER DEFAULT NULL
	) RETURN NUMBER;


  --==========================================================================
  --    PROCEDURE   NAME:
  --
  --    Get_Jai_New_Tax_Amount                     Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to get the exclusive tax amount and non recoverable exclusive tax
  --    amount for a PO,PR or a RELEASE
  --
  --  PARAMETERS:
  --      In: pv_document_type         IN VARCHAR2,                       document type  : requisition,po,release
  --          pn_document_id           IN NUMBER,                         document_id    : req header id,po header id
  --          pn_release_num           IN NUMBER DEFAULT NULL,            release nmuber : for release,it receive release number
  --          xn_excl_tax_amount      OUT NOCOPY NUMBER,                  exclusive tax amount for the document
  --          xn_excl_nr_tax_amount   OUT NOCOPY NUMBER                   exclusive non recoverable tax amount for the document
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           7-Apr-2009   Xiao Lv  created
  --==========================================================================
  PROCEDURE Get_Jai_New_Tax_Amount
  ( pv_document_type       IN VARCHAR2,
    pn_document_id         IN NUMBER,
    pn_chg_request_group_id  IN NUMBER,
    xn_excl_tax_amount     OUT NOCOPY NUMBER,
    xn_excl_nr_tax_amount  OUT NOCOPY NUMBER
  );

 --==========================================================================
  --    FUNCTION   NAME:
  --
  --    Get_Jai_Req_Tax_Disp                     Public
  --
  --  DESCRIPTION:
  --    Return the formatted non-recoverable tax for display
  --
  --  PARAMETERS:
  --      In: pn_jai_excl_nr_tax      IN   NUMBER        non recoverable tax amount
  --          pv_total_tax_dsp        IN   VARCHAR2      total tax amount for display
  --          pv_currency_code        IN   VARCHAR2      currency code used for formating
  --          pv_currency_mask        IN   VARCHAR       formatted mask used by fnd_currency function
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           8-Apr-2009   Eric Ma  created
  --==========================================================================
  FUNCTION Get_Jai_Req_Tax_Disp
  ( pn_jai_excl_nr_tax IN NUMBER
  , pv_total_tax_dsp   IN VARCHAR2
  , pv_currency_code   IN VARCHAR2
  , pv_currency_mask   IN VARCHAR2
  ) RETURN VARCHAR2;

 --==========================================================================
  --    FUNCTION   NAME:
  --
  --    Get_Jai_Tax_Disp                     Public
  --
  --  DESCRIPTION:
  --    Return the formatted tax amount for display
  --
  --  PARAMETERS:
  --      In: pn_tax_amount           IN   NUMBER        tax amount
  --          pv_currency_code        IN   VARCHAR2      currency code used for formating
  --          pv_currency_mask        IN   VARCHAR       formatted mask used by fnd_currency function
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           8-Apr-2009   Eric Ma  created
  --==========================================================================
  FUNCTION Get_Jai_Tax_Disp
  ( pn_tax_amount IN NUMBER
  , pv_currency_code   IN VARCHAR2
  , pv_currency_mask   IN VARCHAR2
  ) RETURN VARCHAR2;

  --==========================================================================
  --    FUNCTION   NAME:
  --
  --    Get_Jai_Open_Form_command                     Public
  --
  --  DESCRIPTION:
  --    Return the open form command for each document type
  --
  --  PARAMETERS:
  --      In: pv_document_type        IN   VARCHAR2      document type
  --  DESIGN REFERENCES:
  --
  --  CHANGE HISTORY:
  --
  --           13-Apr-2009   Eric Ma  created
  --==========================================================================

  Function Get_Jai_Open_Form_Command( pv_document_type VARCHAR2 )
  RETURN VARCHAR2;

--==========================================================================
  --    PROCEDURE   NAME:
  --
  --    Populate_Session_GT                     Public
  --
  --  DESCRIPTION:
  --    Populate_session_gt will insert IL tax amount into session table
  --
  --  PARAMETERS:
  --      In: p_document_id          IN   NUMBER        req header id,po header id
  --          p_document_type        IN   VARCHAR2      po type
  --          p_document_subtype     IN   VARCHAR2
  --          x_session_gt_key       IN   NUMBER
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           13-Apr-2009   Xiao Lv  created
  --==========================================================================

  PROCEDURE Populate_Session_GT(
	   p_document_id         IN     NUMBER
	,  p_document_type       IN     VARCHAR2
	,  p_document_subtype    IN     VARCHAR2
	,  x_session_gt_key      IN     NUMBER
	) ;



END JAI_PO_WF_UTIL_PUB;

/
