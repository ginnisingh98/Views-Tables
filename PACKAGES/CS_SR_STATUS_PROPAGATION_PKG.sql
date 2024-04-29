--------------------------------------------------------
--  DDL for Package CS_SR_STATUS_PROPAGATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_STATUS_PROPAGATION_PKG" AUTHID CURRENT_USER AS
/* $Header: csxsrsps.pls 115.1 2003/09/23 00:09:25 talex noship $ */

  PROCEDURE VALIDATE_SR_CLOSURE(
	      p_api_version   	   IN         NUMBER,
	      p_init_msg_list	   IN         VARCHAR2 DEFAULT fnd_api.g_false,
              p_commit             IN         VARCHAR2,
              p_service_request_id IN         NUMBER,
              p_user_id            IN         NUMBER,
              p_resp_appl_id       IN         NUMBER,
              p_login_id           IN         NUMBER DEFAULT NULL,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2);


  PROCEDURE CLOSE_SR_CHILDREN(
	      p_api_version   	    IN         NUMBER,
	      p_init_msg_list       IN         VARCHAR2 DEFAULT fnd_api.g_false,
	      p_commit		    IN         VARCHAR2 DEFAULT fnd_api.g_false,
	      p_validation_required IN         VARCHAR2,
	      p_action_required     IN 	       VARCHAR2,
              p_service_request_id  IN         NUMBER,
              p_user_id             IN         NUMBER,
              p_resp_appl_id        IN         NUMBER,
              p_login_id            IN         NUMBER DEFAULT NULL,
              x_return_status       OUT NOCOPY VARCHAR2,
              x_msg_count           OUT NOCOPY NUMBER,
              x_msg_data            OUT NOCOPY VARCHAR2);

  PROCEDURE SR_UPWARD_STATUS_PROPAGATION(
              p_api_version        IN         NUMBER,
              p_init_msg_list      IN         VARCHAR2 DEFAULT fnd_api.g_false,
              p_commit             IN         VARCHAR2 DEFAULT fnd_api.g_false,
              p_service_request_id IN         NUMBER,
              p_user_id            IN         NUMBER,
              p_resp_appl_id       IN         NUMBER,
              p_login_id           IN         NUMBER DEFAULT NULL,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2);

END CS_SR_STATUS_PROPAGATION_PKG;

 

/
