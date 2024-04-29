--------------------------------------------------------
--  DDL for Package ECEPOI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECEPOI" AUTHID CURRENT_USER AS
/* $Header: OEPOIS.pls 120.0.12010000.1 2009/08/28 00:58:13 smusanna noship $ */

Procedure Process_POI_Inbound (
        errbuf                OUT NOCOPY  varchar2,
        retcode               OUT NOCOPY  varchar2,
        i_file_path           IN   varchar2,
        i_file_name           IN   varchar2,
	   i_debug_mode	     IN   number,
        i_run_import          IN   varchar2,
        i_num_instances       IN   number default 1,
	   i_transaction_type    IN   varchar2,
	   i_map_id	          IN   number,
           i_data_file_characterset  IN varchar2
        );

Procedure Concat_Strings(
          String1       IN      VARCHAR2,
          String2       IN      VARCHAR2,
          String3       IN      VARCHAR2,
          OUT_String    OUT NOCOPY     VARCHAR2
          );

Procedure Get_Ship_To_Org_Id(
          p_address_id       IN      NUMBER,
          p_customer_id      IN      NUMBER,
          x_ship_to_org_id   OUT NOCOPY     NUMBER
          );

Procedure Get_Bill_To_Org_Id(
          p_address_id       IN      NUMBER,
          p_customer_id      IN      NUMBER,
          x_bill_to_org_id   OUT NOCOPY     NUMBER
          );

-- Fix for the bug 2627330
Procedure Concat_Instructions(
          String1       IN      VARCHAR2,
          String2       IN      VARCHAR2,
          String3       IN      VARCHAR2,
          String4       IN      VARCHAR2,
          String5       IN      VARCHAR2,
          Concat_String OUT NOCOPY     VARCHAR2
          );
-- Fix ends

Function EM_Transaction_Type
(   p_txn_code                 IN  VARCHAR2
) Return Varchar2;

Procedure Raise_Event_Hist (
          p_order_source_id         IN     Number,
          p_orig_sys_document_ref   IN     Varchar2,
          p_sold_to_org_id          IN     Number,
          p_transaction_type        IN     Varchar2,
          p_document_id		    IN     Number   DEFAULT NULL,
          p_change_sequence         IN     Varchar2 DEFAULT NULL,
          p_order_number            IN     Number   DEFAULT NULL,
          p_itemtype                IN     Varchar2 DEFAULT NULL,
          p_itemkey                 IN     Varchar2 DEFAULT NULL,
          p_status                  IN     Varchar2 DEFAULT NULL,
          p_message_text            IN     Varchar2 DEFAULT NULL,
          p_processing		    IN     Varchar2 DEFAULT NULL,
          p_xmlg_party_id           IN     Number   DEFAULT NULL,
          p_xmlg_party_site_id      IN     Number   DEFAULT NULL,
          p_order_type_id           IN     Number   DEFAULT NULL,
          p_header_id               IN     Number   DEFAULT NULL,
          p_org_id                  IN     Number,
          x_return_status           OUT NOCOPY    Varchar2
);

PROCEDURE Get_Item_Description
(  p_org_id               IN NUMBER
,  p_item_identifier_type IN VARCHAR2
,  p_inventory_item_id    IN NUMBER
,  p_ordered_item_id      IN NUMBER
,  p_sold_to_org_id       IN NUMBER
,  p_ordered_item         IN VARCHAR2
,  x_item_description     OUT NOCOPY VARCHAR2
);


END ECEPOI;

/
