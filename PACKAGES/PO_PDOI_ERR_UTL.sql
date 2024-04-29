--------------------------------------------------------
--  DDL for Package PO_PDOI_ERR_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_ERR_UTL" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_ERR_UTL.pls 120.5 2006/01/31 10:03 jinwang noship $ */

PROCEDURE add_error
( p_interface_header_id          IN NUMBER,
  p_interface_line_id            IN NUMBER := NULL,
  p_interface_line_location_id   IN NUMBER := NULL,
  p_interface_distribution_id    IN NUMBER := NULL,
  p_price_diff_interface_id      IN NUMBER := NULL,
  p_interface_attr_values_id     IN NUMBER := NULL,
  p_interface_attr_values_tlp_id IN NUMBER := NULL,
  p_app_name                     IN VARCHAR2 := NULL,
  p_error_message_name           IN VARCHAR2 := NULL,
  p_table_name                   IN VARCHAR2 := NULL,
  p_column_name                  IN VARCHAR2 ,  -- TODO: Default to NULL later
  p_column_value                 IN VARCHAR2 ,  -- TODO: Default to NULL later
  p_token1_name                  IN VARCHAR2 := NULL,
  p_token1_value                 IN VARCHAR2 := NULL,
  p_token2_name                  IN VARCHAR2 := NULL,
  p_token2_value                 IN VARCHAR2 := NULL,
  p_token3_name                  IN VARCHAR2 := NULL,
  p_token3_value                 IN VARCHAR2 := NULL,
  p_token4_name                  IN VARCHAR2 := NULL,
  p_token4_value                 IN VARCHAR2 := NULL,
  p_token5_name                  IN VARCHAR2 := NULL,
  p_token5_value                 IN VARCHAR2 := NULL,
  p_token6_name                  IN VARCHAR2 := NULL,
  p_token6_value                 IN VARCHAR2 := NULL,
  p_error_message                IN VARCHAR2 := NULL
);


PROCEDURE add_warning
( p_interface_header_id          IN NUMBER,
  p_interface_line_id            IN NUMBER := NULL,
  p_interface_line_location_id   IN NUMBER := NULL,
  p_interface_distribution_id    IN NUMBER := NULL,
  p_price_diff_interface_id      IN NUMBER := NULL,
  p_interface_attr_values_id     IN NUMBER := NULL,
  p_interface_attr_values_tlp_id IN NUMBER := NULL,
  p_app_name                     IN VARCHAR2 := NULL,
  p_error_message_name           IN VARCHAR2 := NULL,
  p_table_name                   IN VARCHAR2 := NULL,
  p_column_name                  IN VARCHAR2 := NULL,
  p_column_value                 IN VARCHAR2 := NULL,
  p_token1_name                  IN VARCHAR2 := NULL,
  p_token1_value                 IN VARCHAR2 := NULL,
  p_token2_name                  IN VARCHAR2 := NULL,
  p_token2_value                 IN VARCHAR2 := NULL,
  p_token3_name                  IN VARCHAR2 := NULL,
  p_token3_value                 IN VARCHAR2 := NULL,
  p_token4_name                  IN VARCHAR2 := NULL,
  p_token4_value                 IN VARCHAR2 := NULL,
  p_token5_name                  IN VARCHAR2 := NULL,
  p_token5_value                 IN VARCHAR2 := NULL,
  p_token6_name                  IN VARCHAR2 := NULL,
  p_token6_value                 IN VARCHAR2 := NULL,
  p_error_message                IN VARCHAR2 := NULL
);

PROCEDURE add_fatal_error
( p_interface_header_id          IN NUMBER,
  p_interface_line_id            IN NUMBER := NULL,
  p_interface_line_location_id   IN NUMBER := NULL,
  p_interface_distribution_id    IN NUMBER := NULL,
  p_price_diff_interface_id      IN NUMBER := NULL,
  p_interface_attr_values_id     IN NUMBER := NULL,
  p_interface_attr_values_tlp_id IN NUMBER := NULL,
  p_app_name                     IN VARCHAR2 := NULL,
  p_error_message_name           IN VARCHAR2 := NULL,
  p_table_name                   IN VARCHAR2 := NULL,
  p_column_name                  IN VARCHAR2 := NULL,
  p_column_value                 IN VARCHAR2 := NULL,
  p_token1_name                  IN VARCHAR2 := NULL,
  p_token1_value                 IN VARCHAR2 := NULL,
  p_token2_name                  IN VARCHAR2 := NULL,
  p_token2_value                 IN VARCHAR2 := NULL,
  p_token3_name                  IN VARCHAR2 := NULL,
  p_token3_value                 IN VARCHAR2 := NULL,
  p_token4_name                  IN VARCHAR2 := NULL,
  p_token4_value                 IN VARCHAR2 := NULL,
  p_token5_name                  IN VARCHAR2 := NULL,
  p_token5_value                 IN VARCHAR2 := NULL,
  p_token6_name                  IN VARCHAR2 := NULL,
  p_token6_value                 IN VARCHAR2 := NULL,
  p_error_message                IN VARCHAR2 := NULL,
  p_validation_id                IN NUMBER := NULL,
  p_headers                      IN PO_PDOI_TYPES.headers_rec_type := NULL,
  p_lines                        IN PO_PDOI_TYPES.lines_rec_type := NULL,
  p_line_locs                    IN PO_PDOI_TYPES.line_locs_rec_type := NULL,
  p_distributions                IN PO_PDOI_TYPES.distributions_rec_type := NULL,
  p_price_diffs                  IN PO_PDOI_TYPES.price_diffs_rec_type := NULL
);

PROCEDURE process_val_type_errors
( x_results     IN OUT NOCOPY  po_validation_results_type,
  p_table_name  IN   VARCHAR2,
  p_headers     IN PO_PDOI_TYPES.headers_rec_type := NULL,
  p_lines       IN PO_PDOI_TYPES.lines_rec_type := NULL,
  p_line_locs   IN PO_PDOI_TYPES.line_locs_rec_type := NULL,
  p_distributions IN PO_PDOI_TYPES.distributions_rec_type := NULL,
  p_price_diffs IN PO_PDOI_TYPES.price_diffs_rec_type := NULL
);

PROCEDURE derive_parent_interface_ids
( p_table_name             IN VARCHAR2,
  p_table_id_tbl           IN PO_TBL_NUMBER,
  x_intf_header_id_tbl     OUT NOCOPY PO_TBL_NUMBER,
  x_intf_line_id_tbl       OUT NOCOPY PO_TBL_NUMBER,
  x_intf_line_loc_id_tbl   OUT NOCOPY PO_TBL_NUMBER,
  x_intf_dist_id_tbl       OUT NOCOPY PO_TBL_NUMBER,
  x_intf_price_diff_id_tbl OUT NOCOPY PO_TBL_NUMBER
);



END PO_PDOI_ERR_UTL;

 

/
