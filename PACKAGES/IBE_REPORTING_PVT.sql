--------------------------------------------------------
--  DDL for Package IBE_REPORTING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_REPORTING_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVECRS.pls 115.15 2002/12/10 11:29:08 suchandr ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_REPORTING_PKG';

PROCEDURE  printDebugLog(pDebugStmt Varchar2);

FUNCTION get_item_count(inventory_item_id in number,header_id in number) return number;

PROCEDURE  getFrequencyDate(pDate IN Date, pFrequency IN Varchar2, pPeriodSetName IN varchar2, pdayoffset IN Number, pStartDate OUT NOCOPY Date, pEndDate OUT NOCOPY Date);

PROCEDURE  removeFactData( pMode IN Varchar2, pName IN Varchar2, pFromDate IN Date, pToDate IN Date);

PROCEDURE  forceRefreshData(pForceRefreshFlag IN Varchar2,pMode IN Varchar2, pObjName IN Varchar2,pBeginDate IN Date,pEndDate IN Date,pForceRefreshStatus OUT NOCOPY Varchar2);

PROCEDURE  dropIndex( pMode IN Varchar2, pOwner IN Varchar2,pName IN Varchar2);
PROCEDURE  createIndex( pMode IN Varchar2, pName IN Varchar2);


PROCEDURE insertOrderHeaderFact( p_currency_code IN Varchar2, pFromDate IN Date, pToDate IN Date);
PROCEDURE insertOrderLineFact( p_currency_code IN Varchar2, pFromDate IN Date, pToDate IN Date);
PROCEDURE insertBinFact(pRefreshDate IN Date);
PROCEDURE insertBinFact(pCurrencyCode IN Varchar2,pRefreshDate IN Date);

PROCEDURE refreshFact(pMode IN Varchar2,pFactName IN Varchar2,pBeginDate IN Varchar2, pEndDate IN Varchar2);

PROCEDURE refreshFactMain(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER,
		pMode IN varchar2 default 'COMPLETE', pBeginDate IN varchar2,
		pEndDate IN varchar2,pDayOffset IN Number default 0,
		pDebugFlag IN Varchar2 default 'N',pRateCheckFlag IN Varchar2 default 'N');

PROCEDURE refreshMview(pMode IN Varchar2, pMViewName Varchar2,pFactName Varchar2);

PROCEDURE refreshMviewMain( errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER, pfactRefreshMode IN Varchar2 default 'COMPLETE', pDebugFlag IN Varchar2 Default 'N');

PROCEDURE purgeMain(errbuf    OUT NOCOPY  VARCHAR2, retcode OUT NOCOPY    NUMBER, pDebugFlag IN Varchar2 Default 'N');

-- added by savio for bundle roll up
FUNCTION return_amount(p_inventory_item_id number,p_organization_id number,p_order_header_id number) return number;

FUNCTION return_functional_amount(p_inventory_item_id number   , p_organization_id number ,
                                  p_order_header_id number     , p_item_type_code varchar2,
                                  p_line_category_code varchar2, p_ordered_Quantity number,
                                  p_Unit_Selling_Price number  ,p_conversion_rate number)
         RETURN number;

FUNCTION get_section_path(section_id in number,store_id in number)
	    RETURN varchar2;

PRAGMA RESTRICT_REFERENCES (get_section_path, WNDS);
END;

 

/
