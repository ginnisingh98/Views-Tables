--------------------------------------------------------
--  DDL for Package CLN_3C3_AP_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_3C3_AP_TRIGGER_PKG" AUTHID CURRENT_USER AS
   /* $Header: CLN3C3TS.pls 120.0 2005/05/24 16:17:41 appldev noship $ */

   PROCEDURE TRIGGER_REJECTION(
                                      p_invoice_id             IN              NUMBER,
                                      p_group_id               IN              NUMBER,
                                      p_request_id             IN              NUMBER,
                                      p_external_doc_ref       IN              VARCHAR2);

END CLN_3C3_AP_TRIGGER_PKG;

 

/
