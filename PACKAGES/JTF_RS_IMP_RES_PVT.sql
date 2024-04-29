--------------------------------------------------------
--  DDL for Package JTF_RS_IMP_RES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_IMP_RES_PVT" AUTHID CURRENT_USER AS
  /* $Header: jtfrsvus.pls 120.1 2005/06/07 23:05:02 baianand ship $ */

  TYPE imp_rec_type IS RECORD (
    role_id                jtf_rs_roles_b.role_id%TYPE,
    rs_start_date_active   jtf_rs_resource_extns.start_date_active%TYPE,
    rs_end_date_active     jtf_rs_resource_extns.end_date_active%TYPE,
    role_start_date_active jtf_rs_role_relations.start_date_active%TYPE,
    role_end_date_active   jtf_rs_role_relations.end_date_active%TYPE,
    sales_credit_type_id   jtf_rs_salesreps.sales_credit_type_id%TYPE,
    org_id                 jtf_rs_salesreps.org_id%TYPE,
    resource_id            jtf_rs_resource_extns.resource_id%TYPE,
    category               jtf_rs_resource_extns.category%TYPE,
    person_id              jtf_rs_resource_extns.source_id%TYPE,
    contact_id             jtf_rs_resource_extns.contact_id%TYPE,
    user_id                jtf_rs_resource_extns.user_id%TYPE,
    name                   jtf_rs_resource_extns.source_name%TYPE,
    user_name              jtf_rs_resource_extns.user_name%TYPE,
    address_id             jtf_rs_resource_extns.address_id%TYPE,
    salesperson_number     jtf_rs_salesreps.salesrep_number%TYPE,
    selected               VARCHAR2(1),
    comment_code           VARCHAR2(30),
    create_salesperson     VARCHAR2(1)
  );

  TYPE imp_tbl_type IS TABLE OF imp_rec_type
  INDEX BY BINARY_INTEGER;

  TYPE res_id_rec_type IS RECORD (
    res_id            jtf_rs_resource_extns.resource_id%TYPE
  );

  TYPE res_id_tbl_type is TABLE OF res_id_rec_type
  INDEX BY BINARY_INTEGER;

  PROCEDURE import_resources (
   P_API_VERSION     IN   NUMBER,
   P_INIT_MSG_LIST   IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT          IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_IMP_RES_TBL     IN   imp_tbl_type,
   X_RES_ID_TBL      OUT NOCOPY res_id_tbl_type,
   X_TRANSACTION_NUM OUT NOCOPY NUMBER,
   X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
   X_MSG_COUNT       OUT NOCOPY NUMBER,
   X_MSG_DATA        OUT NOCOPY VARCHAR2
  );

END jtf_rs_imp_res_pvt;

 

/
