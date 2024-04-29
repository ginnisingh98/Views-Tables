--------------------------------------------------------
--  DDL for Package MSC_ATP_ALLOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_ALLOC" AUTHID CURRENT_USER AS
/* $Header: MSCATALS.pls 120.1 2007/12/12 10:20:26 sbnaik ship $  */
G_SUCCESS	CONSTANT NUMBER := 0;
G_WARNING	CONSTANT NUMBER := 1;
G_ERROR		CONSTANT NUMBER := 2;

-- time_phased_atp
G_ATF_DATE      DATE;

PROCEDURE View_Allocation_Details(
	p_session_id         	IN    		NUMBER,
	p_inventory_item_id  	IN    		NUMBER,
	p_instance_id        	IN    		NUMBER,
	p_organization_id    	IN    		NUMBER,
	x_return_status      	OUT	NOCOPY VARCHAR2);

PROCEDURE Refresh_Allocation_Details(
        ERRBUF                  OUT     NOCOPY  VARCHAR2,
        RETCODE                 OUT     NOCOPY  NUMBER,
	p_session_id         	IN    		NUMBER,
	p_inventory_item_id  	IN    		NUMBER,
	p_instance_id        	IN    		NUMBER,
	p_organization_id    	IN    		NUMBER);

-- Added function to call the refresh allocation concurrent program
-- from database package.
-- fix for bug 2781625
function Refresh_Alloc_request(
                     p_new_session_id in number ,
                     p_inventory_item_id in number ,
                     p_instance_id in number ,
                     p_organization_id in number ) return number;
END MSC_ATP_ALLOC;

/
