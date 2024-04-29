--------------------------------------------------------
--  DDL for Package IPA_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IPA_APIS" AUTHID CURRENT_USER AS
--$Header: IPASRVS.pls 120.1.12010000.2 2010/02/23 19:15:53 djanaswa ship $

	PROCEDURE summarize_dpis (
				errbug	IN OUT NOCOPY VARCHAR2 ,
				retcode	IN OUT NOCOPY varchar2 )	;

	PROCEDURE update_dpis ( i_interface_id 		IN   	NUMBER  ,
				i_project_id 	   		IN   	NUMBER  ,
				i_project_asset_id   		IN   	NUMBER  ,
				i_date_placed_in_service 	IN	DATE 	  ,
				i_xface_complete_asset_flag 	IN	VARCHAR2,
				i_book_type_code     		IN	VARCHAR2,
				i_asset_units        		IN	NUMBER, --changed datatype bug 9339798
		   	 	i_asset_category_id  		IN	NUMBER  ,
				i_asset_location_id  		IN	NUMBER  ,
		   	 	i_depreciate_flag    		IN	VARCHAR2,
				i_depreciation_expense_ccid	IN	NUMBER,
				i_asset_status			IN	VARCHAR2,
                                i_xface_asset_units             IN      NUMBER -- added bug 9339798
			     );
     /* Commented out for rel 11.5.1 as no longer used
	PROCEDURE update_expenditure_item (
				i_project_id 	IN 	NUMBER)	;
     */


END ipa_apis ;

/
