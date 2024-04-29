--------------------------------------------------------
--  DDL for Package PSA_FJE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_FJE_PKG" AUTHID CURRENT_USER AS
/* $Header: psafjecs.pls 120.0 2005/08/12 18:47:55 vmedikon noship $ */

  PROCEDURE populate_ref_info ( p_sob_id 	NUMBER,
                                p_packet_id     NUMBER);

END psa_fje_pkg;

 

/
