--------------------------------------------------------
--  DDL for Package MRP_OM_API_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_OM_API_PK" AUTHID CURRENT_USER AS
/* $Header: MRPOAPIS.pls 115.2 2002/11/22 01:18:37 schaudha noship $  */

Type line_id_tbl IS TABLE of NUMBER  INDEX BY BINARY_INTEGER;


PROCEDURE MRP_OM_Interface (
               p_line_tbl        IN  line_id_tbl,
               x_return_status  OUT NOCOPY varchar2
);


END MRP_OM_API_PK;

 

/
