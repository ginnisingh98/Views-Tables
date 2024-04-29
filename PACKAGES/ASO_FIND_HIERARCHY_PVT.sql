--------------------------------------------------------
--  DDL for Package ASO_FIND_HIERARCHY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_FIND_HIERARCHY_PVT" AUTHID CURRENT_USER AS
/* $Header: asovqres.pls 120.1 2005/06/29 12:44:04 appldev ship $ */

  TYPE hier_rec_type IS RECORD (
    depth           NUMBER := FND_API.G_MISS_NUM ,
    line_num        NUMBER := FND_API.G_MISS_NUM ,
    parent_line_id  Number := FND_API.G_MISS_NUM ,
    quote_line_id   NUMBER := FND_API.G_MISS_NUM ,
    inventory_item_id NUMBER := FND_API.G_MISS_NUM ,
    inventory_item  VARCHAR2(2000) := FND_API.G_MISS_CHAR ,
    description     varchar2(2000) := FND_API.G_MISS_CHAR ,
    item_revision   VARCHAR2(2000) := FND_API.G_MISS_CHAR ,
    uom_code        VARCHAR2(2000) := FND_API.G_MISS_CHAR ,
   -- inventory_item  VARCHAR2(40) := FND_API.G_MISS_CHAR ,
   -- description     varchar2(240) := FND_API.G_MISS_CHAR ,
   -- item_revision   VARCHAR2(3) := FND_API.G_MISS_CHAR ,
   -- uom_code        VARCHAR2(3) := FND_API.G_MISS_CHAR ,
    quantity        NUMBER  := FND_API.G_MISS_NUM ,
    amount          NUMBER  := FND_API.G_MISS_NUM ,
    adjusted_amount NUMBER  := FND_API.G_MISS_NUM ,
    qty_factor      NUMBER  := FND_API.G_MISS_NUM ,
    included_flag   VARCHAR2(2000) := 'N'  ) ;
   -- included_flag   VARCHAR2(1) := 'N'  ) ;


  Type hier_tbl_type IS TABLE OF hier_rec_type
                        INDEX BY BINARY_INTEGER;

  G_qte_lines_tbl  hier_tbl_type ;
  G_hier_tbl    hier_tbl_type ;
  G_Miss_tbl    hier_tbl_type ;

  TYPE relation_rec_type IS RECORD (
     quote_line_id    NUMBER := FND_API.G_MISS_NUM ,
     related_quote_line_id  NUMBER := FND_API.G_MISS_NUM );

  TYPE relation_tbl_type IS TABLE OF relation_rec_type
                            INDEX BY BINARY_INTEGER ;

  G_relation_tbl  relation_tbl_type ;
  G_Miss_reln_tbl relation_tbl_type ;

   PROCEDURE Populate_hier( p_quote_header_id   IN  NUMBER ,
                           x_hier_tbl  OUT NOCOPY /* file.sql.39 change */   hier_tbl_type ,
                           x_return_status  OUT NOCOPY /* file.sql.39 change */   VARCHAR2  ,
                           x_msg_count      OUT NOCOPY /* file.sql.39 change */   NUMBER    ,
                           x_msg_data       OUT NOCOPY /* file.sql.39 change */   VARCHAR2 );
End ASO_FInd_Hierarchy_pvt ;

 

/
