--------------------------------------------------------
--  DDL for Package WSH_RLM_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_RLM_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: WSHRLMIS.pls 120.2.12000000.2 2007/04/09 10:16:39 sunilku ship $*/

k_VNULL	  CONSTANT VARCHAR2(25) := 'THIS_IS_A_NULL_VALUE';
k_DNULL   CONSTANT DATE         := to_date('01/01/1930','dd/mm/yyyy');
k_NNULL   CONSTANT NUMBER       := -19999999999;

TYPE t_shipper_rec is RECORD(
    shipper_ID1	VARCHAR2(30),
    shipper_ID2 VARCHAR2(30),
    shipper_ID3 VARCHAR2(30),
    shipper_ID4 VARCHAR2(30),
    shipper_ID5 VARCHAR2(30));

TYPE t_optional_match_rec is RECORD(
    cust_production_line            VARCHAR2(50),
    customer_dock_code              VARCHAR2(50),
    request_date                    DATE,
    schedule_date                   DATE,
    cust_po_number                  VARCHAR2(50),
    customer_item_revision          VARCHAR2(35),
    customer_job                    VARCHAR2(50),
    cust_model_serial_number        VARCHAR2(35),
    cust_production_seq_num         VARCHAR2(35),
    industry_attribute1             VARCHAR2(150),
    industry_attribute2             VARCHAR2(150),
    industry_attribute3             VARCHAR2(150),
    industry_attribute4             VARCHAR2(150),
    industry_attribute5             VARCHAR2(150),
    industry_attribute6             VARCHAR2(150),
    industry_attribute7             VARCHAR2(150),
    industry_attribute8             VARCHAR2(150),
    industry_attribute9             VARCHAR2(150),
    industry_attribute10            VARCHAR2(150),
    industry_attribute11            VARCHAR2(150),
    industry_attribute12            VARCHAR2(150),
    industry_attribute13            VARCHAR2(150),
    industry_attribute14            VARCHAR2(150),
    industry_attribute15            VARCHAR2(150),
    attribute1                      VARCHAR2(150),
    attribute2                      VARCHAR2(150),
    attribute3                      VARCHAR2(150),
    attribute4                      VARCHAR2(150),
    attribute5                      VARCHAR2(150),
    attribute6                      VARCHAR2(150),
    attribute7                      VARCHAR2(150),
    attribute8                      VARCHAR2(150),
    attribute9                      VARCHAR2(150),
    attribute10                     VARCHAR2(150),
    attribute11                     VARCHAR2(150),
    attribute12                     VARCHAR2(150),
    attribute13                     VARCHAR2(150),
    attribute14                     VARCHAR2(150),
    attribute15                     VARCHAR2(150));


PROCEDURE Get_In_Transit_Qty(
   p_source_code              IN   VARCHAR2 DEFAULT 'OE',
   p_customer_id              IN   NUMBER,
   p_ship_to_org_id           IN   NUMBER,
   p_intmed_ship_to_org_id    IN   NUMBER,--Bugfix 5911991
   p_ship_from_org_id         IN   NUMBER,
   p_inventory_item_id        IN   NUMBER,
   p_customer_item_id	      IN   NUMBER,
   p_order_header_id          IN   NUMBER,
   p_blanket_number           IN   NUMBER,
   p_org_id                   IN   NUMBER DEFAULT NULL,
   p_schedule_type	      IN   VARCHAR2,
   p_shipper_recs             IN   T_SHIPPER_REC,
   p_shipment_date            IN   DATE  DEFAULT NULL,
   p_match_within_rule	      IN   RLM_CORE_SV.T_MATCH_REC,
   p_match_across_rule	      IN   RLM_CORE_SV.T_MATCH_REC,
   p_optional_match_rec       IN   T_OPTIONAL_MATCH_REC,
   x_in_transit_qty           OUT NOCOPY   NUMBER,
   x_return_status            OUT NOCOPY   VARCHAR2);

END WSH_RLM_INTERFACE;
 

/
