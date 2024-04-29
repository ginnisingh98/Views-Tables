--------------------------------------------------------
--  DDL for Package CZ_IB_LOCKING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_IB_LOCKING" AUTHID CURRENT_USER AS
/*	$Header: cziblcks.pls 120.0 2005/05/24 19:16:32 appldev noship $*/

------------------------------------------------------------------------------------------

m_msg_count                   NUMBER;
m_msg_data                    VARCHAR2(2000);
m_return_status               VARCHAR2(255);

--------------------------------------------------------------------------------------
-- API name    :  lock_Config
-- Package Name:  CZ_IB_LOCKING
-- Type        :  Public
-- Pre-reqs    :  None
-- Function    :  Lock configuration specified by
--                p_config_session_hdr_id, p_config_session_rev_nbr (,p_config_session_item_id)
-- Version     :  Current version 1.0
--                Initial version 1.0
--
-- Note        : this procedure calls procedure CSI_CZ_INT.lock_item_instance()
-- for each instance with configuration specified by parameters
-- p_config_session_hdr_id, p_config_session_rev_nbr and p_config_session_item_id
-- others parameters are passed to CSI_CZ_INT.lock_item_instance() directly
--
PROCEDURE lock_Config
(
  p_api_version            IN  NUMBER,
  p_config_session_hdr_id  IN  NUMBER,
  p_config_session_rev_nbr IN  NUMBER,
  p_config_session_item_id IN  NUMBER,
  p_source_application_id  IN  NUMBER,
  p_source_header_ref      IN  VARCHAR2,
  p_source_line_ref1       IN  VARCHAR2,
  p_source_line_ref2       IN  VARCHAR2,
  p_source_line_ref3       IN  VARCHAR2,
  p_commit                 IN  VARCHAR2,
  p_init_msg_list          IN  VARCHAR2,
  p_validation_level       IN  NUMBER,
  x_locking_key            OUT NOCOPY NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------------------
-- API name    :  unlock_Config
-- Package Name:  CZ_IB_LOCKING
-- Type        :  Public
-- Pre-reqs    :  None
-- Function    :  Unlock configuration specified by
--                p_config_session_hdr_id, p_config_session_rev_nbr (,p_config_session_item_id)
-- Version     :  Current version 1.0
--                Initial version 1.0
--
-- Note        : this procedure calls procedure CSI_CZ_INT.unlock_item_instance()
-- for each instance with configuration specified by parameters
-- p_config_session_hdr_id, p_config_session_rev_nbr and p_config_session_item_id
-- others parameters are passed to CSI_CZ_INT.unlock_item_instance() directly
--
PROCEDURE unlock_Config
  (
  p_api_version            IN  NUMBER,
  p_config_session_hdr_id  IN  NUMBER,
  p_config_session_rev_nbr IN  NUMBER,
  p_config_session_item_id IN  NUMBER,
  p_locking_key            IN  NUMBER,
  p_source_application_id  IN  NUMBER,
  p_source_header_ref      IN  VARCHAR2,
  p_source_line_ref1       IN  VARCHAR2,
  p_source_line_ref2       IN  VARCHAR2,
  p_source_line_ref3       IN  VARCHAR2,
  p_commit                 IN  VARCHAR2,
  p_init_msg_list          IN  VARCHAR2,
  p_validation_level       IN  NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2
  );

END;

 

/
