--------------------------------------------------------
--  DDL for Package HZ_HTTP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_HTTP_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHHTTPS.pls 115.5 2002/12/31 11:55:00 sponnamb noship $*/

  PROCEDURE post (
    doc                    VARCHAR2,
    content_type           VARCHAR2,
    url                    VARCHAR2,
    resp               OUT NOCOPY VARCHAR2,
    resp_content_type  OUT NOCOPY VARCHAR2,
    proxyserver            VARCHAR2 := NULL,
    proxyport              NUMBER   := 80,
    x_return_status IN OUT NOCOPY VARCHAR2,
    x_msg_count     IN OUT NOCOPY NUMBER,
    x_msg_data      IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE post (
    doc                    VARCHAR2,
    content_type           VARCHAR2,
    url                    VARCHAR2,
    resp               OUT NOCOPY VARCHAR2,
    resp_content_type  OUT NOCOPY VARCHAR2,
    proxyserver            VARCHAR2 := NULL,
    proxyport              NUMBER   := 80,
    err_resp           OUT NOCOPY VARCHAR2,
    x_return_status IN OUT NOCOPY VARCHAR2,
    x_msg_count     IN OUT NOCOPY NUMBER,
    x_msg_data      IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE get (
    url                    VARCHAR2,
    resp               OUT NOCOPY VARCHAR2,
    resp_content_type  OUT NOCOPY VARCHAR2,
    proxyserver            VARCHAR2 := NULL,
    proxyport              NUMBER   := 80,
    x_return_status IN OUT NOCOPY VARCHAR2,
    x_msg_count     IN OUT NOCOPY NUMBER,
    x_msg_data      IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE get (
    url                    VARCHAR2,
    resp               OUT NOCOPY VARCHAR2,
    resp_content_type  OUT NOCOPY VARCHAR2,
    proxyserver            VARCHAR2 := NULL,
    proxyport              NUMBER   := 80,
    err_resp           OUT NOCOPY VARCHAR2,
    x_return_status IN OUT NOCOPY VARCHAR2,
    x_msg_count     IN OUT NOCOPY NUMBER,
    x_msg_data      IN OUT NOCOPY VARCHAR2
  );

END hz_http_pkg;

 

/
