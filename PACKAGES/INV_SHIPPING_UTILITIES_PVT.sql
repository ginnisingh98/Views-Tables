--------------------------------------------------------
--  DDL for Package INV_SHIPPING_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SHIPPING_UTILITIES_PVT" AUTHID CURRENT_USER AS
/* $Header: INVWSHUS.pls 120.1 2005/06/11 07:52:30 appldev  $ */
--

     PROCEDURE PRINT_PICK_SLIP (p_pick_slip_num            IN  NUMBER,
                                p_rpt_set_id               IN  NUMBER,
                                p_org_id                   IN  NUMBER,
                                x_ret_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                                x_err_message              OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

END INV_SHIPPING_UTILITIES_PVT;

 

/
