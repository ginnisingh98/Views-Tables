--------------------------------------------------------
--  DDL for Package BSC_PORTLET_KPILISTCUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PORTLET_KPILISTCUST" AUTHID CURRENT_USER as
/* $Header: BSCPKCS.pls 120.3 2007/02/08 14:09:48 ppandey ship $ */
--type BSC_NUM_LIST is table of Number;

APPLICATION_ID CONSTANT NUMBER := 271;

------------------------------------------------------------------
-- juwang's code goes from here
------------------------------------------------------------------

FUNCTION get_pluginfo_params(
    p_resp_id IN NUMBER) RETURN VARCHAR2;



PROCEDURE update_indicators (
    p_resp_id IN NUMBER,
    p_last_update_date IN DATE,
    p_last_updated_by IN NUMBER,
    p_number_array IN BSC_NUM_LIST
);


FUNCTION set_customized_data_private_n(
    p_user_id IN NUMBER,
    p_plug_id IN NUMBER,
    p_reference_path IN VARCHAR2,
    p_resp_id IN NUMBER,
    p_details_flag IN NUMBER,
    p_group_flag IN NUMBER,
    p_kpi_measure_details_flag IN NUMBER,
    p_createy_by IN NUMBER,
    p_last_updated_by IN NUMBER,
    p_porlet_name IN VARCHAR2,
    p_number_array IN BSC_NUM_LIST,
    p_o_ret_status OUT NOCOPY NUMBER) RETURN VARCHAR2;



FUNCTION get_customization(
    p_cookie_value IN VARCHAR2,
    p_encrypted_plug_id IN VARCHAR2,
    p_portlet_id IN NUMBER,
    p_resp_id OUT NOCOPY NUMBER,
    p_plug_id OUT NOCOPY NUMBER,
    p_user_id OUT NOCOPY NUMBER,
    p_details_flag OUT NOCOPY NUMBER,
    p_group_flag OUT NOCOPY NUMBER,
    p_display_name OUT NOCOPY VARCHAR2,
    p_has_selected_kpi OUT NOCOPY NUMBER,
    p_kpi_measure_details_flag OUT NOCOPY NUMBER) RETURN NUMBER;


end BSC_PORTLET_KPILISTCUST;

/
