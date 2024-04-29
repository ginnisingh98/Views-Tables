--------------------------------------------------------
--  DDL for Package PO_HR_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_HR_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: POHRINTS.pls 120.3 2008/06/26 06:51:50 adbharga noship $*/

-- See the package body for a detailed description of this function.
PROCEDURE is_Supplier_Updatable (
                 p_assignment_id        IN  NUMBER,
                 p_effective_date IN  DATE DEFAULT NULL
                 )
;

END PO_HR_INTERFACE_PVT;

/
