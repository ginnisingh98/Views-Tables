--------------------------------------------------------
--  DDL for Package WMS_EPC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_EPC_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSEPCPS.pls 120.3.12010000.6 2012/08/30 18:48:20 sahmahes ship $ */
/*#
  * This object provides extension APIs to support EPC generation of
  *  custom/unimplemented EPC Types
  * @rep:scope public
  * @rep:product WMS
  * @rep:lifecycle active
  * @rep:displayname Extension API for EPC generation in WMS
  * @rep:category BUSINESS_ENTITY WMS_EPC_PUB
  */




  /*#
  * This API lets customer implement its own logic to pick
    * company-prefix if the customer has multiple company-prefix after merger
    * and acquisition. The default company-prefix is set at the Organization parameter level
    *
    * @ param p_org_id Orgnization id of the transaction source
    * @ paraminfo {@rep:required}
    * @ param p_label_request_id Provides all information for current transaction from wms_label_requests table
    * @ paraminfo {@rep:required}
    * @ param X_company_prefix returned company-prefix
    * @ paraminfo {@rep:required}
    * @ param x_return_status "S"- SUCCESS /"E" - ERROR /"U" - UNEXPECTED ERROR
    * @ paraminfo {@rep:required}
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname API to get custom company-prefix
    * @rep:businessevent get_custom_company_prefix
  */

  PROCEDURE get_custom_company_prefix
    ( p_org_id IN NUMBER,
      p_label_request_id  IN NUMBER,
      X_company_prefix out nocopy VARCHAR2,
      X_RETURN_STATUS out nocopy VARCHAR2);

  /*#
  * This API lets customer implement its own logic to pick
    * company-prefix-index if the customer has multiple company-prefix-index after merger
    * and acquisition. The default company-prefix-index is set at the Organization parameter level
    *
    * @ param p_org_id Orgnization id of the transaction source
    * @ paraminfo {@rep:required}
    * @ param p_label_request_id Provides all information for current transaction from wms_label_requests table
    * @ paraminfo {@rep:required}
    * @ param x_comp_prefix_index returned company-prefix-index
    * @ paraminfo {@rep:required}
    * @ param x_return_status "S"- SUCCESS /"E" - ERROR /"U" - UNEXPECTED ERROR
    * @ paraminfo {@rep:required}
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname API to get custom company-prefix-index
    * @rep:businessevent get_custom_comp_prefix_index
  */


  PROCEDURE get_custom_comp_prefix_index
    ( p_org_id IN NUMBER,
      p_label_request_id  IN NUMBER,
      x_comp_prefix_index out nocopy VARCHAR2,
      x_RETURN_STATUS out nocopy VARCHAR2);

    /*#
       * This API, if implemented provides customers an opportunity to decide whether to honor
       *  ucc_128_suffix_flag set in the organization parameters form or not when generating LPN
       *  in the mobile pages.
       * @ param p_org_id Orgnization id of the transaction source
       * @ paraminfo {@rep:required}
       * @ param x_honor_org_param returned "YES" - Honor ucc_128_suffix_flag as set in the organization parameters form
       *                                    "NO" - Do not honor ucc_128_suffix_flag set in the organization parameters, by default taken as checkbox disabled
       *                                    "NULL" - By default taken as "NO"
       * @ paraminfo {@rep:required}
       * @ rep:scope public
       * @ rep:lifecycle active
       * @ rep:displayname API to honor organization parameters or not
       * @ rep:businessevent GET_CUSTOM_UCC_128_SUFFIX
  */

   -- Added for Bug 13740139
  PROCEDURE GET_CUSTOM_UCC_128_SUFFIX(
              p_org_id IN NUMBER,
              x_honor_org_param OUT NOCOPY VARCHAR2
              );
-- End of Bug 13740139


/*#
    * This API, if implemented, provides customers an opportunity to
    * generate non-Standard custom EPC or unimplemented EPC that can be
    * used by stored in WMS product and used for subsquent transactions.
    *
    * @ param p_org_id Orgnization id of the transaction source
    * @ paraminfo {@rep:required}
    * @ param p_category_id EPC category id defined in Oracle DB EPC generation utility
    * @ paraminfo {@rep:required}
    * @ param p_epc_rule_type_id  EPC generation rule type id defined in Oracle DB EPC generation utility.
	*							  In both old and new RFID model the p_epc_rule_type_id would be taken as input but in new model it represents the rule name from MGD_ID_SCHEME.
	*							  The naming convention for EPC rule types in new model is changed from EPC_XXX_## to XXX-##, e.g in new model EPC_SSCC_64 is changed to SSCC-64.
    * @ paraminfo {@rep:required}
    * @ param p_filter_value To identify the object type (Pallet, Case,Inner-pack etc
    * @ paraminfo {@rep:required}
    * @ param p_label_request_id Provides all information for current transaction from wms_label_requests table
    * @ paraminfo {@rep:required}
    * @ param x_return_status "S"- SUCCESS /"E" - ERROR /"U" - UNEXPECTED ERROR
    * @ paraminfo {@rep:required}
    * @ param x_return_mesg message in case there is error in custom EPC generation
    * @ paraminfo {@rep:required}
    * @ param x_EPC returned EPC in HEX system
    * @ paraminfo {@rep:required}
	* @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname API to implement custom/unimplemented EPC generation
    * @rep:businessevent get_custom_epc
  */
   --BUG8796558
    PROCEDURE get_custom_epc(p_org_id IN VARCHAR2,
			 p_category_id IN VARCHAR2,
			 p_epc_rule_type_id IN VARCHAR2,
			 p_filter_value IN NUMBER,
			 p_label_request_id IN NUMBER,
			 x_return_status OUT nocopy VARCHAR2,
			 x_return_mesg OUT nocopy VARCHAR2,
			 x_epc OUT nocopy VARCHAR2 );


END wms_epc_pub;

/
