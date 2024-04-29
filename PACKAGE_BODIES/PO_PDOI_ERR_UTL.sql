--------------------------------------------------------
--  DDL for Package Body PO_PDOI_ERR_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_ERR_UTL" AS
/* $Header: PO_PDOI_ERR_UTL.plb 120.9.12010000.3 2011/09/07 11:08:32 dtoshniw ship $ */


d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_ERR_UTL');

g_APP_PO CONSTANT VARCHAR2(30) := 'PO';

--------------------------------------------------------------------------
---------------------- PRIVATE PROCEDURES PROTOTYPE ----------------------
--------------------------------------------------------------------------

PROCEDURE map_error_message
(
  p_validation_id                IN NUMBER,
  p_headers                      IN PO_PDOI_TYPES.headers_rec_type := NULL,
  p_lines                        IN PO_PDOI_TYPES.lines_rec_type := NULL,
  p_line_locs                    IN PO_PDOI_TYPES.line_locs_rec_type := NULL,
  p_price_diffs                  IN PO_PDOI_TYPES.price_diffs_rec_type := NULL,
  p_table_name                   IN VARCHAR2 := NULL,
  p_interface_header_id          IN NUMBER,
  p_interface_line_id            IN NUMBER := NULL,
  p_interface_line_location_id   IN NUMBER := NULL,
  p_price_diff_interface_id      IN NUMBER := NULL,
  x_mapping_exists               OUT NOCOPY VARCHAR2,
  x_mapped_err_msg               OUT NOCOPY PO_MSG_MAPPING_UTL.msg_rec_type
);

FUNCTION get_value_from_key
(
  p_key                          IN VARCHAR2,
  p_headers                      IN PO_PDOI_TYPES.headers_rec_type := NULL,
  p_lines                        IN PO_PDOI_TYPES.lines_rec_type := NULL,
  p_line_locs                    IN PO_PDOI_TYPES.line_locs_rec_type := NULL,
  p_price_diffs                  IN PO_PDOI_TYPES.price_diffs_rec_type := NULL,
  p_table_name                   IN VARCHAR2 := NULL,
  p_interface_header_id          IN NUMBER,
  p_interface_line_id            IN NUMBER := NULL,
  p_interface_line_location_id   IN NUMBER := NULL,
  p_price_diff_interface_id      IN NUMBER := NULL
) RETURN VARCHAR2;

-------------------------------------------------------
-------------- PUBLIC PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: add_error
--Function:
--  Add an error to the strucutre. The structure will eventually gets
--  flushed to PO_INTERFACE_ERRORS table.
--Parameters:
--IN:
--p_app_name
--  Application where the error message is defined in. If none is passed,
--  'PO' will be assumed
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
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
  p_column_name                  IN VARCHAR2 ,  -- TODO: Default to Null later
  p_column_value                 IN VARCHAR2 ,  -- TODO: Default to Null later
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
) IS

d_api_name CONSTANT VARCHAR2(30) := 'add_error';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_rec PO_INTERFACE_ERRORS%ROWTYPE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  l_rec.interface_type := 'PO_DOCS_OPEN_INTERFACE';
  l_rec.interface_header_id := p_interface_header_id;
  l_rec.interface_line_id := p_interface_line_id;
  l_rec.interface_line_location_id := p_interface_line_location_id;
  l_rec.interface_distribution_id := p_interface_distribution_id;
  l_rec.interface_attr_values_id := p_interface_attr_values_id;
  l_rec.interface_attr_values_tlp_id := p_interface_attr_values_tlp_id;
  l_rec.price_diff_interface_id := p_price_diff_interface_id; -- bug 5215781
  l_rec.app_name := NVL(p_app_name, g_APP_PO);
  l_rec.error_message_name := p_error_message_name;
  l_rec.table_name := p_table_name;
  l_rec.column_name := p_column_name;
  l_rec.column_value := p_column_value;
   --bug 12812134: truncating the values assigned to token values to 200,
   --              the column size of token values in po_interface_errors.
  l_rec.token1_name := p_token1_name;
  l_rec.token1_value := SubStr(p_token1_value,1,200);
  l_rec.token2_name := p_token2_name;
  l_rec.token2_value := SubStr(p_token2_value,1,200);
  l_rec.token3_name := p_token3_name;
  l_rec.token3_value := SubStr(p_token3_value,1,200);
  l_rec.token4_name := p_token4_name;
  l_rec.token4_value := SubStr(p_token4_value,1,200);
  l_rec.token5_name := p_token5_name;
  l_rec.token5_value := SubStr(p_token5_value,1,200);
  l_rec.token6_name := p_token6_name;
  l_rec.token6_value := SubStr(p_token6_value,1,200);
  l_rec.error_message := p_error_message;  -- bug5385342

  /* Bug 9918507 start
  Batch_id was not getting populated in the po_interface_errors
  even though it was entered in po_headers_interface.
  Query for batch_id using interface_header_id and populate l_rec.batch_id
  with that value*/
  SELECT batch_id
  INTO l_rec.batch_id
  FROM po_headers_interface
  WHERE interface_header_id = p_interface_header_id;
  /* Bug 9918507 end*/

  PO_INTERFACE_ERRORS_UTL.add_to_errors_tbl
  ( p_err_type => 'FATAL',
    p_err_rec  => l_rec
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END add_error;

-----------------------------------------------------------------------
--Start of Comments
--Name: add_warning
--Function:
--  Add a warning to the strucutre. The structure will eventually gets
--  flushed to PO_INTERFACE_ERRORS table.
--Parameters:
--IN:
--p_app_name
--  Application where the error message is defined in. If none is passed,
--  'PO' will be assumed
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
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
) IS
d_api_name CONSTANT VARCHAR2(30) := 'add_warning';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_rec PO_INTERFACE_ERRORS%ROWTYPE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  l_rec.interface_type := 'PO_DOCS_OPEN_INTERFACE';
  l_rec.interface_header_id := p_interface_header_id;
  l_rec.interface_line_id := p_interface_line_id;
  l_rec.interface_line_location_id := p_interface_line_location_id;
  l_rec.interface_distribution_id := p_interface_distribution_id;
  l_rec.interface_attr_values_id := p_interface_attr_values_id;
  l_rec.interface_attr_values_tlp_id := p_interface_attr_values_tlp_id;
  l_rec.price_diff_interface_id := p_price_diff_interface_id; -- bug 5215781
  l_rec.app_name := NVL(p_app_name, g_APP_PO);
  l_rec.error_message_name := p_error_message_name;
  l_rec.table_name := p_table_name;
  l_rec.column_name := p_column_name;
  l_rec.column_value := p_column_value;
   --bug 12812134: truncating the values assigned to token values to 200,
   --              the column size of token values in po_interface_errors.
  l_rec.token1_name := p_token1_name;
  l_rec.token1_value := SubStr(p_token1_value,1,200);
  l_rec.token2_name := p_token2_name;
  l_rec.token2_value := SubStr(p_token2_value,1,200);
  l_rec.token3_name := p_token3_name;
  l_rec.token3_value := SubStr(p_token3_value,1,200);
  l_rec.token4_name := p_token4_name;
  l_rec.token4_value := SubStr(p_token4_value,1,200);
  l_rec.token5_name := p_token5_name;
  l_rec.token5_value := SubStr(p_token5_value,1,200);
  l_rec.token6_name := p_token6_name;
  l_rec.token6_value := SubStr(p_token6_value,1,200);
  l_rec.error_message := p_error_message; -- bug5385342

  d_position := 10;

  PO_INTERFACE_ERRORS_UTL.add_to_errors_tbl
  ( p_err_type => 'WARNING',
    p_err_rec  => l_rec
  );

  d_position := 20;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END add_warning;

-----------------------------------------------------------------------
--Start of Comments
--Name: add_fatal_error
--Function:
--  insert an error to the strucutre. The structure will eventually gets
--  flushed to PO_INTERFACE_ERRORS table. But the error may be mapped
--  to a new message before the actual insert happens accoring to its
--  context and validation content.
--Parameters:
--IN:
--p_app_name
--  Application where the error message is defined in. If none is passed,
--  'PO' will be assumed
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
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
) IS

d_api_name CONSTANT VARCHAR2(30) := 'add_fatal_error';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_mapping_exists VARCHAR2(1) := FND_API.G_FALSE;
l_mapped_err_msg PO_MSG_MAPPING_UTL.msg_rec_type;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_validation_id IS NOT NULL) THEN
    -- check whether the message needs to be mapped
    map_error_message(
      p_validation_id       => p_validation_id,
      p_headers             => p_headers,
      p_lines               => p_lines,
      p_line_locs           => p_line_locs,
      p_price_diffs         => p_price_diffs,
      p_table_name          => p_table_name,
      p_interface_header_id => p_interface_header_id,
      p_interface_line_id => p_interface_line_id,
      p_interface_line_location_id => p_interface_line_location_id,
      p_price_diff_interface_id => p_price_diff_interface_id,
      x_mapping_exists => l_mapping_exists,
      x_mapped_err_msg => l_mapped_err_msg
    );
  END IF;

  -- after checking, we know that if message needs to be transformed,
  -- l_mapping_err_msg will contain the new messages; Otherwise,
  -- l_mapping_err_msg will be empty
  -- In the following code, we copy the original message values to
  -- l_mapping_err_msg if mapping does not happen; so that the message
  -- contained in l_mapping_err_msg can be added to the error table
  IF (l_mapping_exists = FND_API.G_FALSE) THEN
    l_mapped_err_msg.app_name := p_app_name;
    l_mapped_err_msg.message_name := p_error_message_name;
    l_mapped_err_msg.column_name := p_column_name;
    l_mapped_err_msg.column_value := p_column_value;
    l_mapped_err_msg.token1_name := p_token1_name;
    l_mapped_err_msg.token1_value := p_token1_value;
    l_mapped_err_msg.token2_name := p_token2_name;
    l_mapped_err_msg.token2_value := p_token2_value;
    l_mapped_err_msg.token3_name := p_token3_name;
    l_mapped_err_msg.token3_value := p_token3_value;
    l_mapped_err_msg.token4_name := p_token4_name;
    l_mapped_err_msg.token4_value := p_token4_value;
    l_mapped_err_msg.token5_name := p_token5_name;
    l_mapped_err_msg.token5_value := p_token5_value;
    l_mapped_err_msg.token6_name := p_token6_name;
    l_mapped_err_msg.token6_value := p_token6_value;
  END IF;

  add_error(
    p_interface_header_id        => p_interface_header_id,
    p_interface_line_id          => p_interface_line_id,
    p_interface_line_location_id => p_interface_line_location_id,
    p_interface_distribution_id  => p_interface_distribution_id,
    p_price_diff_interface_id    => p_price_diff_interface_id,
    p_app_name                   => l_mapped_err_msg.app_name,
    p_error_message_name         => l_mapped_err_msg.message_name,
    p_table_name                 => p_table_name,
    p_column_name                => l_mapped_err_msg.column_name,
    p_column_value               => l_mapped_err_msg.column_value,
    p_token1_name                => l_mapped_err_msg.token1_name,
    p_token1_value               => l_mapped_err_msg.token1_value,
    p_token2_name                => l_mapped_err_msg.token2_name,
    p_token2_value               => l_mapped_err_msg.token2_value,
    p_token3_name                => l_mapped_err_msg.token3_name,
    p_token3_value               => l_mapped_err_msg.token3_value,
    p_token4_name                => l_mapped_err_msg.token4_name,
    p_token4_value               => l_mapped_err_msg.token4_value,
    p_token5_name                => l_mapped_err_msg.token5_name,
    p_token5_value               => l_mapped_err_msg.token5_value,
    p_token6_name                => l_mapped_err_msg.token6_name,
    p_token6_value               => l_mapped_err_msg.token6_value,
    p_error_message              => p_error_message -- bug5385342
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END add_fatal_error;

-----------------------------------------------------------------------
--Start of Comments
--Name: process_val_type_errors
--Function:
--  Procedure to process the PDOI Validation results.
--Parameters:
--IN:
--x_results    - po_validation_results_type
--p_table_name - values include: PO_PDOI_CONSTANTS.g_PO_HEADERS_INTERFACE
--                               PO_PDOI_CONSTANTS.g_PO_LINES_INTERFACE
--                               PO_PDOI_CONSTANTS.g_PO_LINE_LOCATIONS_INTERFACE
--                               PO_PDOI_CONSTANTS.g_PO_DISTRIBUTIONS_INTERFACE
--                               PO_PDOI_CONSTANTS.g_PO_PRICE_DIFF_INTERFACE
--
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_val_type_errors
( x_results     IN OUT NOCOPY  po_validation_results_type,
  p_table_name  IN   VARCHAR2,
  p_headers     IN PO_PDOI_TYPES.headers_rec_type := NULL,
  p_lines       IN PO_PDOI_TYPES.lines_rec_type := NULL,
  p_line_locs   IN PO_PDOI_TYPES.line_locs_rec_type := NULL,
  p_distributions IN PO_PDOI_TYPES.distributions_rec_type := NULL,
  p_price_diffs IN PO_PDOI_TYPES.price_diffs_rec_type := NULL
)
IS

l_intf_header_id_tbl       PO_TBL_NUMBER := PO_TBL_NUMBER();
l_intf_line_id_tbl         PO_TBL_NUMBER := PO_TBL_NUMBER();
l_intf_line_loc_id_tbl     PO_TBL_NUMBER := PO_TBL_NUMBER();
l_intf_dist_id_tbl         PO_TBL_NUMBER := PO_TBL_NUMBER();
l_intf_price_diff_id_tbl   PO_TBL_NUMBER := PO_TBL_NUMBER();

d_api_name CONSTANT VARCHAR2(30) := 'process_val_type_errors';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_mapping_exists VARCHAR2(1);
l_mapped_err_msg PO_MSG_MAPPING_UTL.msg_rec_type;
l_app_name VARCHAR2(30) := NULL;
BEGIN
    d_position := 0;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_begin(d_module, 'table_name', p_table_name);
    END IF;

    l_intf_header_id_tbl.extend(x_results.entity_id.COUNT);
    l_intf_line_id_tbl.extend(x_results.entity_id.COUNT);
    l_intf_line_loc_id_tbl.extend(x_results.entity_id.COUNT);
    l_intf_dist_id_tbl.extend(x_results.entity_id.COUNT);
    l_intf_price_diff_id_tbl.extend(x_results.entity_id.COUNT);

    d_position := 10;

    derive_parent_interface_ids
    ( p_table_name               => p_table_name,
      p_table_id_tbl             => x_results.entity_id,
      x_intf_header_id_tbl       => l_intf_header_id_tbl,
      x_intf_line_id_tbl         => l_intf_line_id_tbl,
      x_intf_line_loc_id_tbl     => l_intf_line_loc_id_tbl,
      x_intf_dist_id_tbl         => l_intf_dist_id_tbl,
      x_intf_price_diff_id_tbl   => l_intf_price_diff_id_tbl
    );

    d_position := 20;


    FOR i IN 1 .. x_results.entity_id.COUNT LOOP

      map_error_message
      ( p_validation_id => x_results.validation_id(i),
        p_headers => p_headers,
        p_lines => p_lines,
        p_line_locs => p_line_locs,
        p_price_diffs => p_price_diffs,
        p_table_name => p_table_name,
        p_interface_header_id => l_intf_header_id_tbl(i),
        p_interface_line_id => l_intf_line_id_tbl(i),
        p_interface_line_location_id => l_intf_line_loc_id_tbl(i),
        p_price_diff_interface_id => l_intf_price_diff_id_tbl(i),
        x_mapping_exists => l_mapping_exists,
        x_mapped_err_msg => l_mapped_err_msg
      );

      IF (l_mapping_exists = FND_API.G_TRUE) THEN

        -- If we need to transform the message, then copy the values from
        -- the returned record structure to x_results
        l_app_name := l_mapped_err_msg.app_name;
        x_results.message_name(i) := l_mapped_err_msg.message_name;
        x_results.column_name(i) := l_mapped_err_msg.column_name;
        x_results.column_val(i) := l_mapped_err_msg.column_value;
        x_results.token1_name(i) := l_mapped_err_msg.token1_name;
        x_results.token1_value(i) := l_mapped_err_msg.token1_value;
        x_results.token2_name(i) := l_mapped_err_msg.token2_name;
        x_results.token2_value(i) := l_mapped_err_msg.token2_value;
        x_results.token3_name(i) := l_mapped_err_msg.token3_name;
        x_results.token3_value(i) := l_mapped_err_msg.token3_value;
        x_results.token4_name(i) := l_mapped_err_msg.token4_name;
        x_results.token4_value(i) := l_mapped_err_msg.token4_value;
        x_results.token5_name(i) := l_mapped_err_msg.token5_name;
        x_results.token5_value(i) := l_mapped_err_msg.token5_value;
        x_results.token6_name(i) := l_mapped_err_msg.token6_name;
        x_results.token6_value(i) := l_mapped_err_msg.token6_value;

      END IF;

      IF x_results.result_type(i) = po_validations.c_result_type_failure THEN
         add_error(p_interface_header_id        => l_intf_header_id_tbl(i),
                   p_interface_line_id          => l_intf_line_id_tbl(i),
                   p_interface_line_location_id => l_intf_line_loc_id_tbl(i),
                   p_interface_distribution_id  => l_intf_dist_id_tbl(i),
                   p_price_diff_interface_id    => l_intf_price_diff_id_tbl(i),
                   p_app_name                   => l_app_name,
                   p_error_message_name         => x_results.message_name(i),
                   p_table_name                 => p_table_name,
                   p_column_name                => x_results.column_name(i),
                   p_column_value               => x_results.column_val(i),
                   p_token1_name                => x_results.token1_name(i),
                   p_token1_value               => x_results.token1_value(i),
                   p_token2_name                => x_results.token2_name(i),
                   p_token2_value               => x_results.token2_value(i),
                   p_token3_name                => x_results.token3_name(i),
                   p_token3_value               => x_results.token3_value(i),
                   p_token4_name                => x_results.token4_name(i),
                   p_token4_value               => x_results.token4_value(i),
                   p_token5_name                => x_results.token5_name(i),
                   p_token5_value               => x_results.token5_value(i),
                   p_token6_name                => x_results.token6_name(i),
                   p_token6_value               => x_results.token6_value(i));
      END IF;
    END LOOP;

    d_position := 30;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;

END process_val_type_errors;


-----------------------------------------------------------------------
--Start of Comments
--Name: derive_parent_interface_ids
--Function:
--  Procedure to derive the parent interface ids for a given entity
--Parameters:
--IN:
--p_table_name - values include: PO_PDOI_CONSTANTS.g_PO_HEADERS_INTERFACE
--                               PO_PDOI_CONSTANTS.g_PO_LINES_INTERFACE
--                               PO_PDOI_CONSTANTS.g_PO_LINE_LOCATIONS_INTERFACE
--                               PO_PDOI_CONSTANTS.g_PO_DISTRIBUTIONS_INTERFACE
--                               PO_PDOI_CONSTANTS.g_PO_PRICE_DIFF_INTERFACE
--
--p_table_id_tbl - Table of interface ids that correspond to the table name passed in
--
--IN OUT:
--OUT:
--x_intf_hdr_id_tbl        - Table of interface header ids
--x_intf_line_id_tbl       - Table of interface line ids
--x_intf_line_loc_id_tbl   - Table of interface line location ids
--x_intf_dist_id_tbl       - Table of interface distribution ids
--x_intf_price_diff_id_tbl - Table of interface price differential ids
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_parent_interface_ids
( p_table_name             IN VARCHAR2,
  p_table_id_tbl           IN PO_TBL_NUMBER,
  x_intf_header_id_tbl     OUT NOCOPY PO_TBL_NUMBER,
  x_intf_line_id_tbl       OUT NOCOPY PO_TBL_NUMBER,
  x_intf_line_loc_id_tbl   OUT NOCOPY PO_TBL_NUMBER,
  x_intf_dist_id_tbl       OUT NOCOPY PO_TBL_NUMBER,
  x_intf_price_diff_id_tbl OUT NOCOPY PO_TBL_NUMBER
) IS

l_key NUMBER;
l_seq PO_TBL_NUMBER := PO_TBL_NUMBER();

d_api_name CONSTANT VARCHAR2(30) := 'derive_parent_interface_ids';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_begin(d_module, 'table_name', p_table_name);
  END IF;

  x_intf_header_id_tbl       := PO_TBL_NUMBER();
  x_intf_line_id_tbl         := PO_TBL_NUMBER();
  x_intf_line_loc_id_tbl     := PO_TBL_NUMBER();
  x_intf_dist_id_tbl         := PO_TBL_NUMBER();
  x_intf_price_diff_id_tbl   := PO_TBL_NUMBER();

  l_key := PO_CORE_S.get_session_gt_nextval;

  l_seq.extend (p_table_id_tbl.COUNT);

  -- This will intialize all out variables to have correct size
  x_intf_header_id_tbl.extend(p_table_id_tbl.COUNT);
  x_intf_line_id_tbl.extend(p_table_id_tbl.COUNT);
  x_intf_line_loc_id_tbl.extend(p_table_id_tbl.COUNT);
  x_intf_dist_id_tbl.extend(p_table_id_tbl.COUNT);
  x_intf_price_diff_id_tbl.extend(p_table_id_tbl.COUNT);

  d_position := 10;

  FOR i IN 1..l_seq.COUNT LOOP
    -- define a sequence
    l_seq(i) := i;
  END LOOP;

  d_position := 20;

  FORALL i IN 1..p_table_id_tbl.COUNT
    INSERT INTO po_session_gt
    ( key, index_num1, num1 )
    VALUES
    (l_key, l_seq(i), p_table_id_tbl(i));

  d_position := 30;

  IF (p_table_name = PO_PDOI_CONSTANTS.g_PO_HEADERS_INTERFACE) THEN

    d_position := 40;

    SELECT PHI.interface_header_id
    BULK COLLECT
    INTO x_intf_header_id_tbl
    FROM po_session_gt PSG,
         po_headers_interface PHI
    WHERE PSG.key = l_key AND
          PSG.num1 = PHI.interface_header_id
    ORDER BY PSG.index_num1;

  ELSIF (p_table_name = PO_PDOI_CONSTANTS.g_PO_LINES_INTERFACE) THEN

    d_position := 50;

    SELECT PLI.interface_header_id,
           PLI.interface_line_id
    BULK COLLECT
    INTO  x_intf_header_id_tbl,
          x_intf_line_id_tbl
    FROM po_session_gt PSG,
         po_lines_interface PLI
    WHERE PSG.key = l_key
    AND PSG.num1 = PLI.interface_line_id
    ORDER BY PSG.index_num1;

  ELSIF (p_table_name = PO_PDOI_CONSTANTS.g_PO_LINE_LOCATIONS_INTERFACE) THEN

    d_position := 60;

    SELECT PLLI.interface_header_id,
           PLLI.interface_line_id,
           PLLI.interface_line_location_id
    BULK COLLECT
    INTO x_intf_header_id_tbl,
         x_intf_line_id_tbl,
         x_intf_line_loc_id_tbl
    FROM po_session_gt PSG,
         po_line_locations_interface PLLI
    WHERE PSG.key = l_key
    AND PSG.num1 = PLLI.interface_line_location_id
    ORDER BY PSG.index_num1;

  ELSIF (p_table_name = PO_PDOI_CONSTANTS.g_PO_DISTRIBUTIONS_INTERFACE) THEN

    d_position := 70;

    SELECT PDI.interface_header_id,
           PDI.interface_line_id,
           PDI.interface_line_location_id,
           PDI.interface_distribution_id
    BULK COLLECT
    INTO x_intf_header_id_tbl,
         x_intf_line_id_tbl,
         x_intf_line_loc_id_tbl,
         x_intf_dist_id_tbl
    FROM po_session_gt PSG,
         po_distributions_interface PDI
    WHERE PSG.key = l_key
    AND PSG.num1 = PDI.interface_distribution_id
    ORDER BY PSG.index_num1;

  ELSIF (p_table_name = PO_PDOI_CONSTANTS.g_PO_PRICE_DIFF_INTERFACE) THEN

    d_position := 80;

    SELECT PPDI.interface_header_id,
           PPDI.interface_line_id,
           PPDI.interface_line_location_id,
           PPDI.price_diff_interface_id
    BULK COLLECT
    INTO x_intf_header_id_tbl,
         x_intf_line_id_tbl,
         x_intf_line_loc_id_tbl,
         x_intf_price_diff_id_tbl
    FROM po_session_gt PSG,
         po_price_diff_interface PPDI
    WHERE PSG.key = l_key
    AND PSG.num1 = PPDI.price_diff_interface_id
    ORDER BY PSG.index_num1;

  END IF;

  d_position := 90;

  PO_PDOI_UTL.remove_session_gt_records(p_key => l_key);

  d_position := 100;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;

END derive_parent_interface_ids;

--------------------------------------------------------------------------
---------------------- PRIVATE PROCEDURES --------------------------------
--------------------------------------------------------------------------


-----------------------------------------------------------------------
--Start of Comments
--Name: map_error_message
--Function:
--  funtion to map error message thrown by validation framework to ip
--  specific error messages based on validation id
--Parameters:
--IN:
-- p_validation_id
--  unique identifier for each validation
-- p_headers
--  batch of header records in interface table
-- p_lines
--  batch of line records in interface table
-- p_line_locs
--  batch of location records in the interface table
-- p_price_diffs
--  batch of price differential records in the interface table
-- p_table_name
--  name of interface table which contains the errorous record
-- p_interface_header_id
--  corresponding interface_header_id of the error record
-- p_interface_line_id
--  corresponding interface_line_id of the error record
-- p_interface_line_location_id
--  corresponding interface_line_location_id of the error record
-- p_price_diff_interface_id
--  corresponding price_diff_interface_id of the error record
--IN OUT:
--OUT:
-- x_mapping_exists
--  FND_API.G_TRUE if mapping exists, FND_API.G_FALSE otherwise
-- x_mapped_err_msg
--  Message that gets returned from the mapping
--End of Comments
------------------------------------------------------------------------
PROCEDURE map_error_message
(
  p_validation_id                IN NUMBER,
  p_headers                      IN PO_PDOI_TYPES.headers_rec_type := NULL,
  p_lines                        IN PO_PDOI_TYPES.lines_rec_type := NULL,
  p_line_locs                    IN PO_PDOI_TYPES.line_locs_rec_type := NULL,
  p_price_diffs                  IN PO_PDOI_TYPES.price_diffs_rec_type := NULL,
  p_table_name                   IN VARCHAR2 := NULL,
  p_interface_header_id          IN NUMBER,
  p_interface_line_id            IN NUMBER := NULL,
  p_interface_line_location_id   IN NUMBER := NULL,
  p_price_diff_interface_id      IN NUMBER := NULL,
  x_mapping_exists               OUT NOCOPY VARCHAR2,
  x_mapped_err_msg               OUT NOCOPY PO_MSG_MAPPING_UTL.msg_rec_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'map_error_message';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;


BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_begin(d_module, 'p_validation_id', p_validation_id);
     PO_LOG.proc_begin(d_module, 'p_table_name', p_table_name);
     PO_LOG.proc_begin(d_module, 'p_interface_header_id', p_interface_header_id);
     PO_LOG.proc_begin(d_module, 'p_interface_line_id', p_interface_line_id);
     PO_LOG.proc_begin(d_module, 'p_interface_line_location_id',
	                   p_interface_line_location_id);
     PO_LOG.proc_begin(d_module, 'p_price_diff_interface_id',
	                   p_price_diff_interface_id);
  END IF;

  -- find the message mapping, if it exists
  PO_MSG_MAPPING_UTL.find_msg
  ( p_context    => PO_PDOI_PARAMS.g_request.calling_module,
    p_id         => p_validation_id,
    x_msg_exists => x_mapping_exists,
    x_msg_rec    => x_mapped_err_msg
  );

  -- check whether mapping exists
  IF (x_mapping_exists = FND_API.G_FALSE) THEN
    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module, 'no mapping exists for validation id ',
	                  p_validation_id);
    END IF;

    RETURN;
  END IF;

  -- get column value
  IF (x_mapped_err_msg.column_value_key IS NOT NULL) THEN
    x_mapped_err_msg.column_value :=
      get_value_from_key
      (
        p_key => x_mapped_err_msg.column_value_key,
        p_headers => p_headers,
        p_lines => p_lines,
        p_line_locs => p_line_locs,
        p_price_diffs => p_price_diffs,
        p_table_name => p_table_name,
        p_interface_header_id => p_interface_header_id,
        p_interface_line_id => p_interface_line_id,
        p_interface_line_location_id => p_interface_line_location_id,
        p_price_diff_interface_id => p_price_diff_interface_id
      );

  END IF;

  -- get token values
  FOR i IN 1..x_mapped_err_msg.num_of_tokens
  LOOP
    CASE i
      WHEN 1 THEN
        IF (x_mapped_err_msg.token1_value_key <>
            x_mapped_err_msg.column_value_key) THEN
          x_mapped_err_msg.token1_value :=
            get_value_from_key
            (
              p_key => x_mapped_err_msg.token1_value_key,
              p_headers => p_headers,
              p_lines => p_lines,
              p_line_locs => p_line_locs,
              p_price_diffs => p_price_diffs,
              p_table_name => p_table_name,
              p_interface_header_id => p_interface_header_id,
              p_interface_line_id => p_interface_line_id,
              p_interface_line_location_id => p_interface_line_location_id,
              p_price_diff_interface_id => p_price_diff_interface_id
            );
        ELSE
          x_mapped_err_msg.token1_value := x_mapped_err_msg.column_value;
        END IF;
      WHEN 2 THEN
        IF (x_mapped_err_msg.token2_value_key <>
            x_mapped_err_msg.column_value_key) THEN
          x_mapped_err_msg.token2_value :=
            get_value_from_key
            (
              p_key => x_mapped_err_msg.token2_value_key,
              p_headers => p_headers,
              p_lines => p_lines,
              p_line_locs => p_line_locs,
              p_price_diffs => p_price_diffs,
              p_table_name => p_table_name,
              p_interface_header_id => p_interface_header_id,
              p_interface_line_id => p_interface_line_id,
              p_interface_line_location_id => p_interface_line_location_id,
              p_price_diff_interface_id => p_price_diff_interface_id
            );
        ELSE
          x_mapped_err_msg.token2_value := x_mapped_err_msg.column_value;
        END IF;
      WHEN 3 THEN
        IF (x_mapped_err_msg.token3_value_key <>
            x_mapped_err_msg.column_value_key) THEN
          x_mapped_err_msg.token3_value :=
            get_value_from_key
            (
              p_key => x_mapped_err_msg.token3_value_key,
              p_headers => p_headers,
              p_lines => p_lines,
              p_line_locs => p_line_locs,
              p_price_diffs => p_price_diffs,
              p_table_name => p_table_name,
              p_interface_header_id => p_interface_header_id,
              p_interface_line_id => p_interface_line_id,
              p_interface_line_location_id => p_interface_line_location_id,
              p_price_diff_interface_id => p_price_diff_interface_id
            );
        ELSE
          x_mapped_err_msg.token3_value := x_mapped_err_msg.column_value;
        END IF;
      WHEN 4 THEN
        IF (x_mapped_err_msg.token4_value_key <>
            x_mapped_err_msg.column_value_key) THEN
          x_mapped_err_msg.token4_value :=
            get_value_from_key
            (
              p_key => x_mapped_err_msg.token4_value_key,
              p_headers => p_headers,
              p_lines => p_lines,
              p_line_locs => p_line_locs,
              p_price_diffs => p_price_diffs,
              p_table_name => p_table_name,
              p_interface_header_id => p_interface_header_id,
              p_interface_line_id => p_interface_line_id,
              p_interface_line_location_id => p_interface_line_location_id,
              p_price_diff_interface_id => p_price_diff_interface_id
            );
        ELSE
          x_mapped_err_msg.token4_value := x_mapped_err_msg.column_value;
        END IF;
      WHEN 5 THEN
        IF (x_mapped_err_msg.token5_value_key <>
            x_mapped_err_msg.column_value_key) THEN
          x_mapped_err_msg.token5_value :=
            get_value_from_key
            (
              p_key => x_mapped_err_msg.token5_value_key,
              p_headers => p_headers,
              p_lines => p_lines,
              p_line_locs => p_line_locs,
              p_price_diffs => p_price_diffs,
              p_table_name => p_table_name,
              p_interface_header_id => p_interface_header_id,
              p_interface_line_id => p_interface_line_id,
              p_interface_line_location_id => p_interface_line_location_id,
              p_price_diff_interface_id => p_price_diff_interface_id
            );
        ELSE
          x_mapped_err_msg.token5_value := x_mapped_err_msg.column_value;
        END IF;
      WHEN 6 THEN
        IF (x_mapped_err_msg.token6_value_key <>
            x_mapped_err_msg.column_value_key) THEN
          x_mapped_err_msg.token6_value :=
            get_value_from_key
            (
              p_key => x_mapped_err_msg.token6_value_key,
              p_headers => p_headers,
              p_lines => p_lines,
              p_line_locs => p_line_locs,
              p_price_diffs => p_price_diffs,
              p_table_name => p_table_name,
              p_interface_header_id => p_interface_header_id,
              p_interface_line_id => p_interface_line_id,
              p_interface_line_location_id => p_interface_line_location_id,
              p_price_diff_interface_id => p_price_diff_interface_id
            );
        ELSE
          x_mapped_err_msg.token6_value := x_mapped_err_msg.column_value;
        END IF;
    END CASE;
  END LOOP;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END map_error_message;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_value_from_key
--Function:
--  funtion to get interface record value based on the key
--Parameters:
--IN:
-- p_key
--  unique identifier for a particular attribute in interface record
-- p_headers
--  batch of header records in interface table
-- p_lines
--  batch of line records in interface table
-- p_line_locs
--  batch of location records in the interface table
-- p_price_diffs
--  batch of price differential records in the interface table
-- p_table_name
--  name of interface table which contains the errorous record
-- p_interface_header_id
--  corresponding interface_header_id of the error record
-- p_interface_line_id
--  corresponding interface_line_id of the error record
-- p_interface_line_location_id
--  corresponding interface_line_location_id of the error record
-- p_price_diff_interface_id
--  corresponding price_diff_interface_id of the error record
--IN OUT:
--OUT:
--RETURN: value of an attribute in interface record for the particular key
--End of Comments
------------------------------------------------------------------------
FUNCTION get_value_from_key
(
  p_key                          IN VARCHAR2,
  p_headers                      IN PO_PDOI_TYPES.headers_rec_type := NULL,
  p_lines                        IN PO_PDOI_TYPES.lines_rec_type := NULL,
  p_line_locs                    IN PO_PDOI_TYPES.line_locs_rec_type := NULL,
  p_price_diffs                  IN PO_PDOI_TYPES.price_diffs_rec_type := NULL,
  p_table_name                   IN VARCHAR2 := NULL,
  p_interface_header_id          IN NUMBER,
  p_interface_line_id            IN NUMBER := NULL,
  p_interface_line_location_id   IN NUMBER := NULL,
  p_price_diff_interface_id      IN NUMBER := NULL
) RETURN VARCHAR2 IS

d_api_name CONSTANT VARCHAR2(30) := 'get_value_from_key';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_value VARCHAR2(4000) := NULL;
l_index NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_begin(d_module, 'p_key', p_key);
     PO_LOG.proc_begin(d_module, 'p_table_name', p_table_name);
     PO_LOG.proc_begin(d_module, 'p_interface_header_id', p_interface_header_id);
     PO_LOG.proc_begin(d_module, 'p_interface_line_id', p_interface_line_id);
     PO_LOG.proc_begin(d_module, 'p_interface_line_location_id',
	                   p_interface_line_location_id);
     PO_LOG.proc_begin(d_module, 'p_price_diff_interface_id',
	                   p_price_diff_interface_id);
  END IF;

  -- get value from each interface record based on p_table_name
  CASE p_table_name
    WHEN PO_PDOI_CONSTANTS.g_PO_HEADERS_INTERFACE THEN
      d_position := 10;
      l_index := p_headers.intf_id_index_tbl(p_interface_header_id);
      IF (p_key = PO_MSG_MAPPING_UTL.c_rate_type) THEN
        l_value := p_headers.rate_type_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_agent_name) THEN
        l_value := p_headers.agent_name_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_ship_to_location) THEN
        l_value := p_headers.ship_to_loc_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_bill_to_location) THEN
        l_value := p_headers.bill_to_loc_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_payment_terms) THEN
        l_value := p_headers.payment_terms_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_vendor_name) THEN
        l_value := p_headers.vendor_name_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_vendor_site_code) THEN
        l_value := p_headers.vendor_site_code_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_vendor_contact) THEN
        l_value := p_headers.vendor_contact_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_style_display_name) THEN
        l_value := p_headers.style_display_name_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_from_rfq_num) THEN
        l_value := p_headers.from_rfq_num_tbl(l_index);
      ELSE
        NULL;
      END IF;
    WHEN PO_PDOI_CONSTANTS.g_PO_LINES_INTERFACE THEN
      d_position := 20;
      l_index := p_lines.intf_id_index_tbl(p_interface_line_id);
      IF (p_key = PO_MSG_MAPPING_UTL.c_item) THEN
        l_value := p_lines.item_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_item_desc) THEN
        l_value := p_lines.item_desc_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_job_business_group_name) THEN
        l_value := p_lines.job_business_group_name_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_job_name) THEN
        l_value := p_lines.job_name_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_category) THEN
        l_value := p_lines.category_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_ip_category) THEN
        l_value := p_lines.ip_category_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_uom_code) THEN
        -- bug5619358
        -- For Catalog Upload, we need to get the value from
        -- UNI_MEAS_LOOKUP_CODE if UOM_CODE is NULL
        IF (PO_PDOI_PARAMS.g_request.calling_module =
              PO_PDOI_CONSTANTS.g_call_mod_CATALOG_UPLOAD) THEN

          l_value := NVL(p_lines.uom_code_tbl(l_index),
                         p_lines.unit_of_measure_tbl(l_index));
        END IF;
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_line_type) THEN
        l_value := p_lines.line_type_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_un_number) THEN
        l_value := p_lines.un_number_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_hazard_class) THEN
        l_value := p_lines.hazard_class_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_template_name) THEN
        l_value := p_lines.template_name_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_amount) THEN
        l_value := p_lines.amount_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_unit_price) THEN
        l_value := p_lines.unit_price_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_line_num) THEN
        l_value := p_lines.line_num_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_quantity) THEN
        l_value := p_lines.quantity_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_item_revision) THEN
        l_value := p_lines.item_revision_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_ga_flag) THEN
        l_value := p_lines.hd_global_agreement_flag_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_negotiated_flag) THEN
        l_value := p_lines.negotiated_flag_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_created_language) THEN
        l_value := p_lines.hd_created_language_tbl(l_index);
      ELSE
        NULL;
      END IF;
    WHEN PO_PDOI_CONSTANTS.g_PO_LINE_LOCATIONS_INTERFACE THEN
      d_position := 30;
      l_index := p_line_locs.intf_id_index_tbl(p_interface_line_location_id);
      IF (p_key = PO_MSG_MAPPING_UTL.c_ship_to_organization_code) THEN
        l_value := p_line_locs.ship_to_org_code_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_loc_ship_to_location) THEN
        l_value := p_line_locs.ship_to_loc_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_payment_terms) THEN
        l_value := p_line_locs.payment_terms_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_receiving_routing) THEN
        l_value := p_line_locs.receiving_routing_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_tax_code_id) THEN
        l_value := p_line_locs.tax_code_id_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_price_discount) THEN
        l_value := p_line_locs.price_discount_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_style_id) THEN
        l_value := p_line_locs.hd_style_id_tbl(l_index);
      ELSIF (p_key = PO_MSG_MAPPING_UTL.c_start_date) THEN
        l_value := p_line_locs.start_date_tbl(l_index);
      ELSE
        NULL;
      END IF;
    WHEN PO_PDOI_CONSTANTS.g_PO_PRICE_DIFF_INTERFACE THEN
      NULL;
  END CASE;

 IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN l_value;

  EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;
END get_value_from_key;


END PO_PDOI_ERR_UTL;

/
