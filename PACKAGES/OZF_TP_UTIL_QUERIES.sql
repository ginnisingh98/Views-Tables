--------------------------------------------------------
--  DDL for Package OZF_TP_UTIL_QUERIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_TP_UTIL_QUERIES" AUTHID CURRENT_USER AS
/* $Header: ozfvtpqs.pls 120.2 2005/12/19 13:21:03 gramanat ship $ */

TYPE QUALIFIER_REC_TYPE IS RECORD
(
   qualifier_context    VARCHAR2(30),
   qualifier_attribute  VARCHAR2(30),
   qualifier_attr_value VARCHAR2(30)
);


TYPE QUALIFIER_TBL_TYPE IS TABLE OF  QUALIFIER_REC_TYPE
        INDEX BY BINARY_INTEGER;

-- FUNCTION
FUNCTION get_party_name(p_site_use_id IN NUMBER) return VARCHAR2;
--    get activity description for Schedules and Offers
FUNCTION get_activity_description(activity_class IN VARCHAR2 DEFAULT NULL, activity_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

FUNCTION get_activity_access(p_object_class IN VARCHAR2,p_object_id IN NUMBER,p_resource_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_uom_conv(p_object_id IN VARCHAR2
                     ,p_qty       IN NUMBER
                     ,p_from_uom  IN VARCHAR2
                     ,p_to_uom    IN VARCHAR2) RETURN NUMBER;

FUNCTION get_a_alert(p_object_id         IN NUMBER,
                   p_object_type       IN VARCHAR2,
                   p_report_date       IN DATE,
                   p_resource_id       IN NUMBER,
                   p_alert_type        IN VARCHAR2,
                   p_alert_for         IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_alert(p_site_use_id       IN NUMBER,
                   p_cust_account_id   IN NUMBER,
                   p_report_date       IN DATE,
                   p_resource_id       IN NUMBER,
                   p_alert_type        IN VARCHAR2,
                   p_alert_for         IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_p_alert(p_product_attribute  IN VARCHAR2,
                   p_product_attr_value IN NUMBER,
                   p_report_date        IN DATE,
                   p_resource_id        IN NUMBER,
                   p_alert_type         IN VARCHAR2,
                   p_alert_for          IN VARCHAR2) RETURN VARCHAR2;


PROCEDURE get_list_price(
                    p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2  := FND_API.g_false,
                    p_commit               IN  VARCHAR2  := FND_API.g_false,

                    p_obj_id               IN  NUMBER,
                    p_obj_type             IN  VARCHAR2,
                    p_product_attribute    IN  VARCHAR2,
                    p_product_attr_value   IN  VARCHAR2,
                    p_fcst_uom             IN  VARCHAR2,
                    p_currency_code        IN  VARCHAR2,
                    p_price_list_id        IN  NUMBER,
                    p_qualifier_tbl        IN  OZF_TP_UTIL_QUERIES.QUALIFIER_TBL_TYPE,

                    x_list_price           OUT NOCOPY NUMBER,
                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_msg_count            OUT NOCOPY NUMBER,
                    x_msg_data             OUT NOCOPY VARCHAR2
                   );

FUNCTION get_quota_unit RETURN VARCHAR2;

FUNCTION get_item_descr (  p_FlexField_Name IN VARCHAR2
                          ,p_Context_Name IN VARCHAR2
                          ,p_attribute_name IN VARCHAR2
                          ,p_attr_value IN VARCHAR2 ) RETURN VARCHAR2;

FUNCTION get_item_name ( p_inventory_item_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_item_cost ( p_inventory_item_id IN NUMBER) RETURN NUMBER;


END OZF_TP_UTIL_QUERIES;
--show errors;

 

/
