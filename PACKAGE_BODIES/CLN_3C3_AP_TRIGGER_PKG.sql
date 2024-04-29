--------------------------------------------------------
--  DDL for Package Body CLN_3C3_AP_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_3C3_AP_TRIGGER_PKG" AS
/* $Header: CLN3C3TB.pls 120.0 2005/05/24 16:22:31 appldev noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

   PROCEDURE TRIGGER_REJECTION(
                                      p_invoice_id             IN              NUMBER,
                                      p_group_id               IN              NUMBER,
                                      p_request_id             IN              NUMBER,
                                      p_external_doc_ref       IN              VARCHAR2) IS
   BEGIN
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering CLN_3C3_AP_TRIGGER_PKG.TRIGGER_REJECTION API ------ ', 2);
        END IF;
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('p_invoice_id : ' || p_invoice_id, 1);
                cln_debug_pub.Add('p_group_id : ' || p_group_id, 1);
                cln_debug_pub.Add('p_request_id : ' || p_request_id, 1);
                cln_debug_pub.Add('p_external_doc_ref : ' || p_external_doc_ref, 1);
        END IF;

        CLN_NTFYINVC_PKG.TRIGGER_REJECTION(p_invoice_id,p_group_id,p_request_id,p_external_doc_ref);

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Exiting CLN_3C3_AP_TRIGGER_PKG.TRIGGER_REJECTION API ------ ', 2);
        END IF;
   END TRIGGER_REJECTION;
END CLN_3C3_AP_TRIGGER_PKG;

/
