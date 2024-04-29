--------------------------------------------------------
--  DDL for Package PO_DISTRIBUTIONS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DISTRIBUTIONS_SV2" AUTHID CURRENT_USER as
/* $Header: POXPOD2S.pls 115.2 2002/11/23 02:47:16 sbull ship $ */

/*===========================================================================
  PACKAGE NAME:         PO_DISTRIBUTIONS_SV2

  DESCRIPTION:          Contains flexfield server side validation.

  CLIENT/SERVER:        Server

  LIBRARY NAME          None

  OWNER:                MCHIHAOU

  PROCEDURE NAMES:      get_new_ccid
===========================================================================*/

FUNCTION get_new_ccid(
                x_operation           IN VARCHAR2,
                x_appl_short_name     IN VARCHAR2,
                x_key_flex_code       IN VARCHAR2,
                x_structure_number    IN NUMBER,
                x_concat_segments     IN VARCHAR2,
                x_validation_date     IN DATE,
                x_vrule               IN VARCHAR2,
                x_encoded_error_msg IN OUT NOCOPY VARCHAR2,
                x_new_ccid          IN OUT NOCOPY NUMBER) RETURN BOOLEAN;

END po_distributions_sv2;

 

/
