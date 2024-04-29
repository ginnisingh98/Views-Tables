--------------------------------------------------------
--  DDL for Package Body XTR_CASHPOOL_UTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_CASHPOOL_UTLS" as
/* $Header: xtrpoolb.pls 120.0.12010000.2 2008/08/06 10:43:50 srsampat ship $ */

/****************************************************************/
/* Insert record into XTR_CASHPOOL_ATTRIBUTES table for IAC     */
/* deal attributes                                              */
/****************************************************************/
PROCEDURE INSERT_IAC_CASHPOOL (p_cashpool_id 	NUMBER,
			       p_party_code	VARCHAR2,
			       p_iac_portfolio  VARCHAR2,
			       p_iac_product_type VARCHAR2)IS
BEGIN
   If p_cashpool_id is NOT NULL then
      INSERT INTO XTR_CASHPOOL_ATTRIBUTES
		       (CASHPOOL_ATTRIBUTE_ID,
			CASHPOOL_ID,
			IAC_PORTFOLIO,
			IAC_PRODUCT_TYPE,
			PORTFOLIO,
			PRODUCT_TYPE,
			ROUNDING_TYPE,
			DAY_COUNT_TYPE,
			PRICING_MODEL,
			FUND_LIMIT_CODE,
			INVEST_LIMIT_CODE,
			PARTY_CODE,
			PARTY_PORTFOLIO,
			PARTY_PRODUCT_TYPE,
			PARTY_PRICING_MODEL,
			PARTY_FUND_LIMIT_CODE,
			PARTY_INVEST_LIMIT_CODE,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATE_LOGIN)
      VALUES
		       (xtr_cashpool_attributes_s.nextval,
			p_cashpool_id,
			p_iac_portfolio,
			p_iac_product_type,
			null,
			null,
			null,
			null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
			null,
		        nvl(fnd_global.user_id,-1),
			sysdate,
   		        nvl(fnd_global.user_id,-1),
			sysdate,
		        nvl(fnd_global.user_id,-1));
   End if;
END;

/****************************************************************/
/* Insert record into XTR_CASHPOOL_ATTRIBUTES table for IG      */
/* deal attributes                                              */
/****************************************************************/
PROCEDURE INSERT_IG_CASHPOOL (p_cashpool_id    NUMBER,
                              p_portfolio  VARCHAR2,
                              p_product_type VARCHAR2,
			      p_rounding_type VARCHAR2,
			      p_day_count_type VARCHAR2,
			      p_pricing_model  VARCHAR2,
		              p_fund_limit	VARCHAR2,
			      p_invest_limit	VARCHAR2,
			      p_party_code	VARCHAR2,
			      p_party_portfolio VARCHAR2,
			      p_party_product_type	VARCHAR2,
			      p_party_pricing_model	VARCHAR2,
			      p_party_fund_limit	VARCHAR2,
			      p_party_invest_limit	VARCHAR2)IS
BEGIN
   If p_cashpool_id is NOT NULL then
      INSERT INTO XTR_CASHPOOL_ATTRIBUTES
                       (CASHPOOL_ATTRIBUTE_ID,
                        CASHPOOL_ID,
                        IAC_PORTFOLIO,
                        IAC_PRODUCT_TYPE,
                        PORTFOLIO,
                        PRODUCT_TYPE,
                        ROUNDING_TYPE,
                        DAY_COUNT_TYPE,
                        PRICING_MODEL,
                        FUND_LIMIT_CODE,
                        INVEST_LIMIT_CODE,
                        PARTY_CODE,
                        PARTY_PORTFOLIO,
                        PARTY_PRODUCT_TYPE,
                        PARTY_PRICING_MODEL,
                        PARTY_FUND_LIMIT_CODE,
                        PARTY_INVEST_LIMIT_CODE,
                        CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATE_LOGIN)
      VALUES
                       (xtr_cashpool_attributes_s.nextval,
                        p_cashpool_id,
                        null,
                        null,
		        p_portfolio,
                        p_product_type,
                        p_rounding_type,
                        p_day_count_type,
                        p_pricing_model,
                        p_fund_limit,
                        p_invest_limit,
                        p_party_code,
                        p_party_portfolio,
                        p_party_product_type,
                        p_party_pricing_model,
                        p_party_fund_limit,
                        p_party_invest_limit,
                        nvl(fnd_global.user_id,-1),
                        sysdate,
                        nvl(fnd_global.user_id,-1),
                        sysdate,
                        nvl(fnd_global.user_id,-1));
   End if;

END;

/****************************************************************/
/* Update XTR_CASHPOOL_ATTRIBUTES table for IAC deal attributes */
/****************************************************************/

PROCEDURE UPDATE_IAC_CASHPOOL (p_cashpool_id    NUMBER,
                               p_iac_portfolio  VARCHAR2,
                               p_iac_product_type VARCHAR2)IS
BEGIN
	Update XTR_CASHPOOL_ATTRIBUTES
	set IAC_PORTFOLIO = p_iac_portfolio,
	    IAC_PRODUCT_TYPE = p_iac_product_type
	Where cashpool_id = p_cashpool_id
	and IAC_PORTFOLIO is NOT NULL;
END;

/****************************************************************/
/* Update XTR_CASHPOOL_ATTRIBUTES table for IG deal attributes  */
/* for Company                                                  */
/****************************************************************/
PROCEDURE UPDATE_IG_CASHPOOL (p_cashpool_id    NUMBER,
                              p_portfolio  VARCHAR2,
                              p_product_type VARCHAR2,
                              p_rounding_type VARCHAR2,
                              p_day_count_type VARCHAR2,
                              p_pricing_model  VARCHAR2,
                              p_fund_limit      VARCHAR2,
                              p_invest_limit    VARCHAR2,
                              p_party_code      VARCHAR2,
                              p_party_portfolio VARCHAR2,
                              p_party_product_type      VARCHAR2,
                              p_party_pricing_model     VARCHAR2,
                              p_party_fund_limit        VARCHAR2,
                              p_party_invest_limit      VARCHAR2)IS
BEGIN
        Update XTR_CASHPOOL_ATTRIBUTES
        Set PORTFOLIO 		= p_portfolio,
	    PRODUCT_TYPE	= p_product_type,
	    ROUNDING_TYPE	= p_rounding_type,
	    DAY_COUNT_TYPE	= p_day_count_type,
	    PRICING_MODEL	= p_pricing_model,
            FUND_LIMIT_CODE     = p_fund_limit,
            INVEST_LIMIT_CODE   = p_invest_limit,
            PARTY_PORTFOLIO     = p_party_portfolio,
            PARTY_PRODUCT_TYPE  = p_party_product_type,
            PARTY_PRICING_MODEL = p_party_pricing_model,
            PARTY_FUND_LIMIT_CODE = p_party_fund_limit,
            PARTY_INVEST_LIMIT_CODE = p_party_invest_limit,
            LAST_UPDATED_BY     = nvl(fnd_global.user_id,-1),
            LAST_UPDATE_DATE    = sysdate,
            LAST_UPDATE_LOGIN   = nvl(fnd_global.user_id,-1)
        Where cashpool_id = p_cashpool_id
	and party_code = p_party_code
        and iac_portfolio is NULL;
END;

/****************************************************************/
/* Update XTR_CASHPOOL_ATTRIBUTES table for IG deal attributes  */
/* for Intercompany                                             */
/****************************************************************/
PROCEDURE UPDATE_IG_ROW_CASHPOOL (p_cashpool_id    NUMBER,
                              p_fund_limit      VARCHAR2,
                              p_invest_limit    VARCHAR2,
                              p_party_code      VARCHAR2,
                              p_party_portfolio VARCHAR2,
                              p_party_product_type      VARCHAR2,
                              p_party_pricing_model     VARCHAR2,
                              p_party_fund_limit        VARCHAR2,
                              p_party_invest_limit      VARCHAR2)IS
BEGIN
	Update XTR_CASHPOOL_ATTRIBUTES
	Set FUND_LIMIT_CODE 	= p_fund_limit,
	    INVEST_LIMIT_CODE	= p_invest_limit,
	    PARTY_PORTFOLIO	= p_party_portfolio,
	    PARTY_PRODUCT_TYPE  = p_party_product_type,
	    PARTY_PRICING_MODEL = p_party_pricing_model,
	    PARTY_FUND_LIMIT_CODE = p_party_fund_limit,
	    PARTY_INVEST_LIMIT_CODE = p_party_invest_limit,
	    LAST_UPDATED_BY	= nvl(fnd_global.user_id,-1),
	    LAST_UPDATE_DATE	= sysdate,
	    LAST_UPDATE_LOGIN	= nvl(fnd_global.user_id,-1)
	Where cashpool_id = p_cashpool_id
	and party_code = p_party_code;
END;

/****************************************************************/
/* delete record from XTR_CASHPOOL_ATTRIBUTES table when user   */
/* remove sub-account from the cashpool                         */
/****************************************************************/
PROCEDURE DELETE_XTR_CASHPOOL (p_cashpool_id NUMBER,
			       p_party_code VARCHAR2) IS
BEGIN
	Delete from XTR_CASHPOOL_ATTRIBUTES
	Where CASHPOOL_ATTRIBUTE_ID = p_cashpool_id
	and party_code = p_party_code;
END;


/****************************************************************/
/* Default cashpol Treasury deal attribute values while user    */
/* create the physical cashpool. 			        */
/****************************************************************/
PROCEDURE DEFAULT_IAC_IG_ATTRIBUTES (p_company_code NUMBER,
				     x_iac_portfolio OUT NOCOPY VARCHAR2,
				     x_iac_product_type OUT NOCOPY VARCHAR2,
			             x_portfolio OUT NOCOPY VARCHAR2,
				     x_product_type OUT NOCOPY VARCHAR2,
				     x_rounding_type OUT NOCOPY VARCHAR2,
				     x_day_count_type OUT NOCOPY VARCHAR2,
				     x_pricing_model OUT NOCOPY VARCHAR2) is

Cursor C_IAC_ATT is
select iac_portfolio, iac_product_type
from xtr_cashpool_attributes
where party_code = p_company_code
and iac_portfolio is NOT NULL
order by creation_date desc;

Cursor C_IG_ATT is
select portfolio, product_type,
	rounding_type, day_count_type, pricing_model
from xtr_cashpool_attributes
where party_code = p_company_code
and portfolio is NOT NULL
order by creation_date desc;

Cursor C_DFT_PORTFOLIO is
select portfolio
from  XTR_PORTFOLIOS
where company_code = p_company_code
and nvl(default_portfolio, 'N') = 'Y';


BEGIN
  Open C_IAC_ATT;
  Fetch C_IAC_ATT into x_iac_portfolio, x_iac_product_type;
  if C_IAC_ATT%NOTFOUND then
     Open C_DFT_PORTFOLIO;
     Fetch C_DFT_PORTFOLIO into x_iac_portfolio;
     Close C_DFT_PORTFOLIO;
  End if;

  Close C_IAC_ATT;

  Open C_IG_ATT;
  Fetch C_IG_ATT into x_portfolio, x_product_type,
	x_rounding_type, x_day_count_type, x_pricing_model;
  if C_IG_ATT%NOTFOUND then
     Open C_DFT_PORTFOLIO;
     Fetch C_DFT_PORTFOLIO into x_portfolio;
     Close C_DFT_PORTFOLIO;
  End if;

  Close C_IG_ATT;






END;
END XTR_CASHPOOL_UTLS;

/
