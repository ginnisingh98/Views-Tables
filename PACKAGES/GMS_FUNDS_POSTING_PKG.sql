--------------------------------------------------------
--  DDL for Package GMS_FUNDS_POSTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_FUNDS_POSTING_PKG" AUTHID CURRENT_USER AS
/* $Header: gmsglfcs.pls 120.0 2005/05/29 11:51:14 appldev noship $ */
       -- ====================================================================
       -- API is called during PO/AP fundschecking AUTONOMOUS code.
       -- This is included in 11.5.10
       -- ====================================================================
       PROCEDURE gms_gl_return_code (x_er_code          IN OUT NOCOPY VARCHAR2,
                                     x_er_stage         IN OUT NOCOPY VARCHAR2,
                                     x_gl_return_code   IN OUT NOCOPY VARCHAR2,
                                     p_packet_id        IN            NUMBER,
                                     p_mode             IN            VARCHAR2,
                                     p_gms_return_code  IN            VARCHAR2,
                                     p_gms_partial_flag IN            VARCHAR2);
END gms_funds_posting_pkg ;

 

/
