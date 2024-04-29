--------------------------------------------------------
--  DDL for Package Body AP_CLM_PVT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CLM_PVT_PKG" AS
/* $Header: apclmpfb.pls 120.0.12010000.5 2010/03/23 07:08:49 sjetti noship $ */

  G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
  G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
  G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
  G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
  G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
  G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER   := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER   := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER   := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;


Procedure Print_Debug(
		p_api_name		IN VARCHAR2,
		p_debug_info		IN VARCHAR2);

--  This function will determine whether a PO is a clm PO.
FUNCTION is_clm_po
                    (
                            p_po_header_id        IN NUMBER DEFAULT NULL,
                            p_po_line_id          IN NUMBER DEFAULT NULL,
                            p_po_line_location_id IN NUMBER DEFAULT NULL,
                            p_po_distribution_id  IN NUMBER DEFAULT NULL
                    )
RETURN VARCHAR2
IS
l_api_name                 CONSTANT VARCHAR2(100) := 'is_clm_po';
l_debug_info               VARCHAR2(240);
l_is_clm_po                VARCHAR2(1) := 'N';
BEGIN

     l_debug_info := 'Calling po_clm_intg_grp.is_clm_po Procedure: ';
     Print_Debug(l_api_name,  l_debug_info);

     IF (po_clm_intg_grp.is_clm_po(p_po_header_id) = 'Y') then
            l_debug_info := 'Setting is_clm_installed as Y';
            Print_Debug(l_api_name,  l_debug_info);
            l_is_clm_po :='Y';
     END IF ;

     RETURN l_is_clm_po;
EXCEPTION
  WHEN Others THEN
     l_debug_info := 'is_clm_po check failed';
     Print_Debug(l_api_name,  l_debug_info);
     APP_EXCEPTION.raise_exception;
END is_clm_po;



--  This function will determine whether CLM is installed
FUNCTION is_clm_installed
RETURN VARCHAR2
IS
l_api_name                 CONSTANT VARCHAR2(100) := 'is_clm_installed';
l_debug_info               VARCHAR2(240);
l_is_clm_installed  VARCHAR2(1) := 'N';
BEGIN

l_debug_info := 'Calling po_clm_intg_grp.is_clm_installed Procedure: ';
Print_Debug(l_api_name,  l_debug_info);

l_is_clm_installed := po_clm_intg_grp.is_clm_installed ;

RETURN l_is_clm_installed;
EXCEPTION
WHEN OTHERS THEN
     l_debug_info := 'is_clm_installed check failed';
     Print_Debug(l_api_name,  l_debug_info);
     APP_EXCEPTION.raise_exception;
END is_clm_installed;



-- This procedure returns the PO Funding Information for a given entity id
PROCEDURE Get_Funding_Info
  (
    p_PO_HEADER_ID             IN NUMBER DEFAULT NULL,
    p_PO_LINE_ID               IN NUMBER DEFAULT NULL,
    p_LINE_LOCATION_ID         IN NUMBER DEFAULT NULL,
    p_PO_DISTRIBUTION_ID       IN NUMBER DEFAULT NULL,
    x_DISTRIBUTION_TYPE        OUT NOCOPY VARCHAR2,
    x_MATCHING_BASIS           OUT NOCOPY VARCHAR2,
    x_ACCRUE_ON_RECEIPT_FLAG   OUT NOCOPY VARCHAR2,
    x_CODE_COMBINATION_ID      OUT NOCOPY NUMBER,
    x_BUDGET_ACCOUNT_ID        OUT NOCOPY NUMBER,
    x_PARTIAL_FUNDED_FLAG      OUT NOCOPY VARCHAR2,
    x_UNIT_MEAS_LOOKUP_CODE    OUT NOCOPY VARCHAR2,
    x_FUNDED_VALUE             OUT NOCOPY NUMBER,
    x_QUANTITY_FUNDED          OUT NOCOPY NUMBER,
    x_AMOUNT_FUNDED            OUT NOCOPY NUMBER,
    x_QUANTITY_RECEIVED        OUT NOCOPY NUMBER,
    x_AMOUNT_RECEIVED          OUT NOCOPY NUMBER,
    x_QUANTITY_DELIVERED       OUT NOCOPY NUMBER,
    x_AMOUNT_DELIVERED         OUT NOCOPY NUMBER,
    x_QUANTITY_BILLED          OUT NOCOPY NUMBER,
    x_AMOUNT_BILLED            OUT NOCOPY NUMBER,
    x_QUANTITY_CANCELLED       OUT NOCOPY NUMBER,
    x_AMOUNT_CANCELLED 	       OUT NOCOPY NUMBER,
    X_RETURN_STATUS            OUT NOCOPY VARCHAR2)
    IS
l_api_name                 CONSTANT VARCHAR2(100) := 'Get_Funding_Info';
l_distribution_type        PO_DISTRIBUTIONS_ALL.destination_type_code%TYPE ;
l_accrue_on_receipt_flag   PO_DISTRIBUTIONS_ALL.accrue_on_receipt_flag%TYPE ;
l_code_combination_id      PO_DISTRIBUTIONS_ALL.code_combination_id%TYPE ;
l_budget_account_id        PO_DISTRIBUTIONS_ALL.budget_account_id%TYPE ;
l_partial_funded_flag      PO_DISTRIBUTIONS_ALL.partial_funded_flag%TYPE ;
l_funded_value             PO_DISTRIBUTIONS_ALL.funded_value%TYPE ;
l_quantity_funded          PO_DISTRIBUTIONS_ALL.quantity_funded%TYPE ;
l_amount_funded            PO_DISTRIBUTIONS_ALL.amount_funded%TYPE ;
l_quantity_delivered       PO_DISTRIBUTIONS_ALL.quantity_delivered%TYPE ;
l_amount_delivered         PO_DISTRIBUTIONS_ALL.amount_delivered%TYPE ;
l_quantity_billed          PO_DISTRIBUTIONS_ALL.quantity_billed%TYPE ;
l_amount_billed            PO_DISTRIBUTIONS_ALL.amount_billed%TYPE ;
l_quantity_cancelled       PO_DISTRIBUTIONS_ALL.quantity_cancelled%TYPE ;
l_amount_cancelled         PO_DISTRIBUTIONS_ALL.amount_cancelled%TYPE ;
l_matching_basis           PO_LINE_LOCATIONS.matching_basis%TYPE;
l_quantity_received        PO_LINE_LOCATIONS.quantity_received%TYPE;
l_amount_received          PO_LINE_LOCATIONS.amount_received%TYPE;
l_hold_name                VARCHAR2(30);
l_unit_meas_lookup_code    PO_LINE_LOCATIONS_ALL.unit_meas_lookup_code%TYPE;
l_return_status            VARCHAR2(1);
l_debug_info               VARCHAR2(240);

BEGIN

        l_debug_info := 'Processing Proedure AP_CLM_PVT_PKG.Get_Funding_Info for DISTRIBUTION_ID: '|| p_PO_DISTRIBUTION_ID;
        Print_Debug(l_api_name,  l_debug_info);

         po_clm_intg_grp.Get_Funding_Info(
         P_PO_DISTRIBUTION_ID     =>  p_PO_DISTRIBUTION_ID
        ,X_DISTRIBUTION_TYPE      =>  l_distribution_type
        ,X_MATCHING_BASIS         =>  l_matching_basis
        ,X_ACCRUE_ON_RECEIPT_FLAG =>  l_accrue_on_receipt_flag
        ,X_CODE_COMBINATION_ID    =>  l_code_combination_id
        ,X_BUDGET_ACCOUNT_ID      =>  l_budget_account_id
        ,X_PARTIAL_FUNDED_FLAG    =>  l_partial_funded_flag
        ,x_UNIT_MEAS_LOOKUP_CODE  =>  l_unit_meas_lookup_code
        ,X_FUNDED_VALUE           =>  l_funded_value
        ,X_QUANTITY_FUNDED        =>  l_quantity_funded
        ,X_AMOUNT_FUNDED          =>  l_amount_funded
        ,X_QUANTITY_RECEIVED      =>  l_quantity_received
        ,X_AMOUNT_RECEIVED        =>  l_amount_received
        ,X_QUANTITY_DELIVERED     =>  l_quantity_delivered
        ,X_AMOUNT_DELIVERED       =>  l_amount_delivered
        ,X_QUANTITY_BILLED        =>  l_quantity_billed
        ,X_AMOUNT_BILLED          =>  l_amount_billed
        ,x_QUANTITY_CANCELLED     =>  l_quantity_cancelled
        ,x_AMOUNT_CANCELLED       =>  l_amount_cancelled
        ,x_RETURN_STATUS          =>  l_return_status    );

        l_debug_info := 'After calling po_clm_intg_grp.Get_Funding_Info for l_return_status: '|| l_return_status;
        Print_Debug(l_api_name,  l_debug_info);

    IF L_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        l_debug_info := 'PO_INTG_DOCUMENT_FUNDS_GRP.Get_Funding_Info returned invalid status.';
        Print_Debug(l_api_name,  l_debug_info);
        APP_EXCEPTION.raise_exception;
    END IF    ;

x_DISTRIBUTION_TYPE       :=  l_distribution_type     ;
x_MATCHING_BASIS          :=  l_matching_basis  ;
x_ACCRUE_ON_RECEIPT_FLAG  :=  l_accrue_on_receipt_flag  ;
x_CODE_COMBINATION_ID     :=  l_code_combination_id     ;
x_BUDGET_ACCOUNT_ID       :=  l_budget_account_id      ;
x_PARTIAL_FUNDED_FLAG     :=  l_partial_funded_flag      ;
x_UNIT_MEAS_LOOKUP_CODE   :=  l_unit_meas_lookup_code ;
x_FUNDED_VALUE            :=  l_funded_value            ;
x_QUANTITY_FUNDED         :=  l_quantity_funded          ;
x_AMOUNT_FUNDED           :=  l_amount_funded          ;
x_QUANTITY_DELIVERED      :=  l_quantity_delivered      ;
x_AMOUNT_DELIVERED        :=  l_amount_delivered         ;
x_QUANTITY_BILLED         :=  l_quantity_billed          ;
x_AMOUNT_BILLED           :=  l_amount_billed            ;
x_QUANTITY_RECEIVED       :=  l_quantity_received    ;
x_AMOUNT_RECEIVED         :=  l_amount_received      ;
x_QUANTITY_CANCELLED      :=  l_quantity_cancelled ;
x_AMOUNT_CANCELLED        :=  l_amount_cancelled ;
x_RETURN_STATUS           :=  l_return_status ;

 Print_Debug(l_api_name,  'l_matching_basis :'|| l_matching_basis );
 Print_Debug(l_api_name,  'l_quantity_billed :'|| l_quantity_billed );
 Print_Debug(l_api_name,  'l_quantity_funded :'|| l_quantity_funded );
 Print_Debug(l_api_name,  'l_amount_billed :'|| l_amount_billed );
 Print_Debug(l_api_name,  'l_amount_funded :'|| l_amount_funded );

l_debug_info := 'Returning from AP_CLM_PVT_PKG.Get_Funding_Info with l_return_status: '|| l_return_status;
Print_Debug(l_api_name,  l_debug_info);


EXCEPTION
  WHEN Others THEN
     X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
     l_debug_info := 'Get_Funding_Info check failed';
     Print_Debug(l_api_name,  l_debug_info);
     APP_EXCEPTION.raise_exception;
END Get_Funding_Info;

Procedure Print_Debug(
		p_api_name		  IN VARCHAR2,
		p_debug_info		IN VARCHAR2) IS
BEGIN

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT, 'AP.PLSQL.AP_CLM_PVT_PKG'||p_api_name,p_debug_info);
  END IF;

END Print_Debug;

END AP_CLM_PVT_PKG;

/
