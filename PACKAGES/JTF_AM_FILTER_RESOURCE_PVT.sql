--------------------------------------------------------
--  DDL for Package JTF_AM_FILTER_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AM_FILTER_RESOURCE_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfamvss.pls 115.1 2003/10/10 21:22:27 sroychou ship $ */

 /*  Package variables */

  G_PKG_NAME   CONSTANT VARCHAR2(30):= 'JTF_AM_FILTER_RESOURCE_PVT';


  TYPE skill_param_rec IS RECORD
    (
      DOCUMENT_TYPE                    VARCHAR2(30)    := NULL,
      product_id                       NUMBER          := NULL,
      product_org_id                   NUMBER          := NULL,
      category_id                      NUMBER          := NULL,
      problem_code                     VARCHAR2(30)    := NULL,
      component_id                     NUMBER          := NULL
    );

  TYPE skill_param_tbl_type          IS TABLE OF skill_param_rec
                                        INDEX BY BINARY_INTEGER;

  TYPE SR_REC_TYPE IS RECORD (
                               INCIDENT_ID          NUMBER,
                               INCIDENT_TYPE_ID     NUMBER  );


  TYPE RESOURCE_REC_TYPE IS RECORD  (
   RESOURCE_ID          NUMBER,
   RESOURCE_TYPE        VARCHAR2(90) );

  TYPE RESOURCE_TBL_TYPE IS TABLE OF RESOURCE_REC_TYPE
                                      INDEX BY BINARY_INTEGER;

 PROCEDURE SEARCH_SKILL
    (   p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 DEFAULT FND_API.g_false,
        p_commit                              IN  VARCHAR2 DEFAULT FND_API.g_false,
        x_assign_resources_tbl                IN  OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        p_skill_param_tbl                     IN  JTF_AM_FILTER_RESOURCE_PVT.skill_param_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2);


  PROCEDURE SERVICE_SECURITY_CHECK
    (   p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 DEFAULT FND_API.g_false,
        p_commit                              IN  VARCHAR2 DEFAULT FND_API.g_false,
        x_assign_resources_tbl                IN  OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        p_sr_tbl                              IN  JTF_AM_FILTER_RESOURCE_PVT.sr_rec_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2);


END JTF_AM_FILTER_RESOURCE_PVT;

 

/
