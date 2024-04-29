--------------------------------------------------------
--  DDL for Package JL_ZZ_RECEIV_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_RECEIV_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: jlzzoris.pls 120.4.12010000.1 2008/07/31 04:24:52 appldev ship $ */

PROCEDURE copy_gdff (
        p_interface_line_rec IN     OE_Invoice_PUB.OE_GDF_Rec_Type,
        x_interface_line_rec IN OUT NOCOPY OE_Invoice_PUB.OE_GDF_Rec_Type,
        x_return_code        IN OUT NOCOPY NUMBER,
      x_error_buffer       IN OUT NOCOPY VARCHAR2);

PROCEDURE copy_gdf (
        x_interface_line_rec IN OUT NOCOPY OE_Invoice_PUB.OE_GDF_Rec_Type,
        x_return_code        IN OUT NOCOPY NUMBER,
 x_error_buffer       IN OUT NOCOPY VARCHAR2);

PROCEDURE default_gdff
     (p_line_rec     IN     oe_order_pub.line_rec_type,
      x_line_rec        OUT NOCOPY oe_order_pub.line_rec_type,
      x_return_code  IN OUT NOCOPY NUMBER,
      x_error_buffer IN OUT NOCOPY VARCHAR2,
      p_org_id       IN     NUMBER DEFAULT        --Bugfix 2367111
                            MO_GLOBAL.GET_CURRENT_ORG_ID);

PROCEDURE default_gdf
     (x_line_rec     IN OUT NOCOPY oe_order_pub.line_rec_type,
      x_return_code  IN OUT NOCOPY NUMBER,
      x_error_buffer IN OUT NOCOPY VARCHAR2,
      p_org_id       IN     NUMBER DEFAULT           --Bugfix 2367111
                            MO_GLOBAL.GET_CURRENT_ORG_ID);

END JL_ZZ_RECEIV_INTERFACE;

/
