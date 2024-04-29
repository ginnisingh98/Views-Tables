--------------------------------------------------------
--  DDL for Package WSH_USA_QUANTITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_USA_QUANTITY_PVT" AUTHID CURRENT_USER as
/* $Header: WSHUSAQS.pls 120.0.12000000.1 2007/01/16 05:52:26 appldev ship $ */

G_PACKAGE_NAME               CONSTANT        VARCHAR2(50) := 'WSH_USA_QUANTITY_PVT';


PROCEDURE Update_Ordered_Quantity(
p_changed_attribute       IN     WSH_INTERFACE.ChangedAttributeRecType
, p_source_code             IN     VARCHAR2
, p_action_flag             IN     VARCHAR2
, p_wms_flag                IN     VARCHAR2  DEFAULT 'N'
, p_context                 IN     VARCHAR2  DEFAULT NULL
, x_return_status           OUT NOCOPY     VARCHAR2
);

END WSH_USA_QUANTITY_PVT;

 

/
