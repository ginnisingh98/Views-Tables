--------------------------------------------------------
--  DDL for Package M4U_DMD_MESSAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_DMD_MESSAGE_PKG" AUTHID CURRENT_USER AS
 /* $Header: M4UDMSGS.pls 120.1 2007/07/17 07:11:03 bsaratna noship $ */

    PROCEDURE send_rfcin
    (
        p_user_gln              IN VARCHAR2,
        p_retailer_gln          IN VARCHAR2,
        p_datapool_gln          IN VARCHAR2,

        p_reload_flag           IN VARCHAR2,
        p_info_provider_gln     IN VARCHAR2,
        p_tgt_mkt_country       IN VARCHAR2,
        p_tgt_mkt_subdiv        IN VARCHAR2,
        p_gtin                  IN VARCHAR2,
        p_cat_type              IN VARCHAR2,
        p_cat_code              IN VARCHAR2,

        x_msg_id                OUT NOCOPY  VARCHAR2,
        x_ret_sts               OUT NOCOPY  VARCHAR2,
        x_ret_msg               OUT NOCOPY  VARCHAR2
    );

    PROCEDURE send_cis
    (
        p_cis_name              IN VARCHAR2,

        p_user_gln              IN VARCHAR2,
        p_retailer_gln          IN VARCHAR2,
        p_datapool_gln          IN VARCHAR2,

        p_operation             IN VARCHAR2,
        p_info_provider_gln     IN VARCHAR2,
        p_tgt_mkt_country       IN VARCHAR2,
        p_tgt_mkt_subdiv        IN VARCHAR2,
        p_gtin                  IN VARCHAR2,
        p_cat_type              IN VARCHAR2,
        p_cat_code              IN VARCHAR2,
        x_msg_id                OUT NOCOPY  VARCHAR2,
        x_ret_sts               OUT NOCOPY  VARCHAR2,
        x_ret_msg               OUT NOCOPY  VARCHAR2

    );



    PROCEDURE send_cin_ack
    (
        p_cin_msg_id     IN          VARCHAR2,
        x_msg_id         OUT NOCOPY  VARCHAR2,
        x_ret_sts        OUT NOCOPY  VARCHAR2,
        x_ret_msg        OUT NOCOPY  VARCHAR2
    );


    PROCEDURE send_cic
    (
        p_payload    IN          CLOB,
        x_msg_id     OUT NOCOPY  VARCHAR2,
        x_ret_sts    OUT NOCOPY  VARCHAR2,
        x_ret_msg    OUT NOCOPY  VARCHAR2
    );

    PROCEDURE receive_cin
    (
            p_payload       IN              CLOB,
            x_msg_id        OUT NOCOPY      VARCHAR2,
            x_ret_sts       OUT NOCOPY      VARCHAR2,
            x_ret_msg       OUT NOCOPY      VARCHAR2
    );
 END m4u_dmd_message_pkg;

/
