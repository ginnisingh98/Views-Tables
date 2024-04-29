--------------------------------------------------------
--  DDL for Package JG_ZZ_OM_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_OM_COMMON_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzzomcs.pls 120.11 2005/10/06 01:16:23 appradha ship $ */

PROCEDURE copy_gdff (
        p_interface_line_rec IN     OE_Invoice_PUB.OE_GDF_Rec_Type,
        x_interface_line_rec IN OUT NOCOPY OE_Invoice_PUB.OE_GDF_Rec_Type,
        x_return_code        IN OUT NOCOPY NUMBER,
        x_error_buffer       IN OUT NOCOPY VARCHAR2);

  PROCEDURE default_gdff
       (p_line_rec           IN            OE_ORDER_PUB.line_rec_type,
        x_line_rec              OUT NOCOPY OE_ORDER_PUB.line_rec_type,
        x_return_code        IN OUT NOCOPY NUMBER,
        x_error_buffer       IN OUT NOCOPY VARCHAR2
        ); --2354736

  PROCEDURE copy_gdf
       (x_interface_line_rec IN OUT NOCOPY OE_INVOICE_PUB.OE_GDF_Rec_Type,
        x_return_code        IN OUT NOCOPY NUMBER,
        x_error_buffer       IN OUT NOCOPY VARCHAR2);

PROCEDURE default_gdf (
        x_line_rec     IN OUT NOCOPY oe_order_pub.line_rec_type,
        x_return_code  IN OUT NOCOPY NUMBER,
        x_error_buffer IN OUT NOCOPY VARCHAR2
        ); --2354736

END JG_ZZ_OM_COMMON_PKG;

 

/
