--------------------------------------------------------
--  DDL for Package PO_INTERFACE_ERRORS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_INTERFACE_ERRORS_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVPIES.pls 115.1 2003/08/26 23:34:40 bao noship $*/

PROCEDURE insert_row
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2,
  p_rec           IN         PO_INTERFACE_ERRORS%ROWTYPE,
  x_row_id        OUT NOCOPY ROWID
);

END PO_INTERFACE_ERRORS_PVT;

 

/
