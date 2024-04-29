--------------------------------------------------------
--  DDL for Package AMW_ASSOC_POST_TXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_ASSOC_POST_TXN" AUTHID CURRENT_USER AS
/* $Header: amwpasts.pls 115.0 2003/12/03 02:29:21 abedajna noship $ */

   PROCEDURE assoc_post_txn (
      p_process_id                IN              NUMBER := NULL,
      p_risk_id                   IN              NUMBER := NULL,
      p_control_id                IN              NUMBER := NULL,
      p_process_organization_id   IN              NUMBER := NULL,
      p_association_mode          IN              VARCHAR2 := 'ASSOCIATE',
      p_object                    IN              VARCHAR2 := 'RISK',
      p_commit                    IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level          IN              NUMBER   := fnd_api.g_valid_level_full,
      p_init_msg_list             IN              VARCHAR2 := fnd_api.g_false,
      p_api_version_number        IN              NUMBER,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2 );
END AMW_ASSOC_POST_TXN;

 

/
