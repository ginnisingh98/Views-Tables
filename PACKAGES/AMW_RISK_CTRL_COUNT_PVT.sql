--------------------------------------------------------
--  DDL for Package AMW_RISK_CTRL_COUNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_RISK_CTRL_COUNT_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvrccs.pls 115.7 2003/12/03 02:28:06 abedajna noship $ */

   PROCEDURE insert_risk_control_count (
      p_process_id                IN              NUMBER := NULL,
      p_risk_id                   IN              NUMBER := NULL,
      p_control_id                IN              NUMBER := NULL,
      p_process_organization_id   IN              NUMBER := NULL,
      p_association_mode          IN              VARCHAR2 := 'ASSOCIATE',
      p_object                    IN              VARCHAR2 := 'RISK',
      p_commit                    IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level          IN              NUMBER
            := fnd_api.g_valid_level_full,
      p_init_msg_list             IN              VARCHAR2 := fnd_api.g_false,
      p_api_version_number        IN              NUMBER,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2
   );
END amw_risk_ctrl_count_pvt;

 

/
