--------------------------------------------------------
--  DDL for Package Body EGO_DOM_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_DOM_UTIL_PUB" AS
/* $Header: EGOPDUTB.pls 120.1 2005/07/06 11:05:53 dedatta noship $ */

G_SUCCESS            CONSTANT  NUMBER  :=  0;
G_WARNING            CONSTANT  NUMBER  :=  1;
G_ERROR              CONSTANT  NUMBER  :=  2;

G_PKG_NAME           CONSTANT  VARCHAR2(30)  := 'EGO_DOM_UTIL_PUB';
G_APP_NAME           CONSTANT  VARCHAR2(3)   := 'DOM';
G_PKG_NAME_TOKEN     CONSTANT  VARCHAR2(8)   := 'PKG_NAME';
G_API_NAME_TOKEN     CONSTANT  VARCHAR2(8)   := 'API_NAME';
G_SQL_ERR_MSG_TOKEN  CONSTANT  VARCHAR2(11)  := 'SQL_ERR_MSG';
G_PLSQL_ERR          CONSTANT  VARCHAR2(17)  := 'EGO_PLSQL_ERR';



PROCEDURE check_floating_attachments (
                                        p_inventory_item_id     IN NUMBER
                                       ,p_revision_id           IN NUMBER
                                       ,p_organization_id       IN NUMBER
                                       ,p_lifecycle_id          IN NUMBER
                                       ,p_new_phase_id          IN NUMBER
                                       ,x_return_status         OUT NOCOPY  VARCHAR2
                                       ,x_msg_count             OUT NOCOPY  NUMBER
                                       ,x_msg_data              OUT NOCOPY VARCHAR2
) IS
l_return_val VARCHAR2(10);
BEGIN
        EXECUTE IMMEDIATE      'SELECT ENG_DOM_UTIL_PUB.Check_floating_attachments( :1,
                                                                                    :2,
                                                                                    :3,
                                                                                    :4,
                                                                                    :5
                                                                      )
        FROM dual' INTO l_return_val USING IN p_inventory_item_id,
                                   IN p_revision_id ,
                                   IN p_organization_id,
                                   IN p_lifecycle_id,
                                   IN p_new_phase_id ;

IF l_return_val = 'N' THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
ELSE
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := 1;
   FND_MESSAGE.set_name('EGO', 'EGO_FLOAT_ATTACH_EXIST');
   x_msg_data := FND_MESSAGE.GET;
END IF;

END;
END ego_dom_util_pub;

/
