--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_ARCHIVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_ARCHIVE_PVT" AUTHID CURRENT_USER AS
/* $Header: POXPIARS.pls 120.0.12010000.3 2009/06/01 14:06:10 ababujan ship $ */


PROCEDURE archive_po(p_api_version         IN         NUMBER,
  		     p_document_id         IN         NUMBER,
  		     p_document_type       IN         VARCHAR2,
  		     p_document_subtype    IN         VARCHAR2,
  		     x_return_status       OUT NOCOPY VARCHAR2,
                     x_msg_count	   OUT NOCOPY NUMBER,
  		     x_msg_data            OUT NOCOPY VARCHAR2);


FUNCTION is_line_archived                                     -- <SERVICES FPJ>
(   p_po_line_id               IN      NUMBER
) RETURN BOOLEAN;

FUNCTION is_line_location_archived                            -- <SERVICES FPJ>
(   p_line_location_id         IN      NUMBER
) RETURN BOOLEAN;

FUNCTION is_price_differential_archived                       -- <SERVICES FPJ>
(   p_price_differential_id    IN      NUMBER
) RETURN BOOLEAN;

FUNCTION get_archive_mode                                    -- Bug 3565522
(   p_doc_type      IN     VARCHAR2 ,
    p_doc_subtype   IN     VARCHAR2
) RETURN VARCHAR2;

END PO_DOCUMENT_ARCHIVE_PVT; -- Package spec

/
