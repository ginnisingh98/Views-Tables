--------------------------------------------------------
--  DDL for Package ZX_TCM_TAX_RATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TCM_TAX_RATE_PKG" AUTHID CURRENT_USER AS
/* $Header: zxctaxratespkgs.pls 120.1 2005/09/02 00:00:34 lxzhang ship $ */

PROCEDURE get_tax_rate(
  p_event_class_rec              IN  ZX_API_PUB.event_class_rec_type,
  p_tax_regime_code              IN  ZX_RATES_B.tax_regime_code%TYPE,
  p_tax_jurisdiction_code        IN  ZX_RATES_B.tax_jurisdiction_code%TYPE,
  p_tax                          IN  ZX_RATES_B.tax%TYPE,
  p_tax_date                     IN  DATE,
  p_tax_status_code              IN  ZX_RATES_B.tax_status_code%TYPE,
  p_tax_rate_code                IN  ZX_RATES_B.tax_rate_code%TYPE,
  p_place_of_supply_type_code    IN  ZX_LINES.place_of_supply_type_code%TYPE,
  p_structure_index              IN  NUMBER,
  p_multiple_jurisdictions_flag  IN  VARCHAR2,
  x_tax_rate_rec                 OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status                OUT NOCOPY VARCHAR2
);

END ZX_TCM_TAX_RATE_PKG;



 

/
