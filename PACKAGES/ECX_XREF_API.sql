--------------------------------------------------------
--  DDL for Package ECX_XREF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_XREF_API" AUTHID CURRENT_USER as
/* $Header: ECXXRFAS.pls 120.2 2005/06/30 11:19:09 appldev ship $ */

PROCEDURE create_code_category(
  x_return_status       OUT    NOCOPY PLS_INTEGER,
  x_msg                 OUT    NOCOPY VARCHAR2,
  x_xref_hdr_id         OUT    NOCOPY PLS_INTEGER,
  p_xref_category_code  IN     VARCHAR2,
  p_description         IN     VARCHAR2,
  p_owner               IN     VARCHAR2 DEFAULT 'CUSTOM');

PROCEDURE delete_code_category(
  x_return_status       OUT    NOCOPY PLS_INTEGER,
  x_msg                 OUT    NOCOPY VARCHAR2,
  p_xref_category_id    IN     PLS_INTEGER);

PROCEDURE update_code_category(
  x_return_status       OUT   NOCOPY PLS_INTEGER,
  x_msg                 OUT   NOCOPY VARCHAR2,
  p_xref_category_id    IN    PLS_INTEGER,
  p_xref_category_code  IN    VARCHAR2,
  p_description         IN    VARCHAR2,
  p_owner               IN    VARCHAR2 DEFAULT 'CUSTOM');


PROCEDURE retrieve_tp_external_value(
  x_return_status       OUT  NOCOPY PLS_INTEGER,
  x_msg                 OUT  NOCOPY VARCHAR2,
  x_xref_ext_value      OUT  NOCOPY VARCHAR2,
  p_tp_header_id        IN   PLS_INTEGER,
  p_xref_category_code  IN   VARCHAR2,
  p_standard            IN   VARCHAR2,
  p_xref_int_value      IN   VARCHAR2,
  x_xref_dtl_id         OUT  NOCOPY PLS_INTEGER,
  p_standard_type       IN   VARCHAR2 DEFAULT 'XML');

PROCEDURE retrieve_tp_internal_value(
  x_return_status       OUT  NOCOPY PLS_INTEGER,
  x_msg                 OUT  NOCOPY VARCHAR2,
  x_xref_int_value      OUT  NOCOPY VARCHAR2,
  p_tp_header_id        IN   PLS_INTEGER,
  p_xref_category_code  IN   VARCHAR2,
  p_standard            IN   VARCHAR2,
  p_xref_ext_value      IN   VARCHAR2,
  x_xref_dtl_id         OUT  NOCOPY PLS_INTEGER,
  p_standard_type       IN   VARCHAR2 DEFAULT 'XML');

PROCEDURE retrieve_tp_code_values_by_id(
  x_return_status       OUT  NOCOPY PLS_INTEGER,
  x_msg                 OUT  NOCOPY VARCHAR2,
  x_xref_category_code  OUT  NOCOPY VARCHAR2,
  x_standard_code       OUT  NOCOPY VARCHAR2,
  x_xref_ext_value      OUT  NOCOPY VARCHAR2,
  x_xref_int_value      OUT  NOCOPY VARCHAR2,
  x_direction           OUT  NOCOPY VARCHAR2,
  p_xref_dtl_id         IN   PLS_INTEGER,
  x_cat_description     OUT  NOCOPY VARCHAR2,
  x_xref_category_id    OUT  NOCOPY NUMBER,
  x_standard_id         OUT  NOCOPY PLS_INTEGER,
  x_tp_header_id        OUT  NOCOPY PLS_INTEGER,
  x_description         OUT  NOCOPY VARCHAR2,
  x_created_by          OUT  NOCOPY PLS_INTEGER,
  x_creation_date       OUT  NOCOPY DATE,
  x_last_updated_by     OUT  NOCOPY PLS_INTEGER,
  x_last_update_date    OUT  NOCOPY DATE);

PROCEDURE retrieve_tp_code_values(
  x_return_status       OUT  NOCOPY PLS_INTEGER,
  x_msg                 OUT  NOCOPY VARCHAR2,
  x_xref_dtl_id         OUT  NOCOPY PLS_INTEGER,
  x_xref_category_id    OUT  NOCOPY PLS_INTEGER,
  p_xref_category_code  IN   VARCHAR2,
  p_standard            IN   VARCHAR2,
  p_xref_ext_value      IN   VARCHAR2,
  p_xref_int_value      IN   VARCHAR2,
  p_direction           IN   VARCHAR2,
  x_cat_description     OUT  NOCOPY VARCHAR2,
  x_standard_id         OUT  NOCOPY PLS_INTEGER,
  x_tp_header_id        OUT  NOCOPY PLS_INTEGER,
  x_description         OUT  NOCOPY VARCHAR2,
  x_created_by          OUT  NOCOPY PLS_INTEGER,
  x_creation_date       OUT  NOCOPY DATE,
  x_last_updated_by     OUT  NOCOPY PLS_INTEGER,
  x_last_update_date    OUT  NOCOPY DATE,
  p_standard_type       IN   VARCHAR2 DEFAULT 'XML');

PROCEDURE create_tp_code_values(
  x_return_status       OUT   NOCOPY PLS_INTEGER,
  x_msg                 OUT   NOCOPY VARCHAR2,
  x_xref_dtl_id         OUT   NOCOPY PLS_INTEGER,
  x_xref_category_id    OUT   NOCOPY PLS_INTEGER,
  p_xref_category_code  IN    VARCHAR2,
  p_standard            IN    VARCHAR2,
  p_tp_header_id        IN    PLS_INTEGER,
  p_xref_ext_value      IN    VARCHAR2,
  p_xref_int_value      IN    VARCHAR2,
  p_description         IN    VARCHAR2,
  p_direction           IN    VARCHAR2,
  p_standard_type       IN   VARCHAR2 DEFAULT 'XML');

PROCEDURE update_tp_code_values(
  x_return_status      OUT    NOCOPY PLS_INTEGER,
  x_msg                OUT    NOCOPY VARCHAR2,
  p_xref_dtl_id        IN     PLS_INTEGER,
  p_xref_ext_value     IN     VARCHAR2,
  p_xref_int_value     IN     VARCHAR2,
  p_tp_header_id       IN     PLS_INTEGER,
  p_description        IN     VARCHAR2,
  p_direction          IN     VARCHAR2);

PROCEDURE delete_tp_code_values(
  x_return_status      OUT    NOCOPY PLS_INTEGER,
  x_msg                OUT    NOCOPY VARCHAR2,
  p_xref_dtl_id        IN     PLS_INTEGER);

PROCEDURE retrieve_standard_code_values(
  x_return_status      OUT  NOCOPY PLS_INTEGER,
  x_msg                OUT  NOCOPY VARCHAR2,
  x_xref_std_id        OUT  NOCOPY PLS_INTEGER,
  x_xref_category_id   OUT  NOCOPY PLS_INTEGER,
  p_xref_category_code IN   VARCHAR2,
  p_standard           IN   VARCHAR2,
  p_xref_std_value     IN   VARCHAR2,
  p_xref_int_value     IN   VARCHAR2,
  x_cat_description    OUT  NOCOPY VARCHAR2,
  x_standard_id        OUT  NOCOPY PLS_INTEGER,
  x_description        OUT  NOCOPY VARCHAR2,
  x_data_seeded        OUT  NOCOPY VARCHAR2,
  x_created_by         OUT  NOCOPY PLS_INTEGER,
  x_creation_date      OUT  NOCOPY DATE,
  x_last_updated_by    OUT  NOCOPY PLS_INTEGER,
  x_last_update_date   OUT  NOCOPY DATE,
  p_standard_type       IN   VARCHAR2 DEFAULT 'XML');


PROCEDURE create_standard_code_values(
  x_return_status       OUT     NOCOPY PLS_INTEGER,
  x_msg                 OUT     NOCOPY VARCHAR2,
  x_xref_std_id         OUT     NOCOPY PLS_INTEGER,
  x_xref_category_id    OUT     NOCOPY PLS_INTEGER,
  p_xref_category_code  IN      VARCHAR2,
  p_standard            IN      VARCHAR2,
  p_xref_std_value      IN      VARCHAR2,
  p_xref_int_value      IN      VARCHAR2,
  p_description         IN      VARCHAR2,
  p_data_seeded         IN      VARCHAR2  DEFAULT 'N',
  p_owner               IN      VARCHAR2  DEFAULT 'CUSTOM',
  p_standard_type       IN      VARCHAR2  DEFAULT 'XML'
);

PROCEDURE update_standard_code_values(
  x_return_status     OUT  NOCOPY PLS_INTEGER,
  x_msg               OUT  NOCOPY VARCHAR2,
  p_xref_standard_id  IN   PLS_INTEGER,
  p_xref_std_value    IN   VARCHAR2,
  p_xref_int_value    IN   VARCHAR2,
  p_description       IN   VARCHAR2,
  p_owner             IN   VARCHAR2 DEFAULT 'CUSTOM'
);

PROCEDURE delete_standard_code_values(
  x_return_status     OUT  NOCOPY PLS_INTEGER,
  x_msg               OUT  NOCOPY VARCHAR2,
  p_xref_standard_id  IN   PLS_INTEGER
);

end ECX_XREF_API;

 

/
