--------------------------------------------------------
--  DDL for Package INL_RULE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_RULE_GRP" AUTHID CURRENT_USER AS
/* $Header: INLGRULS.pls 120.0.12010000.2 2013/09/09 14:53:03 acferrei noship $ */
G_MODULE_NAME CONSTANT VARCHAR2(200):= 'INL.PLSQL.INL_RULE_GRP.';
G_PKG_NAME    CONSTANT VARCHAR2(30) := 'INL_RULE_GRP';
G_CONDITION_CUSTOM VARCHAR2(1);

FUNCTION Check_Condition(p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                         p_commit IN VARCHAR2 := FND_API.G_FALSE,
                         p_ship_header_id IN NUMBER,
                         p_rule_package_name IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

END INL_RULE_GRP;

/
