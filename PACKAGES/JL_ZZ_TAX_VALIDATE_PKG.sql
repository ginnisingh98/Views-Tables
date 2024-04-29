--------------------------------------------------------
--  DDL for Package JL_ZZ_TAX_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_TAX_VALIDATE_PKG" AUTHID CURRENT_USER as
/* $Header: jlzzdefvalpkgs.pls 120.5.12010000.1 2008/07/31 04:24:17 appldev ship $ */

PROCEDURE default_and_validate_tax_attr(
                  p_api_version      IN            NUMBER,
                  p_init_msg_list    IN            VARCHAR2,
                  p_commit           IN            VARCHAR2,
                  p_validation_level IN            VARCHAR2,
                  x_return_status       OUT NOCOPY VARCHAR2,
                  x_msg_count           OUT NOCOPY NUMBER,
                  x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE default_tax_attr  (
                             x_return_status       OUT NOCOPY VARCHAR2);

PROCEDURE validate_tax_attr (x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE default_tax_attr  (p_trx_line_index      IN  NUMBER,
                             x_return_status       OUT NOCOPY VARCHAR2);

END jl_zz_tax_validate_pkg;

/
