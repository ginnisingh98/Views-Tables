--------------------------------------------------------
--  DDL for Package Body PO_DISTRIBUTIONS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DISTRIBUTIONS_SV2" AS
/* $Header: POXPOD2B.pls 115.2 2002/11/23 02:47:28 sbull ship $ */

FUNCTION get_new_ccid(
                x_operation           IN VARCHAR2,
                x_appl_short_name     IN VARCHAR2,
                x_key_flex_code       IN VARCHAR2,
                x_structure_number    IN NUMBER,
                x_concat_segments     IN VARCHAR2,
                x_validation_date     IN DATE,
                x_vrule               IN VARCHAR2,
                x_encoded_error_msg IN OUT NOCOPY VARCHAR2,
                x_new_ccid          IN OUT NOCOPY NUMBER) return BOOLEAN is

x_success  BOOLEAN;

x_progress  VARCHAR2(3) := '000';

BEGIN

  x_progress := '001';

  x_success := FND_FLEX_KEYVAL.validate_segs(
                operation=>x_operation,
                appl_short_name=>x_appl_short_name,
                key_flex_code=>x_key_flex_code,
                structure_number=>x_structure_number,
                concat_segments=>x_concat_segments,
                validation_date=>x_validation_date,
                vrule=>x_vrule);

  x_progress := '002';

  IF x_success = TRUE THEN

    x_new_ccid := FND_FLEX_KEYVAL.combination_id;
    return(TRUE);

  ELSE

     x_encoded_error_msg := FND_FLEX_KEYVAL.encoded_error_message;
  --   x_encoded_error_msg := FND_FLEX_KEYVAL.error_message;
    return(FALSE);

  END IF;

EXCEPTION
WHEN OTHERS THEN
po_message_s.sql_error('po_distributions_sv2.get_new_ccid', x_progress, sqlcode);


END;

END po_distributions_sv2;


/
