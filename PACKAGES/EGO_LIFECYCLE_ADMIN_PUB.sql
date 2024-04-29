--------------------------------------------------------
--  DDL for Package EGO_LIFECYCLE_ADMIN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_LIFECYCLE_ADMIN_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOPLCAS.pls 115.1 2003/02/18 00:29:39 jflannic noship $ */

PROCEDURE Check_Delete_Lifecycle_OK
(
     p_api_version             IN      NUMBER
   , p_lifecycle_id            IN      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
   , p_init_msg_list           IN      VARCHAR2   := fnd_api.g_FALSE
   , x_delete_ok               OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
);

PROCEDURE Check_Delete_Phase_OK
(
     p_api_version             IN      NUMBER
   , p_phase_id                IN      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
   , p_init_msg_list           IN      VARCHAR2   := fnd_api.g_FALSE
   , x_delete_ok               OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
);

PROCEDURE Process_Phase_Delete
(
     p_api_version             IN   NUMBER
   , p_phase_id                IN   NUMBER
   , p_init_msg_list           IN   VARCHAR2   := fnd_api.g_FALSE
   , p_commit                  IN   VARCHAR2   := fnd_api.g_FALSE
   , x_return_status           OUT  NOCOPY VARCHAR2
   , x_errorcode               OUT  NOCOPY NUMBER
   , x_msg_count               OUT  NOCOPY NUMBER
   , x_msg_data                OUT  NOCOPY VARCHAR2
);

PROCEDURE Process_Phase_Code_Delete
(
     p_api_version             IN   NUMBER
   , p_phase_code              IN   VARCHAR2
   , p_init_msg_list           IN   VARCHAR2   := fnd_api.g_FALSE
   , p_commit                  IN   VARCHAR2   := fnd_api.g_FALSE
   , x_return_status           OUT  NOCOPY VARCHAR2
   , x_errorcode               OUT  NOCOPY NUMBER
   , x_msg_count               OUT  NOCOPY NUMBER
   , x_msg_data                OUT  NOCOPY VARCHAR2
);


PROCEDURE Delete_Stale_Data_For_Lc
(
     p_api_version             IN  NUMBER
   , p_lifecycle_id            IN  NUMBER
   , p_init_msg_list           IN   VARCHAR2   := fnd_api.g_FALSE
   , p_commit                  IN   VARCHAR2   := fnd_api.g_FALSE
   , x_return_status           OUT  NOCOPY VARCHAR2
   , x_errorcode               OUT  NOCOPY NUMBER
   , x_msg_count               OUT  NOCOPY NUMBER
   , x_msg_data                OUT  NOCOPY VARCHAR2
);

END EGO_LIFECYCLE_ADMIN_PUB;


 

/
