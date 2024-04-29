--------------------------------------------------------
--  DDL for Package ZX_GET_TAX_PARAM_DRIVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_GET_TAX_PARAM_DRIVER_PKG" AUTHID CURRENT_USER AS
/* $Header: zxifgetparampkgs.pls 120.2 2005/09/20 14:34:47 hvsingh ship $ */

PROCEDURE get_driver_value
(
p_struct_name         IN   VARCHAR2,
p_struct_index        IN   BINARY_INTEGER,
p_tax_param_code      IN   VARCHAR2,
x_tax_param_value     OUT  NOCOPY NUMBER,
x_return_status       OUT  NOCOPY VARCHAR2
);

PROCEDURE get_driver_value
(
p_struct_name         IN   VARCHAR2,
p_struct_index        IN   BINARY_INTEGER,
p_tax_param_code      IN   VARCHAR2,
x_tax_param_value     OUT  NOCOPY DATE,
x_return_status       OUT  NOCOPY VARCHAR2
);

PROCEDURE get_driver_value
(
p_struct_name         IN   VARCHAR2,
p_struct_index        IN   BINARY_INTEGER,
p_tax_param_code      IN   VARCHAR2,
x_tax_param_value     OUT  NOCOPY VARCHAR2,
x_return_status       OUT  NOCOPY VARCHAR2
);

END zx_get_tax_param_driver_pkg;


 

/
