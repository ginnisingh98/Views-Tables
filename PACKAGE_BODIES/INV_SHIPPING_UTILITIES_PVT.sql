--------------------------------------------------------
--  DDL for Package Body INV_SHIPPING_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SHIPPING_UTILITIES_PVT" AS
/* $Header: INVWSHUB.pls 120.1 2005/06/11 07:49:20 appldev  $ */

     G_PKG_NAME constant VARCHAR2(30) := 'INV_SHIPPING_UTILITIES_PVT';

     PROCEDURE PRINT_PICK_SLIP (p_pick_slip_num            IN  NUMBER,
                                p_rpt_set_id               IN  NUMBER,
                                p_org_id                   IN  NUMBER,
                                x_ret_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                                x_err_message              OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
     IS
     BEGIN
          WSH_Pr_Pick_Slip_Number.Print_Pick_Slip
          (
               p_pick_slip_number => p_pick_slip_num,
               p_report_set_id    => p_rpt_set_id,
               p_organization_id  => p_org_id,
               x_api_status       => x_ret_status,
               x_error_message    => x_err_message
          );

     END PRINT_PICK_SLIP;

END INV_SHIPPING_UTILITIES_PVT;

/
