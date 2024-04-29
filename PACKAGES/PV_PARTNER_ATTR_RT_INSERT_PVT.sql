--------------------------------------------------------
--  DDL for Package PV_PARTNER_ATTR_RT_INSERT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PARTNER_ATTR_RT_INSERT_PVT" AUTHID CURRENT_USER as
/* $Header: pvxptais.pls 120.0 2005/05/27 15:33:22 appldev noship $ */


/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    private procedure declaration                                  */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/



g_search_attr_values_id   dbms_sql.number_table;
g_party_id                dbms_sql.number_table;
g_attribute_id            dbms_sql.number_table;
g_attr_text               dbms_sql.varchar2_table;
g_creation_date           dbms_sql.date_table;
g_created_by              dbms_sql.number_table;
g_last_update_date        dbms_sql.date_table;
g_last_updated_by         dbms_sql.number_table;
g_last_update_login       dbms_sql.number_table;
g_object_version_number   dbms_sql.number_table;



PROCEDURE partner_attr_insert (
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_partner_id             IN   NUMBER,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2
    );

END  PV_PARTNER_ATTR_RT_INSERT_PVT;

 

/
