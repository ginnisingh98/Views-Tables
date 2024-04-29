--------------------------------------------------------
--  DDL for Package CSI_BUSINESS_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_BUSINESS_EVENT_PVT" AUTHID CURRENT_USER AS
/* $Header: csivbess.pls 120.1 2007/10/21 17:12:45 fli noship $ */

   PROCEDURE create_instance_event
      (p_api_version               IN     NUMBER
       ,p_commit                   IN     VARCHAR2
       ,p_init_msg_list            IN     VARCHAR2
       ,p_validation_level         IN     NUMBER
       ,p_instance_id              IN     NUMBER
       ,p_subject_instance_id      IN     NUMBER
       ,x_return_status            OUT    NOCOPY VARCHAR2
       ,x_msg_count                OUT    NOCOPY NUMBER
       ,x_msg_data                 OUT    NOCOPY VARCHAR2
      );

   PROCEDURE update_instance_event
      (p_api_version               IN     NUMBER
       ,p_commit                   IN     VARCHAR2
       ,p_init_msg_list            IN     VARCHAR2
       ,p_validation_level         IN     NUMBER
       ,p_instance_id              IN     NUMBER
       ,p_subject_instance_id      IN     NUMBER
       ,x_return_status            OUT    NOCOPY VARCHAR2
       ,x_msg_count                OUT    NOCOPY NUMBER
       ,x_msg_data                 OUT    NOCOPY VARCHAR2
      );
END;

/
