--------------------------------------------------------
--  DDL for Package WSH_ITM_ITEM_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_ITEM_SYNC" AUTHID CURRENT_USER AS
/* $Header: WSHITISS.pls 120.0.12010000.2 2009/03/19 09:27:20 sankarun ship $ */

        PROCEDURE POPULATE_DATA (
            errbuf               		OUT NOCOPY   VARCHAR2,
			retcode              		OUT NOCOPY   NUMBER,
			p_from_organization_code	IN           VARCHAR2,
			p_to_organization_code   	IN           VARCHAR2,
			p_from_item            		IN           VARCHAR2 ,
			p_to_item              		IN           VARCHAR2,
			p_user_item_type       		IN           VARCHAR2,
			p_created_n_days       		IN           NUMBER,
			p_updated_n_days       		IN           NUMBER
                                );
END;

/
