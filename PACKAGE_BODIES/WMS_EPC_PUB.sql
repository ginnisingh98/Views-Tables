--------------------------------------------------------
--  DDL for Package Body WMS_EPC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_EPC_PUB" AS
/* $Header: WMSEPCPB.pls 120.1.12010000.4 2012/08/30 18:50:16 sahmahes ship $ */

PROCEDURE GET_CUSTOM_COMPANY_PREFIX(
				    p_org_id IN NUMBER,
				    p_label_request_id  IN NUMBER,
				    X_company_prefix out nocopy VARCHAR2,
				    X_RETURN_STATUS out nocopy VARCHAR2)


  IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   X_company_prefix := NULL;

END GET_CUSTOM_COMPANY_PREFIX;


PROCEDURE GET_CUSTOM_COMP_PREFIX_INDEX(
				       p_org_id IN NUMBER,
				       p_label_request_id  IN NUMBER,
				       X_comp_prefix_index out nocopy VARCHAR2,
				       X_RETURN_STATUS out nocopy VARCHAR2)


  IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   X_comp_prefix_index := NULL;

END GET_CUSTOM_COMP_PREFIX_INDEX;

-- Added for Bug 13740139
PROCEDURE GET_CUSTOM_UCC_128_SUFFIX(
              p_org_id IN NUMBER,
              x_honor_org_param OUT NOCOPY VARCHAR2
              )
 IS
BEGIN
      x_honor_org_param := NULL;

END GET_CUSTOM_UCC_128_SUFFIX;
-- End of Bug 13740139

--BUG8796558
	PROCEDURE get_custom_epc(p_org_id IN VARCHAR2,
			 p_category_id IN VARCHAR2,
			 p_epc_rule_type_id IN VARCHAR2,
			 p_filter_value IN NUMBER,
			 p_label_request_id IN NUMBER,
			 x_return_status OUT nocopy VARCHAR2,
			 x_return_mesg OUT nocopy VARCHAR2,
			 x_epc OUT nocopy VARCHAR2 )
	IS
	BEGIN
	x_return_status := fnd_api.g_ret_sts_success;
	x_return_mesg := NULL;
	x_epc := NULL;

	END get_custom_epc;


END wms_epc_pub;

/
