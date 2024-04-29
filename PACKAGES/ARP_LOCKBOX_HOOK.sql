--------------------------------------------------------
--  DDL for Package ARP_LOCKBOX_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_LOCKBOX_HOOK" AUTHID CURRENT_USER AS
/*$Header: ARRLBHKS.pls 120.4.12010000.1 2008/07/24 16:52:32 appldev ship $*/
--
PROCEDURE proc_before_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2,
                                 out_insert_records OUT NOCOPY VARCHAR2);
--
PROCEDURE proc_after_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2,
                                 out_insert_records OUT NOCOPY VARCHAR2);
--
PROCEDURE proc_after_second_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2);
--
PROCEDURE cursor_for_matching_rule(p_matching_option IN VARCHAR2,
                                   p_cursor_string OUT NOCOPY VARCHAR2);
--
PROCEDURE CURSOR_FOR_CUSTOM_LLCA(  p_unresolved_inv_array  IN OUT NOCOPY arp_lockbox_hook_pvt.invoice_array,
                                   p_invoice_array         IN OUT NOCOPY arp_lockbox_hook_pvt.invoice_array,
				   p_line_array            IN OUT NOCOPY arp_lockbox_hook_pvt.line_array );
--
END arp_lockbox_hook;

/
