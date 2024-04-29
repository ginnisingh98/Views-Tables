--------------------------------------------------------
--  DDL for Package OE_QUOTE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_QUOTE_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUQUOS.pls 120.0.12010000.1 2008/07/25 07:57:26 appldev ship $ */


-- Global to indicate to other APIs (like process order) that complete
-- negotiation is the calling API
G_COMPLETE_NEG                     VARCHAR2(1) := 'N';

PROCEDURE Complete_Negotiation
   (p_header_id                 IN NUMBER
   ,x_return_status             OUT NOCOPY VARCHAR2
   ,x_msg_count                 OUT NOCOPY NUMBER
   ,x_msg_data                  OUT NOCOPY VARCHAR2
   );

END OE_Quote_Util;

/
