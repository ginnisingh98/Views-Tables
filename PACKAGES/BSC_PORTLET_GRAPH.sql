--------------------------------------------------------
--  DDL for Package BSC_PORTLET_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PORTLET_GRAPH" AUTHID CURRENT_USER AS
/* $Header: BSCPGHS.pls 115.8 2003/02/12 14:26:35 adrao ship $ */


PROCEDURE plug(
    p_session_id   IN pls_integer,
    p_plug_id      IN pls_integer,
    p_display_name IN VARCHAR2 default null,
    p_delete       IN VARCHAR2 default 'N');


PROCEDURE show_err(
	p_ctm_url IN VARCHAR2,
 	l_ask IN VARCHAR2,
	p_display_name IN VARCHAR2 DEFAULT NULL);

FUNCTION has_access(p_plug_id IN NUMBER) RETURN BOOLEAN;

FUNCTION re_align_html_pieces(src IN utl_http.html_pieces) RETURN
  utl_http.html_pieces;

PROCEDURE draw_kpi_graph(
    p_ctm_url      IN VARCHAR2,
    p_target_url   IN VARCHAR2,
    p_session_id   IN pls_integer,
    p_plug_id      IN pls_integer,
    p_display_name IN VARCHAR2 DEFAULT NULL);





PROCEDURE launch_bsckpi_jsp(
    p_session_id IN pls_integer,
    p_plug_id    IN pls_integer);



FUNCTION get_tab_url(
    p_cookie_value IN VARCHAR2,
    p_encrypted_plug_id IN VARCHAR2
) RETURN VARCHAR2;


FUNCTION get_kpi_url(
    p_cookie_value IN VARCHAR2,
    p_encrypted_plug_id IN VARCHAR2
) RETURN VARCHAR2;



FUNCTION get_tab_url(
    p_session_id IN NUMBER,
    p_plug_id    IN NUMBER
) RETURN VARCHAR2;


FUNCTION get_kpi_url(
    p_session_id IN NUMBER,
    p_plug_id    IN NUMBER) RETURN VARCHAR2;


FUNCTION get_pluginfo_params(
    p_resp_id IN NUMBER,
    p_session_id IN NUMBER,
    p_plug_id    IN NUMBER
) RETURN VARCHAR2;



FUNCTION get_portlet_kpigraph_url(
    p_session_id IN pls_integer,
    p_plug_id IN pls_integer,
    p_tab_id IN NUMBER,
    p_kpi_id IN NUMBER,
    p_resp_id IN NUMBER) RETURN VARCHAR2;




FUNCTION get_customized_kpigraph_url(
    p_session_id IN pls_integer,
    p_plug_id IN pls_integer,
    p_tab_id IN NUMBER,
    p_kpi_id IN NUMBER,
    p_is_never_customized IN BOOLEAN,
    p_resp_id IN NUMBER,
    p_display_name IN VARCHAR2) RETURN VARCHAR2;





PROCEDURE get_customized_data_private(
    p_session_id IN pls_integer,
    p_plug_id    IN pls_integer,
    p_o_resp_id   OUT NOCOPY NUMBER,
    p_o_tab_id   OUT NOCOPY NUMBER,
    p_o_kpi_id   OUT NOCOPY NUMBER);





FUNCTION set_customized_data_private(
    p_user_id IN NUMBER,
    p_plug_id IN NUMBER,
    p_resp_id IN NUMBER,
    p_kpi_id IN NUMBER,
    p_createy_by IN NUMBER,
    p_last_updated_by IN NUMBER,
    p_porlet_name IN VARCHAR2,
    p_o_ret_status OUT NOCOPY NUMBER) RETURN VARCHAR2;



FUNCTION get_customization(
    p_cookie_value IN VARCHAR2,
    p_encrypted_plug_id IN VARCHAR2,
    p_resp_id OUT NOCOPY NUMBER,
    p_tab_id OUT NOCOPY NUMBER,
    p_kpi_id OUT NOCOPY NUMBER,
    p_display_name OUT NOCOPY VARCHAR2,
    p_has_access OUT NOCOPY NUMBER) RETURN NUMBER;




FUNCTION set_customization(
    p_cookie_value IN VARCHAR2,
    p_encrypted_plug_id IN VARCHAR2,
    p_resp_id IN NUMBER,
    p_kpi_id IN NUMBER,
    p_portlet_name IN VARCHAR2,
    p_o_ret_status OUT NOCOPY NUMBER) RETURN VARCHAR2;




FUNCTION get_graph_image(
    p_resp_id IN NUMBER,
    p_kpi_id IN NUMBER,
    p_graph_key IN VARCHAR2,
    p_fbody OUT NOCOPY BLOB,
    p_o_ret_status OUT NOCOPY NUMBER) RETURN VARCHAR2;



FUNCTION save_graphkey(
    p_user_id IN NUMBER,
    p_resp_id IN NUMBER,
    p_kpi_id IN NUMBER,
    p_graph_key IN VARCHAR2,
    p_img_id OUT NOCOPY NUMBER,
    p_o_ret_status OUT NOCOPY NUMBER) RETURN VARCHAR2;
--    p_fbody OUT NOCOPY BLOB,

END bsc_portlet_graph;

 

/
