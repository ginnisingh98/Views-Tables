--------------------------------------------------------
--  DDL for Package M4U_DMD_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_DMD_REQUESTS" AUTHID CURRENT_USER AS
/* $Header: M4UDREQS.pls 120.1 2007/09/12 06:57:59 bsaratna noship $ */

  PROCEDURE create_request
  (
        p_type                IN  VARCHAR2,
        p_direction           IN  VARCHAR2,
        p_status              IN  VARCHAR2 := NULL,
        p_ref_msg_id          IN  VARCHAR2 := NULL,
        p_orig_msg_id         IN  VARCHAR2 := NULL,
        p_msg_timstamp        IN  DATE     := NULL,
        p_payload_id          IN  VARCHAR2 := NULL,
        p_sender_gln          IN  VARCHAR2 := NULL,
        p_receiver_gln        IN  VARCHAR2 := NULL,
        p_rep_party_gln       IN  VARCHAR2 := NULL,
        p_user_gln            IN  VARCHAR2 := NULL,
        p_user_id             IN  VARCHAR2 := NULL,
        x_msg_id              OUT NOCOPY VARCHAR2,
        x_ret_sts             OUT NOCOPY VARCHAR2,
        x_ret_msg             OUT NOCOPY VARCHAR2
  );

  PROCEDURE  create_payload
  (
        p_xml           IN         CLOB,
        p_type          IN         VARCHAR2,
        p_dir           IN         VARCHAR2,
        x_payload_id    OUT NOCOPY VARCHAR2,
        x_ret_sts       OUT NOCOPY VARCHAR2,
        x_ret_msg       OUT NOCOPY VARCHAR2
  );


 PROCEDURE create_document
  (
        p_msg_id                IN VARCHAR2,
        p_type                  IN VARCHAR2,
        p_action                IN VARCHAR2,
        p_doc_status            IN VARCHAR2,
        p_func_status           IN VARCHAR2,
        p_timestamp             IN DATE     := NULL,
        p_processing_msg        IN VARCHAR2 := NULL,
        p_ref_doc_id            IN VARCHAR2 := NULL,
        p_orig_doc_id           IN VARCHAR2 := NULL,
        p_top_gtin              IN VARCHAR2 := NULL,
        p_info_provider_gln     IN VARCHAR2 := NULL,
        p_data_rcpt_gln         IN VARCHAR2 := NULL,
        p_tgt_mkt_ctry          IN VARCHAR2 := NULL,
        p_tgt_mkt_div           IN VARCHAR2 := NULL,
        p_param1                IN VARCHAR2 := NULL,
        p_param2                IN VARCHAR2 := NULL,
        p_param3                IN VARCHAR2 := NULL,
        p_param4                IN VARCHAR2 := NULL,
        p_param5                IN VARCHAR2 := NULL,
        p_lparam1               IN VARCHAR2 := NULL,
        p_lparam2               IN VARCHAR2 := NULL,
        p_lparam3               IN VARCHAR2 := NULL,
        p_lparam4               IN VARCHAR2 := NULL,
        p_lparam5               IN VARCHAR2 := NULL,
        p_payload_id            IN VARCHAR2 := NULL,
        p_payload_dir           IN VARCHAR2 := NULL,
        p_payload_type          IN VARCHAR2 := NULL,
        x_doc_id                OUT NOCOPY VARCHAR2,
        x_ret_sts               OUT NOCOPY VARCHAR2,
        x_ret_msg               OUT NOCOPY VARCHAR2
  );


  PROCEDURE retry_request
  (
        x_errbuf        OUT NOCOPY VARCHAR2,
        x_retcode       OUT NOCOPY NUMBER,
        p_msg_id        IN         VARCHAR2,
        p_mode          IN         VARCHAR2,
        p_time          IN         DATE
  );


  PROCEDURE update_request
  (
          p_msg_id              IN VARCHAR2,
          p_status              IN VARCHAR2,
          p_update_doc_flag     IN VARCHAR2,
          p_retry_count         IN NUMBER,
          p_ref_msg_id          IN VARCHAR2 := NULL,
          p_orig_msg_id         IN VARCHAR2 := NULL,
          p_msg_timstamp        IN DATE     := NULL,

          p_sender_gln          IN VARCHAR2 := NULL,
          p_receiver_gln        IN VARCHAR2 := NULL,
          p_rep_party_gln       IN VARCHAR2 := NULL,
          p_user_id             IN VARCHAR2 := NULL,
          p_user_gln            IN VARCHAR2 := NULL,

          p_bpel_instance_id    IN VARCHAR2 := NULL,
          p_bpel_process_id     IN VARCHAR2 := NULL,

          p_doc_type            IN VARCHAR2,
          p_doc_status          IN VARCHAR2 := NULL,
          p_func_status         IN VARCHAR2 := NULL,
          p_processing_msg      IN VARCHAR2 := NULL,

          p_payload             IN CLOB     := NULL,
          p_payload_dir         IN VARCHAR2 := NULL,
          p_payload_type        IN VARCHAR2 := NULL,

          x_ret_sts             OUT NOCOPY VARCHAR2,
          x_ret_msg             OUT NOCOPY VARCHAR2
  );

  PROCEDURE update_document
  (
        p_doc_id                IN VARCHAR2,
        p_doc_status            IN VARCHAR2,
        p_func_status           IN VARCHAR2,
        p_retry_count           IN NUMBER,
        p_processing_msg        IN VARCHAR2 := NULL,
        p_ref_doc_id            IN VARCHAR2 := NULL,
        p_orig_doc_id           IN VARCHAR2 := NULL,
        p_timestamp             IN VARCHAR2 := NULL,

        p_top_gtin              IN VARCHAR2 := NULL,
        p_info_provider_gln     IN VARCHAR2 := NULL,
        p_data_recepient_gln    IN VARCHAR2 := NULL,
        p_tgt_mkt_cntry         IN VARCHAR2 := NULL,
        p_tgt_mkt_subdiv        IN VARCHAR2 := NULL,

        p_param1                IN VARCHAR2 := NULL,
        p_param2                IN VARCHAR2 := NULL,
        p_param3                IN VARCHAR2 := NULL,
        p_param4                IN VARCHAR2 := NULL,
        p_param5                IN VARCHAR2 := NULL,
        p_lparam1               IN VARCHAR2 := NULL,
        p_lparam2               IN VARCHAR2 := NULL,
        p_lparam3               IN VARCHAR2 := NULL,
        p_lparam4               IN VARCHAR2 := NULL,
        p_lparam5               IN VARCHAR2 := NULL,

        p_payload_id            IN VARCHAR2 := NULL,
        p_payload_dir           IN VARCHAR2 := NULL,
        p_payload_type          IN VARCHAR2 := NULL,
        x_ret_sts               OUT NOCOPY VARCHAR2,
        x_ret_msg               OUT NOCOPY VARCHAR2
  );



END m4u_dmd_requests;

/
