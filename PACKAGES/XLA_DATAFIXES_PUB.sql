--------------------------------------------------------
--  DDL for Package XLA_DATAFIXES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_DATAFIXES_PUB" AUTHID CURRENT_USER AS
/* $Header: xlajedfp.pkh 120.0.12010000.2 2009/03/06 16:06:55 rajose ship $ */

------------------------------------------------------------------------------
-- Global variable
------------------------------------------------------------------------------
g_msg_mode   VARCHAR2(1) := 'S';  -- message mode, S or X

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------


PROCEDURE delete_journal_entries
  (p_api_version                IN  NUMBER
  ,p_init_msg_list              IN  VARCHAR2
  ,p_application_id             IN  INTEGER
  ,p_event_id                   IN  INTEGER
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
);


PROCEDURE reverse_journal_entries
  (p_api_version                IN  NUMBER
  ,p_init_msg_list              IN  VARCHAR2
  ,p_application_id             IN  INTEGER
  ,p_event_id                   IN  INTEGER
  ,p_reversal_method            IN  VARCHAR2
  ,p_gl_date                    IN  DATE
  ,p_post_to_gl_flag            IN  VARCHAR2
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
  ,x_rev_ae_header_id           OUT NOCOPY INTEGER
  ,x_rev_event_id               OUT NOCOPY INTEGER
  ,x_rev_entity_id              OUT NOCOPY INTEGER
  ,x_new_event_id               OUT NOCOPY INTEGER
  ,x_new_entity_id              OUT NOCOPY INTEGER
);



PROCEDURE redo_accounting
  (p_api_version                IN  NUMBER
  ,p_init_msg_list              IN  VARCHAR2
  ,p_application_id             IN  INTEGER
  ,p_event_id                   IN  INTEGER
  ,p_gl_posting_flag            IN  VARCHAR2
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
);



PROCEDURE do_not_transfer_je
  (p_api_version                IN  NUMBER
  ,p_init_msg_list              IN  VARCHAR2
  ,p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
);


PROCEDURE validate_journal_entry
  (p_api_version                IN  NUMBER
  ,p_init_msg_list              IN  VARCHAR2
  ,p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
);


PROCEDURE audit_datafix
  (p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER DEFAULT NULL
  ,p_ae_line_num                IN  INTEGER DEFAULT NULL
  ,p_event_id                   IN  INTEGER DEFAULT NULL
  ,p_audit_all                  IN  VARCHAR2 DEFAULT 'N'
);


PROCEDURE log_error
  (p_module             IN  VARCHAR2 DEFAULT NULL
  ,p_error_msg          IN  VARCHAR2 DEFAULT NULL
  ,p_error_name         IN  VARCHAR2 DEFAULT NULL
);

FUNCTION get_transaction_details ( p_application_id      IN INTEGER,
                                   p_entity_id           IN INTEGER,
                                   p_trans_details_flag  IN VARCHAR2 DEFAULT 'N',
                                   p_entity_code         IN VARCHAR2 DEFAULT NULL
                                   )
                                   RETURN VARCHAR2;

END xla_datafixes_pub;

/
