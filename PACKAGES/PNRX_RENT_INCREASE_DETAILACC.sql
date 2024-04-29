--------------------------------------------------------
--  DDL for Package PNRX_RENT_INCREASE_DETAILACC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNRX_RENT_INCREASE_DETAILACC" AUTHID CURRENT_USER AS
/* $Header: PNRXADRS.pls 120.0 2007/10/03 14:25:36 rthumma noship $ */

PROCEDURE RENT_INCREASE_DETAILACC(
		p_lease_number_low       IN           VARCHAR2 Default Null,
		p_lease_number_high      IN           VARCHAR2 Default Null,
		p_ri_number_low          IN           VARCHAR2 Default Null,
		p_ri_number_high         IN           VARCHAR2 Default Null,
		p_assess_date_from       IN	      DATE,
		p_assess_date_to         IN	      DATE,
		p_lease_class		 IN	      VARCHAR2 Default Null,
		p_property_id		 IN	      NUMBER   Default Null,
		p_building_id		 IN	      NUMBER   Default Null,
		p_location_id		 IN	      NUMBER   Default Null,
                p_include_draft          IN           VARCHAR2 Default	NULL,
		p_rent_type		 IN	      VARCHAR2 Default NULL,
		p_account_class		 IN	      VARCHAR2 Default NULL,
		p_set_of_books_id	 IN	      NUMBER   Default NULL,
		p_chart_of_accounts_id	 IN	      NUMBER   Default	NULL,
                l_request_id             IN           NUMBER,
                l_user_id                IN           NUMBER,
                retcode                  OUT NOCOPY   VARCHAR2,
                errbuf                   OUT NOCOPY   VARCHAR2
                   );



END;

/
