--------------------------------------------------------
--  DDL for Package CSTPPPOI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPPOI" AUTHID CURRENT_USER AS
/* $Header: CSTPPOIS.pls 120.1 2005/06/21 14:46:50 appldev ship $ */

PROCEDURE validate_cost_elements (
        x_interface_header_id   IN      NUMBER,
        x_no_of_rows            OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);

PROCEDURE validate_level_types (
        x_interface_header_id   IN      NUMBER,
        x_no_of_rows            OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);

PROCEDURE get_le_cg_id (
        x_interface_header_id   IN      NUMBER,
        x_cost_group_id         OUT NOCOPY     NUMBER,
        x_legal_entity          OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);

PROCEDURE get_ct_cm_id (
        x_interface_header_id   IN      NUMBER,
        x_legal_entity          IN      NUMBER,
        x_cost_type_id          OUT NOCOPY     NUMBER,
        x_primary_cost_method   OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);

PROCEDURE get_pac_id (
        x_interface_header_id   IN      NUMBER,
        x_legal_entity          IN      NUMBER,
        x_cost_type_id          IN     NUMBER,
        x_pac_period_id         OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);

PROCEDURE validate_item (
        x_interface_header_id   IN      NUMBER,
        x_cost_group_id         IN      NUMBER,
        x_item_id               OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);

PROCEDURE validate_cost (
        x_interface_header_id   IN      NUMBER,
        x_item_id               IN      NUMBER,
        x_pac_period_id         IN      NUMBER,
        x_cost_group_id         IN      NUMBER,
        x_no_of_rows            OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);

PROCEDURE validate_market_value (
        x_interface_header_id   IN      NUMBER,
        x_no_of_rows            OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);


PROCEDURE validate_justification (
        x_interface_header_id   IN      NUMBER,
        x_no_of_rows            OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);


PROCEDURE import_costs (
        x_interface_header_id   IN      NUMBER,
        x_user_id               IN      NUMBER,
        x_login_id              IN      NUMBER,
        x_req_id                IN      NUMBER,
        x_prg_appid             IN      NUMBER,
        x_prg_id                IN      NUMBER,
        x_no_of_rows            OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);

PROCEDURE derive_costs (
        x_interface_header_id   IN      NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);


END CSTPPPOI;

 

/
