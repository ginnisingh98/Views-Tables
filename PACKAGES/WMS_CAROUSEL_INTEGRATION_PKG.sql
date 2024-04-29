--------------------------------------------------------
--  DDL for Package WMS_CAROUSEL_INTEGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CAROUSEL_INTEGRATION_PKG" AUTHID CURRENT_USER AS
/* $Header: WMSCSPBS.pls 120.0 2005/05/24 19:20:17 appldev noship $ */

   PROCEDURE sync_device_request (
      p_request_id      IN              NUMBER,
      p_device_id       IN              NUMBER,
      p_resubmit_flag   IN              VARCHAR2,
      x_status_code     OUT NOCOPY      VARCHAR2,
      x_status_msg      OUT NOCOPY      VARCHAR2,
      x_device_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE sync_device (
      p_organization_id   IN              NUMBER,
      p_device_id         IN              NUMBER,
      p_employee_id       IN              NUMBER,
      p_sign_on_flag      IN              VARCHAR2,
      x_status_code       OUT NOCOPY      VARCHAR2,
      x_device_status     OUT NOCOPY      VARCHAR2
   );

   PROCEDURE pipe_listener_loop (p_job IN NUMBER, p_zone IN VARCHAR2, p_device_id in NUMBER, p_pipe_name IN VARCHAR2);

   PROCEDURE submit_pipe_listeners(p_device_id IN NUMBER);

   PROCEDURE remove_pipe_listeners;

   PROCEDURE recreate_pipe_listeners;

   PROCEDURE start_pipe_listeners(p_device_id IN NUMBER DEFAULT NULL);

   PROCEDURE stop_pipe_listeners(p_device_id IN NUMBER DEFAULT NULL);

   PROCEDURE SIGN_OFF_USER(p_organization_id IN NUMBER,
			p_device_id IN NUMBER,
			p_emp_id IN NUMBER,
			x_return_status OUT NOCOPY VARCHAR2);

END WMS_CAROUSEL_INTEGRATION_PKG;

 

/
