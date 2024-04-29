--------------------------------------------------------
--  DDL for Package ASL_INV_ITEM_SUMM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASL_INV_ITEM_SUMM_PUB" AUTHID CURRENT_USER AS
/* $Header: aslcons.pls 115.2 2004/08/03 01:54:49 dvayro noship $ */

PROCEDURE Table_Load_Main(
    	    ERRBUF   	        OUT NOCOPY VARCHAR2
	     , RETCODE            OUT NOCOPY VARCHAR2
	     , p_run_mode         IN  VARCHAR2 DEFAULT 'I'
	     , p_category_set_id  IN  NUMBER
	     , p_organization_id  IN  NUMBER
	     , p_category_id      IN  NUMBER
         );

PROCEDURE Category_summary_Info_Refresh (
          x_err_msg           OUT NOCOPY VARCHAR2
         ,x_err_code          OUT NOCOPY VARCHAR2);

PROCEDURE Complete_Inv_Item_Refresh(
          x_err_msg          OUT NOCOPY VARCHAR2
	     , x_err_code         OUT NOCOPY VARCHAR2
	     , p_category_set_id  IN  NUMBER
	     , p_organization_id  IN  NUMBER
	     , p_category_id      IN  NUMBER
	    );


PROCEDURE Increm_Cat_Inv_Item_Refresh(
        x_err_msg          OUT NOCOPY VARCHAR2
	   , x_err_code         OUT NOCOPY VARCHAR2
	   , p_category_set_id  IN  NUMBER
	   , p_organization_id  IN  NUMBER
	   ) ;

PROCEDURE Increm_Inv_Item_Refresh(
        x_err_msg          OUT NOCOPY VARCHAR2
	   , x_err_code         OUT NOCOPY VARCHAR2
	   , p_category_set_id  IN  NUMBER
	   , p_organization_id  IN  NUMBER
	   , p_category_id      IN  NUMBER
	   );

PROCEDURE Complete_Inv_Pricing_Refresh(
          x_err_msg          OUT NOCOPY VARCHAR2
	     , x_err_code         OUT NOCOPY VARCHAR2
	     , p_category_set_id  IN  NUMBER
	     , p_organization_id  IN  NUMBER
	     , p_category_id      IN  NUMBER
	    );


PROCEDURE Increm_Cat_Inv_Price_Refresh(
        x_err_msg          OUT NOCOPY VARCHAR2
	   , x_err_code         OUT NOCOPY VARCHAR2
	   , p_category_set_id  IN  NUMBER
	   , p_organization_id  IN  NUMBER
	   ) ;


PROCEDURE Increm_Inv_Pricing_Refresh(
          x_err_msg          OUT NOCOPY VARCHAR2
	     , x_err_code         OUT NOCOPY VARCHAR2
	     , p_category_set_id  IN  NUMBER
	     , p_organization_id  IN  NUMBER
	     , p_category_id      IN  NUMBER
	    ) ;

END ASL_INV_ITEM_SUMM_PUB;


 

/
