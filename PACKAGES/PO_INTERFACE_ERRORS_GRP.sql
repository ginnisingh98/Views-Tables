--------------------------------------------------------
--  DDL for Package PO_INTERFACE_ERRORS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_INTERFACE_ERRORS_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGPIES.pls 115.1 2003/08/27 18:08:16 bao noship $*/

PROCEDURE log_error
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2,
  p_rec           IN         PO_INTERFACE_ERRORS%ROWTYPE,
  x_row_id        OUT NOCOPY ROWID
);

END PO_INTERFACE_ERRORS_GRP;

 

/
