--------------------------------------------------------
--  DDL for Package M4U_GLOBAL_REGQRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_GLOBAL_REGQRY" AUTHID CURRENT_USER AS
/* $Header: M4UQRRES.pls 120.0 2005/05/24 16:16:19 appldev noship $ */

        -- Name
        --      raise_regqry_event
        -- Purpose
        --      This procedure is called from a concurrent program.
        --      The 'oracle.apps.m4u.registryquery.generate' is raised with the supplied event parameters
        --      The sequence m4u_wlqid_sequence is used to obtain unique event key.
        -- Arguments
        -- Notes
        --
        PROCEDURE raise_regqry_event(
                                        x_errbuf                OUT NOCOPY VARCHAR2,
                                        x_retcode               OUT NOCOPY NUMBER,
                                        p_qr_ipgln              IN VARCHAR2,
                                        p_qr_gtin               IN VARCHAR2,
                                        p_qr_targtMarkt         IN VARCHAR2
                                    );

        -- Name
        --      process_gtin_resp
        -- Purpose
        --      This procedure is called from the XGM m4u_230_resp_gbreqry_in
        --      This procedure updates the UCCnet Registry-query collaboration with GTIN info
        -- Arguments
        --      RCIR Item Attributes
        --      p_success_flag                  - Query success/failure flag
        --      p_gtin_query_id                 - GTIN query Id
        --      p_ucc_doc_unique_id             - UCC Doc Unique ID
        --      p_xmlg_internal_control_no      - XMLG ICN from map
        --      x_return_status                 - API ret status
        --      x_msg_data                      - API ret msg
        -- Notes
        --      none
        PROCEDURE process_gtin_resp(
                p_gtin                          IN VARCHAR2,
                p_data_source                   IN VARCHAR2,
                p_target_market                 IN VARCHAR2,
                p_src_data_pool                 IN VARCHAR2,
                p_reg_data_pool                 IN VARCHAR2,
                p_name_of_info_provider         IN VARCHAR2,
                p_brand_owner_name              IN VARCHAR2,
                p_brand_owner_gln               IN VARCHAR2,
                p_brand_name                    IN VARCHAR2,
                p_trade_item_unit_desc          IN VARCHAR2,
                p_eanucc_code                   IN VARCHAR2,
                p_eanucc_type                   IN VARCHAR2,
                p_delivery_method               IN VARCHAR2,
                p_consumer_unit                 IN VARCHAR2,
                p_ord_unit                      IN VARCHAR2,
                p_effective_date                IN VARCHAR2,
                p_next_level_cnt                IN VARCHAR2,
                p_gross_wt                      IN VARCHAR2,
                p_gross_wt_uom                  IN VARCHAR2,
                p_height                        IN VARCHAR2,
                p_height_uom                    IN VARCHAR2,
                p_width                         IN VARCHAR2,
                p_width_uom                     IN VARCHAR2,
                p_depth                         IN VARCHAR2,
                p_depth_uom                     IN VARCHAR2,
                p_volume                        IN VARCHAR2,
                p_volume_uom                    IN VARCHAR2,
                p_net_content                   IN VARCHAR2,
                p_net_content_uom               IN VARCHAR2,
                p_net_wt                        IN VARCHAR2,
                p_net_wt_uom                    IN VARCHAR2,
                p_is_info_pvt                   IN VARCHAR2,
                p_success_flag                  IN VARCHAR2,
                p_gtin_query_id                 IN VARCHAR2,
                p_ucc_doc_unique_id             IN VARCHAR2,
                p_xmlg_internal_control_no      IN NUMBER,
                x_collab_dtl_id                 OUT NOCOPY NUMBER,
                x_return_status                 OUT NOCOPY VARCHAR2,
                x_msg_data                      OUT NOCOPY VARCHAR2 );

END m4u_global_regqry;

 

/
