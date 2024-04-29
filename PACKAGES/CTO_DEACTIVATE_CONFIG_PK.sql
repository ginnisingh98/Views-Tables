--------------------------------------------------------
--  DDL for Package CTO_DEACTIVATE_CONFIG_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_DEACTIVATE_CONFIG_PK" AUTHID CURRENT_USER as
/* $Header: CTODACTS.pls 120.1 2005/06/16 15:48:50 appldev  $*/

gDebugLevel	NUMBER :=  to_number(nvl(FND_PROFILE.value('ONT_DEBUG_LEVEL'),0));
gAttrControl    NUMBER;
gMasterOrgn     NUMBER;

PROCEDURE cto_deactivate_configuration(
                         errbuf 	 OUT   NOCOPY  VARCHAR2,
                         retcode 	 OUT   NOCOPY  VARCHAR2,
                         p_org_id        IN      NUMBER,
			 p_master_org_id IN	 NUMBER,			-- new fix
			 p_config_id     IN      NUMBER,			-- new fix
			 p_dummy	 IN	 NUMBER,			-- new fix
			 p_model_id      IN      NUMBER,			-- new fix
			 p_optionitem_id IN      NUMBER,			-- new fix
                         p_num_of_days   IN      NUMBER,
                         p_user_id 	 IN      NUMBER,
                         p_login_id      IN      NUMBER,
                         p_template_id   IN      NUMBER

                                        );



PROCEDURE CHECK_DELETE_STATUS(
                                p_inventory_item_id    IN NUMBER,
                                p_org_id               IN NUMBER,
                                p_delete_status_code   IN VARCHAR2,
                                x_return_status        OUT NOCOPY VARCHAR2
                              );


PROCEDURE CHECK_COMMON_ROUTING(
                                p_inventory_item_id     IN NUMBER,
                                p_org_id                IN NUMBER,
                                p_delete_status_code    IN VARCHAR2,
                               x_return_status        OUT NOCOPY VARCHAR2
                                );


PROCEDURE CHECK_COMMON_BOM(
                    p_inventory_item_id     IN NUMBER,
                    p_org_id                IN NUMBER,
                    p_delete_status_code    IN VARCHAR2,
                    x_return_status        OUT NOCOPY VARCHAR2
                    );


END CTO_DEACTIVATE_CONFIG_PK;

 

/
