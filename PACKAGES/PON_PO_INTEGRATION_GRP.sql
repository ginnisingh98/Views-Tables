--------------------------------------------------------
--  DDL for Package PON_PO_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_PO_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: PONGPOIS.pls 120.0 2005/06/01 16:02:34 appldev noship $ */

TYPE TBL_NUM IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE TBL_V1 IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

TYPE PURGE_IN_RECTYPE IS RECORD
( entity_name VARCHAR2(50),
  entity_ids  TBL_NUM
);

TYPE PURGE_OUT_RECTYPE IS RECORD
( purge_allowed TBL_V1
);

PROCEDURE validate_po_purge
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2,
  p_in_rec        IN         PURGE_IN_RECTYPE,
  x_out_rec       OUT NOCOPY PURGE_OUT_RECTYPE
);

PROCEDURE po_purge
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2,
  p_in_rec        IN         PURGE_IN_RECTYPE
);

END PON_PO_INTEGRATION_GRP;

 

/
