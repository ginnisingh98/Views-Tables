--------------------------------------------------------
--  DDL for Package ZX_TDS_RATE_DETM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_RATE_DETM_PKG" AUTHID CURRENT_USER AS
 /* $Header: zxditxratedtpkgs.pls 120.8 2003/12/19 03:51:31 ssekuri ship $ */


PROCEDURE GET_TAX_RATE(
 p_begin_index                IN  number,
 p_end_index                  IN  number,
-- p_detail_tax_line_tbl     IN OUT NOCOPY zx_api_pub.detail_tax_line_tbl_type,
 p_event_class_rec            IN  zx_api_pub.event_class_rec_type,
 p_structure_name             IN  VARCHAR2,
 p_structure_index            IN  BINARY_INTEGER,
 p_return_status              OUT NOCOPY VARCHAR2,
 p_error_buffer               OUT NOCOPY VARCHAR2);


PROCEDURE UPDATE_TAX_RATE(
--  p_detail_tax_line_tbl   in out nocopy   zx_api_pub.detail_tax_line_tbl_type,
  p_tax_line_index        in              number ,
  p_tax_rate_code         in              zx_lines.tax_rate_code%type,
  p_tax_rate              in              zx_lines.tax_rate%type,
  p_tax_rate_id           in              number,
  p_Rate_Type_Code             in              zx_rates_b.Rate_Type_Code%type);

END ZX_TDS_RATE_DETM_PKG;


 

/
