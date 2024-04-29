--------------------------------------------------------
--  DDL for Package CSE_AP_PA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_AP_PA_PKG" AUTHID CURRENT_USER AS
/* $Header: CSEAPINS.pls 120.1.12000000.1 2007/01/18 05:14:49 appldev ship $   */

  PROCEDURE process_ipv_to_pa(
    errbuf                     OUT NOCOPY VARCHAR2,
    retcode                    OUT NOCOPY NUMBER,
    p_project_id            IN     number,
    p_task_id               IN     number,
    p_po_header_id          IN     number,
    p_inventory_item_id     IN     number,
    p_organization_id       IN     number);

END cse_ap_pa_pkg ;

 

/
