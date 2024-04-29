--------------------------------------------------------
--  DDL for Package Body IBE_SHOP_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_SHOP_LIST_PVT" AS
/* $Header: IBEVQSLB.pls 120.3 2005/10/05 04:09:16 banatara noship $ */

l_true VARCHAR2(1) := FND_API.G_TRUE;

FUNCTION Find_Index(
   p_id      IN NUMBER,
   p_num_tbl IN jtf_number_table
)
RETURN NUMBER
IS
  l_index NUMBER := 0;
BEGIN
   IF p_num_tbl.COUNT > 0 THEN
      FOR i IN p_num_tbl.FIRST..p_num_tbl.LAST LOOP
         IF p_num_tbl(i) = p_id THEN
            l_index := i;
            EXIT;
         END IF;
      END LOOP;
   END IF;

   RETURN l_index;
END Find_Index;


FUNCTION Find_Index(
   p_id        IN NUMBER,
   p_id_tbl    IN jtf_number_table,
   p_index_tbl IN jtf_number_table
)
RETURN NUMBER
IS
  l_index NUMBER := 0;
BEGIN
   IF p_id_tbl.COUNT > 0 THEN
      FOR i IN p_id_tbl.FIRST..p_id_tbl.LAST LOOP
         IF p_id_tbl(i) = p_id THEN
            l_index := p_index_tbl(i);
            EXIT;
         END IF;
      END LOOP;
   END IF;

   RETURN l_index;
END Find_Index;


FUNCTION Find_Same_Item_In_Qte_Line_Tbl(
   p_qte_line_tbl      IN ASO_Quote_Pub.Qte_Line_Tbl_Type,
   p_inventory_item_id IN NUMBER                         ,
   p_uom_code          IN VARCHAR2
)
RETURN NUMBER
IS
   l_index NUMBER := 0;
BEGIN
   IF p_qte_line_tbl.COUNT > 0 THEN
      FOR i IN p_qte_line_tbl.FIRST..p_qte_line_tbl.LAST LOOP
         IF  p_qte_line_tbl(i).item_type_code    = 'STD'
         AND p_qte_line_tbl(i).inventory_item_id = p_inventory_item_id
         AND p_qte_line_tbl(i).uom_code          = p_uom_code THEN
            l_index := i;
            EXIT;
         END IF;
      END LOOP;
   END IF;

   RETURN l_index;
END Find_Same_Item_In_Qte_Line_Tbl;


FUNCTION Find_Same_Item_In_Lst_Line_Tbl(
   p_list_line_tbl     IN IBE_Shop_List_PVT.SL_Line_Tbl_Type,
   p_inventory_item_id IN NUMBER                            ,
   p_uom_code          IN VARCHAR2
)
RETURN NUMBER
IS
   l_index NUMBER := 0;
BEGIN
   IF p_list_line_tbl.COUNT > 0 THEN
      FOR i IN p_list_line_tbl.FIRST..p_list_line_tbl.LAST LOOP
         IF  p_list_line_tbl(i).item_type_code    = 'STD'
         AND p_list_line_tbl(i).inventory_item_id = p_inventory_item_id
         AND p_list_line_tbl(i).uom_code          = p_uom_code THEN
            l_index := i;
            EXIT;
         END IF;
      END LOOP;
   END IF;
   RETURN l_index;
END Find_Same_Item_In_Lst_Line_Tbl;


FUNCTION Get_Line_IDs_From_Headers(p_list_header_id_tbl IN jtf_number_table)
RETURN jtf_number_table
IS
   TYPE Csr_Type IS REF CURSOR;
   line_csr           Csr_Type;
   rel_line_csr       Csr_Type;
   l_line_id          NUMBER;
   l_rel_line_id      NUMBER;
   l_item_type_code   VARCHAR2(30);
   l_list_line_id_tbl jtf_number_table := jtf_number_table();
   l_list_header_id   NUMBER;
BEGIN
   FOR i IN p_list_header_id_tbl.FIRST..p_list_header_id_tbl.LAST LOOP
      l_list_header_id := p_list_header_id_tbl(i);

      OPEN line_csr FOR SELECT I.shp_list_item_id,
                               I.item_type_code
                        FROM ibe_sh_shp_list_items I
                        WHERE I.shp_list_id = l_list_header_id
                          AND I.item_type_code NOT IN ('CFG', 'OPT', 'SRV');
      LOOP
         FETCH line_csr INTO l_line_id,
                             l_item_type_code;
         EXIT WHEN line_csr%NOTFOUND;

         l_list_line_id_tbl.EXTEND;
         l_list_line_id_tbl(l_list_line_id_tbl.LAST) := l_line_id;

         IF l_item_type_code = 'MDL' OR l_item_type_code = 'SVA' THEN
            OPEN rel_line_csr FOR SELECT R.related_shp_list_item_id
                                  FROM ibe_sh_shlitem_rels R
                                  START WITH R.shp_list_item_id = l_line_id
                                  CONNECT BY R.shp_list_item_id = PRIOR R.related_shp_list_item_id;
           LOOP
              FETCH rel_line_csr INTO l_rel_line_id;
              EXIT WHEN rel_line_csr%NOTFOUND;

              l_list_line_id_tbl.EXTEND;
              l_list_line_id_tbl(l_list_line_id_tbl.LAST) := l_rel_line_id;
           END LOOP;

           CLOSE rel_line_csr;
         END IF;
      END LOOP;

      CLOSE line_csr;
   END LOOP;

   RETURN l_list_line_id_tbl;
END Get_Line_IDs_From_Headers;


/*
 * This procedure returns the out parameter x_list_line_id_tbl
 * which includes all the related items of p_list_line_id_tbl.
 * This also construct the out paramter x_qte_line_relation_tbl.
 */
PROCEDURE Include_Related_Lines(
   p_qte_line_rel_tbl       IN  VARCHAR2        ,
   p_list_line_id_tbl       IN  jtf_number_table,
   x_list_line_id_tbl       OUT NOCOPY jtf_number_table,
   x_qte_line_relation_tbl  OUT NOCOPY ASO_Quote_Pub.Line_Rltship_Tbl_Type,
   x_list_line_relation_tbl OUT NOCOPY SL_Line_Rel_Tbl_Type)
IS
   TYPE rel_line_csr_type IS REF CURSOR;
   rel_line_csr rel_line_csr_type;
   l_line_id                NUMBER;
   l_rel_line_id            NUMBER;
   l_relationship_type_code VARCHAR2(30);
   k                        PLS_INTEGER := 1; -- index for x_qte_line_relation_tbl
BEGIN
   x_list_line_id_tbl := jtf_number_table();

   FOR i IN p_list_line_id_tbl.FIRST..p_list_line_id_tbl.LAST LOOP
      x_list_line_id_tbl.EXTEND;
      x_list_line_id_tbl(x_list_line_id_tbl.LAST) := p_list_line_id_tbl(i);

      /*
       * Hierarchical query to retrieve all the descendents of a line
       */
      OPEN rel_line_csr FOR 'SELECT shp_list_item_id, '||
                                   'related_shp_list_item_id, ' ||
                                   'relationship_type_code ' ||
                            'FROM ibe_sh_shlitem_rels ' ||
                            'START WITH shp_list_item_id = :1 '||
                            'CONNECT BY shp_list_item_id = PRIOR related_shp_list_item_id'
                        USING p_list_line_id_tbl(i);
      LOOP
         FETCH rel_line_csr INTO l_line_id,
                                 l_rel_line_id,
                                 l_relationship_type_code;
         EXIT WHEN rel_line_csr%NOTFOUND;

         -- added 3/28/03: avoid saving SRV info
         IF (l_relationship_type_code <> 'SERVICE') then
           x_list_line_id_tbl.EXTEND;
           x_list_line_id_tbl(x_list_line_id_tbl.LAST) := l_rel_line_id;

           IF FND_API.to_Boolean(p_qte_line_rel_tbl) THEN
              FOR j IN x_list_line_id_tbl.FIRST..x_list_line_id_tbl.LAST LOOP
                 IF x_list_line_id_tbl(j) = l_line_id THEN
                    x_qte_line_relation_tbl(k).qte_line_index := j;
                    EXIT;
                 END IF;
              END LOOP;

              x_qte_line_relation_tbl(k).related_qte_line_index := x_list_line_id_tbl.LAST;
              x_qte_line_relation_tbl(k).relationship_type_code := l_relationship_type_code;
              x_qte_line_relation_tbl(k).operation_code         := 'CREATE';
              k := k + 1;
           ELSE
              FOR j IN x_list_line_id_tbl.FIRST..x_list_line_id_tbl.LAST LOOP
                 IF x_list_line_id_tbl(j) = l_line_id THEN
                    x_list_line_relation_tbl(k).line_index := j;
                    EXIT;
                 END IF;
              END LOOP;

              x_list_line_relation_tbl(k).related_line_index := x_list_line_id_tbl.LAST;
              x_list_line_relation_tbl(k).relationship_type_code := l_relationship_type_code;
              x_list_line_relation_tbl(k).operation_code         := 'CREATE';
              k := k + 1;
           END IF;
         END IF;
      END LOOP;

      CLOSE rel_line_csr;
   END LOOP;
END Include_Related_Lines;


/* Constructs x_qte_line_rel_tbl if p_to_create_quote is TRUE, that is, this
 * procedure is called to create a quote from lists.
 * Constructs x_list_line_rel_tbl if p_to_create_quote is FALSE, that is, this
 * procedure is called to create a list from lists.
 */
PROCEDURE Get_Line_Rels_From_Lines(
   p_to_create_quote    IN  BOOLEAN       ,
   p_list_header_id_tbl IN  jtf_number_table,
   p_list_line_id_tbl   IN  jtf_number_table,
   p_line_index_tbl     IN  jtf_number_table,
   x_qte_line_rel_tbl   OUT NOCOPY ASO_Quote_Pub.Line_Rltship_Tbl_Type,
   x_list_line_rel_tbl  OUT NOCOPY SL_Line_Rel_Tbl_Type
)
IS
   TYPE Csr_Type IS REF CURSOR;
   l_csr                    Csr_Type;
   j                        PLS_INTEGER := 1; -- index for l_qte_line_relation_tbl
   l_line_id                NUMBER;
   l_related_line_id        NUMBER;
   l_relationship_type_code VARCHAR2(30);
   l_list_header_id         NUMBER;
BEGIN
   FOR i IN p_list_header_id_tbl.FIRST..p_list_header_id_tbl.LAST LOOP
      l_list_header_id := p_list_header_id_tbl(i);
      OPEN l_csr FOR SELECT R.shp_list_item_id,
                            R.related_shp_list_item_id,
                            R.relationship_type_code
                     FROM ibe_sh_shp_list_items L,
                          ibe_sh_shlitem_rels   R
                     WHERE L.shp_list_id = l_list_header_id
                       AND R.shp_list_item_id = L.shp_list_item_id;
      LOOP
         FETCH l_csr INTO l_line_id,
                          l_related_line_id,
                          l_relationship_type_code;
         EXIT WHEN l_csr%NOTFOUND;

         -- added 3/28/03: avoid saving SRV info
         if (l_relationship_type_code <> 'SERVICE') then
           /* This procedure is called to create a quote from lists */
           IF p_to_create_quote THEN
              x_qte_line_rel_tbl(j).operation_code := 'CREATE';
              x_qte_line_rel_tbl(j).qte_line_index
                 := Find_Index(l_line_id, p_list_line_id_tbl, p_line_index_tbl);
              x_qte_line_rel_tbl(j).related_qte_line_index
                 := Find_Index(l_related_line_id, p_list_line_id_tbl, p_line_index_tbl);
              x_qte_line_rel_tbl(j).relationship_type_code
                 := l_relationship_type_code;
           /* This procedure is called to create a list from lists */
           ELSE
              x_list_line_rel_tbl(j).operation_code := 'CREATE';
              x_list_line_rel_tbl(j).line_index
                 := Find_Index(l_line_id, p_list_line_id_tbl, p_line_index_tbl);
              x_list_line_rel_tbl(j).related_line_index
                 := Find_Index(l_related_line_id, p_list_line_id_tbl, p_line_index_tbl);
              x_list_line_rel_tbl(j).relationship_type_code
                 := l_relationship_type_code;
           END IF;

           j := j + 1;
         end if;
      END LOOP;

      CLOSE l_csr;
   END LOOP;
END Get_Line_Rels_From_Lines;


PROCEDURE Set_List_Lines_From_List_Lines(
   p_list_line_id_tbl     IN  jtf_number_table                  ,
   p_list_header_id       IN  NUMBER                            ,
   p_combine_same_item    IN  VARCHAR2 := FND_API.G_MISS_CHAR   ,
   x_list_line_tbl        OUT NOCOPY IBE_Shop_List_PVT.SL_Line_Tbl_Type,
   x_list_line_id_map_tbl OUT NOCOPY jtf_number_table                  ,
   x_list_line_index_tbl  OUT NOCOPY jtf_number_table
)
IS
   TYPE Csr_Type IS REF CURSOR;
   l_csr                         Csr_Type;
   l_shp_list_item_id            NUMBER;
   l_inventory_item_id           NUMBER;
   l_organization_id             NUMBER;
   l_uom_code                    VARCHAR2(3);
   l_quantity                    NUMBER;
   l_item_type_code              VARCHAR2(30);
   l_config_header_id            NUMBER;
   l_config_revision_num         NUMBER;
   l_complete_configuration_flag VARCHAR2(3);
   l_valid_configuration_flag    VARCHAR2(3);
   l_relationship_type_code      VARCHAR2(30);
   l_attribute_category          VARCHAR2(30);
   l_attribute1                  VARCHAR2(150);
   l_attribute2                  VARCHAR2(150);
   l_attribute3                  VARCHAR2(150);
   l_attribute4                  VARCHAR2(150);
   l_attribute5                  VARCHAR2(150);
   l_attribute6                  VARCHAR2(150);
   l_attribute7                  VARCHAR2(150);
   l_attribute8                  VARCHAR2(150);
   l_attribute9                  VARCHAR2(150);
   l_attribute10                 VARCHAR2(150);
   l_attribute11                 VARCHAR2(150);
   l_attribute12                 VARCHAR2(150);
   l_attribute13                 VARCHAR2(150);
   l_attribute14                 VARCHAR2(150);
   l_attribute15                 VARCHAR2(150);

   l_list_line_id                NUMBER;
   l_list_line_id_tbl            jtf_number_table := jtf_number_table();
   i                             PLS_INTEGER      := 1; -- index for x_qte_line_tbl
   j                             PLS_INTEGER      := 1; -- index for x_qte_line_detail_tbl
   l_list_line_tbl_index         PLS_INTEGER;
   l_line_id                     NUMBER;
BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Set_List_Lines_From_List_Lines(+)...');
   END IF;
   x_list_line_id_map_tbl := jtf_number_table();
   x_list_line_index_tbl   := jtf_number_table();

   FOR k IN 1..p_list_line_id_tbl.COUNT LOOP
      SELECT shp_list_item_id,
             inventory_item_id,
             quantity,
             uom_code,
             organization_id,
             config_header_id,
             config_revision_num,
             complete_configuration_flag,
             valid_configuration_flag,
             item_type_code,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15
      INTO l_shp_list_item_id,
           l_inventory_item_id,
           l_quantity,
           l_uom_code,
           l_organization_id,
           l_config_header_id,
           l_config_revision_num,
           l_complete_configuration_flag,
           l_valid_configuration_flag,
           l_item_type_code,
           l_attribute_category,
           l_attribute1,
           l_attribute2,
           l_attribute3,
           l_attribute4,
           l_attribute5,
           l_attribute6,
           l_attribute7,
           l_attribute8,
           l_attribute9,
           l_attribute10,
           l_attribute11,
           l_attribute12,
           l_attribute13,
           l_attribute14,
           l_attribute15
      FROM ibe_sh_shp_list_items
      WHERE shp_list_item_id = p_list_line_id_tbl(k);

      IF p_combine_same_item = 'Y' AND l_item_type_code = 'STD' THEN
         l_list_line_tbl_index := Find_Same_Item_In_Lst_Line_Tbl(
                                     p_list_line_tbl     => x_list_line_tbl    ,
                                     p_inventory_item_id => l_inventory_item_id,
                                     p_uom_code          => l_uom_code);

         /*
          * if l_list_line_tbl_index <> 0, there is already a line in x_qte_line_tbl
          * for same standard item.  Don't add a new line and just update the quantity.
          */
         IF l_list_line_tbl_index <> 0 THEN
            x_list_line_tbl(l_list_line_tbl_index).quantity
               := x_list_line_tbl(l_list_line_tbl_index).quantity + l_quantity;
         ELSE
            x_list_line_tbl(i).shp_list_id       := p_list_header_id;
            x_list_line_tbl(i).inventory_item_id := l_inventory_item_id;
            x_list_line_tbl(i).organization_id   := l_organization_id;
            x_list_line_tbl(i).uom_code          := l_uom_code;
            x_list_line_tbl(i).item_type_code    := l_item_type_code;
            x_list_line_tbl(i).quantity          := l_quantity;

            /*
             * find same item IN aso_quote_lines view where item_type_code is 'STD',
             * and inventory_item_id, organization_id, and uom_code matches with this line
             */
            BEGIN
               SELECT shp_list_item_id,
                      quantity
               INTO l_list_line_id,
                    l_quantity
               FROM ibe_sh_shp_list_items
               WHERE shp_list_id       = p_list_header_id
                 AND organization_id   = l_organization_id
                 AND item_type_code    = 'STD'
                 AND inventory_item_id = l_inventory_item_id
                 AND uom_code          = l_uom_code;

               x_list_line_tbl(i).operation_code := 'UPDATE';
               x_list_line_tbl(i).shp_list_item_id  := l_list_line_id;
               x_list_line_tbl(i).quantity := x_list_line_tbl(i).quantity + l_quantity;
            EXCEPTION
               /*
                * We get to NO_DATA_FOUND block when there is no line in
                * x_list_line_tbl nor in ibe_sh_shp_list_items table for the same item.
                */
               WHEN NO_DATA_FOUND THEN
                  x_list_line_tbl(i).operation_code     := 'CREATE';
			   --commented by makulkar
			   /*
                  x_list_line_tbl(i).attribute_category := l_attribute_category;
                  x_list_line_tbl(i).attribute1         := l_attribute1;
                  x_list_line_tbl(i).attribute2         := l_attribute2;
                  x_list_line_tbl(i).attribute3         := l_attribute3;
                  x_list_line_tbl(i).attribute4         := l_attribute4;
                  x_list_line_tbl(i).attribute5         := l_attribute5;
                  x_list_line_tbl(i).attribute6         := l_attribute6;
                  x_list_line_tbl(i).attribute7         := l_attribute7;
                  x_list_line_tbl(i).attribute8         := l_attribute8;
                  x_list_line_tbl(i).attribute9         := l_attribute9;
                  x_list_line_tbl(i).attribute10        := l_attribute10;
                  x_list_line_tbl(i).attribute11        := l_attribute11;
                  x_list_line_tbl(i).attribute12        := l_attribute12;
                  x_list_line_tbl(i).attribute13        := l_attribute13;
                  x_list_line_tbl(i).attribute14        := l_attribute14;
                  x_list_line_tbl(i).attribute15        := l_attribute15;
			   */
            END;

            x_list_line_id_map_tbl.EXTEND;
            x_list_line_index_tbl.EXTEND;
            x_list_line_id_map_tbl(x_list_line_id_map_tbl.LAST)
               := p_list_line_id_tbl(k);
            x_list_line_index_tbl(x_list_line_index_tbl.LAST) := i;

            i := i + 1;
         END IF;
      /*
       * p_combine_same_item = 'N' OR l_item_type_code <> 'STD',
       * which means that we are safe to add a new line
       */
      ELSE
         x_list_line_tbl(i).operation_code              := 'CREATE';
         x_list_line_tbl(i).shp_list_id                 := p_list_header_id;
         x_list_line_tbl(i).inventory_item_id           := l_inventory_item_id;
         x_list_line_tbl(i).organization_id             := l_organization_id;
         x_list_line_tbl(i).uom_code                    := l_uom_code;
         x_list_line_tbl(i).item_type_code              := l_item_type_code;
         x_list_line_tbl(i).quantity                    := l_quantity;
         x_list_line_tbl(i).config_header_id            := l_config_header_id;
         x_list_line_tbl(i).config_revision_num         := l_config_revision_num;
         x_list_line_tbl(i).complete_configuration_flag := l_complete_configuration_flag;
         x_list_line_tbl(i).valid_configuration_flag    := l_valid_configuration_flag;
	    --commented by makulkar
	    /*
         x_list_line_tbl(i).attribute_category          := l_attribute_category;
         x_list_line_tbl(i).attribute1                  := l_attribute1;
         x_list_line_tbl(i).attribute2                  := l_attribute2;
         x_list_line_tbl(i).attribute3                  := l_attribute3;
         x_list_line_tbl(i).attribute4                  := l_attribute4;
         x_list_line_tbl(i).attribute5                  := l_attribute5;
         x_list_line_tbl(i).attribute6                  := l_attribute6;
         x_list_line_tbl(i).attribute7                  := l_attribute7;
         x_list_line_tbl(i).attribute8                  := l_attribute8;
         x_list_line_tbl(i).attribute9                  := l_attribute9;
         x_list_line_tbl(i).attribute10                 := l_attribute10;
         x_list_line_tbl(i).attribute11                 := l_attribute11;
         x_list_line_tbl(i).attribute12                 := l_attribute12;
         x_list_line_tbl(i).attribute13                 := l_attribute13;
         x_list_line_tbl(i).attribute14                 := l_attribute14;
         x_list_line_tbl(i).attribute15                 := l_attribute15;
	    */

         x_list_line_id_map_tbl.EXTEND;
         x_list_line_index_tbl.EXTEND;
         x_list_line_id_map_tbl(x_list_line_id_map_tbl.LAST)
            := p_list_line_id_tbl(k);
         x_list_line_index_tbl(x_list_line_index_tbl.LAST) := i;

         i := i + 1;
      END IF;
   END LOOP;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Set_List_Lines_From_List_Lines(-)...');
   END IF;
END Set_List_Lines_From_List_Lines;

PROCEDURE Delete_Config_From_Shp_List(
   p_shp_list_ids           IN jtf_number_table,
   p_shp_list_line_ids      IN jtf_number_table,
   p_usage_exists           IN OUT NOCOPY NUMBER,
   p_error_message          IN OUT NOCOPY VARCHAR2,
   p_return_value           IN OUT NOCOPY NUMBER
)
IS

TYPE csr_type is REF CURSOR;
C_GET_CONFIG_LINES        csr_type;
l_line_config_id          NUMBER;
l_line_config_revnum      NUMBER;
l_list_ids                VARCHAR2(300);
l_list_line_ids           VARCHAR2(300);
l_cursor_string CONSTANT  VARCHAR2(200) := 'SELECT DISTINCT ' ||
                                                 'config_header_id, ' ||
                                                 'config_revision_num '||
                                                 ' FROM   ibe_sh_shp_list_items ' ||
                                                 ' WHERE';

BEGIN
    IF p_shp_list_ids IS NOT NULL OR p_shp_list_line_ids IS NOT NULL THEN
        IF p_shp_list_ids IS NOT NULL THEN
            FOR i IN 1..p_shp_list_ids.count LOOP
                IF i > 1 THEN
                    l_list_ids := l_list_ids || ',';
                END IF;
                l_list_ids := l_list_ids || p_shp_list_ids(i);
            END LOOP;
            l_list_ids := l_list_ids || ')';
            OPEN C_GET_CONFIG_LINES FOR l_cursor_string || ' shp_list_id in (' || l_list_ids;
        ELSIF p_shp_list_line_ids IS NOT NULL THEN
            FOR i IN 1..p_shp_list_line_ids.count LOOP
                IF i > 1 THEN
                    l_list_line_ids := l_list_line_ids || ',';
                END IF;
                l_list_line_ids := l_list_line_ids || p_shp_list_line_ids(i);
            END LOOP;
            l_list_line_ids := l_list_line_ids || ')';
            OPEN C_GET_CONFIG_LINES FOR l_cursor_string || ' shp_list_item_id in (' ||  l_list_line_ids;
        END IF;
        LOOP
            FETCH C_GET_CONFIG_LINES INTO l_line_config_id, l_line_config_revnum;
            EXIT WHEN C_GET_CONFIG_LINES%NOTFOUND;
	    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('Calling Delete_Configuration for' || l_line_config_id || ', ' || l_line_config_revnum);
	    END IF;
            CZ_CF_API.delete_configuration(
                  config_hdr_id  => l_line_config_id    ,
                  config_rev_nbr => l_line_config_revnum,
                  usage_exists   => p_usage_exists      ,
                  error_message  => p_error_message     ,
                  return_value   => p_return_value);
        END LOOP;
    END IF;
END Delete_Config_From_Shp_List;

PROCEDURE Delete(
   p_api_version     IN  NUMBER   := 1              ,
   p_init_msg_list   IN  VARCHAR2 := FND_API.G_TRUE ,
   p_commit          IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status   OUT NOCOPY VARCHAR2            ,
   x_msg_count       OUT NOCOPY NUMBER              ,
   x_msg_data        OUT NOCOPY VARCHAR2            ,
   p_shop_list_ids   IN  jtf_number_table           ,
   p_obj_ver_numbers IN  jtf_number_table
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Delete';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   L_USER_ID     CONSTANT NUMBER       := FND_GLOBAL.User_ID;
   l_shop_list_line_id     NUMBER;
   l_shop_list_rel_line_id NUMBER;
   l_return_value          NUMBER;
   l_usage_exists          NUMBER;

   CURSOR C_GET_LIST_LINES(l_shp_list_id NUMBER) IS
      SELECT shp_list_item_id
      FROM ibe_sh_shp_list_items
      WHERE shp_list_id = l_shp_list_id;

   CURSOR C_GET_REL_LINES(l_shp_list_id NUMBER) IS
      SELECT ISSR.shlitem_rel_id
      FROM ibe_sh_shlitem_rels   ISSR,
           ibe_sh_shp_list_items ISSLI
      WHERE ISSR.shp_list_item_id = ISSLI.shp_list_item_id
        AND ISSLI.shp_list_id = l_shp_list_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Delete_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Delete(+)');
   -- API body

      IBE_Util.Debug('Delete Configuration Using list ids - Start');
   END IF;
   Delete_Config_From_Shp_List(
                                   p_shp_list_ids       => p_shop_list_ids,
                                   p_shp_list_line_ids => NULL,
                                   p_usage_exists      => l_usage_exists,
                                   p_error_message     => x_msg_data,
                                   p_return_value      => l_return_value);
   IF l_return_value = 0 THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Done CZ_CF_API.delete_configuration at '
           || TO_CHAR(SYSDATE, 'mm/dd/yyyy:hh24:MI:SS'));
   END IF;

   FOR i IN 1..p_shop_list_ids.count LOOP
      -- delete line relationships
      OPEN C_GET_REL_LINES(p_shop_list_ids(i));
         LOOP
            FETCH C_GET_REL_LINES into l_shop_list_rel_line_id;
            EXIT WHEN C_GET_REL_LINES%NOTFOUND;

            IBE_ShopList_Line_Relation_PKG.Delete_Row(
               p_SHLITEM_REL_ID  => l_shop_list_rel_line_id);
         END LOOP;
      CLOSE C_GET_REL_LINES;

      -- delete list lines
      OPEN C_GET_LIST_LINES(p_shop_list_ids(i));
         LOOP
            FETCH C_GET_LIST_LINES into l_shop_list_line_id;
            EXIT WHEN C_GET_LIST_LINES%NOTFOUND;

            IBE_Shop_List_Line_PKG.Delete_Row(
               p_SHP_LIST_ITEM_ID  => l_shop_list_line_id);
         END LOOP;
      CLOSE C_GET_LIST_LINES;

      BEGIN
         -- delete list header
         IBE_Shop_List_Header_PKG.Delete_Row(
            p_SHP_LIST_ID           => p_shop_list_ids(i),
            p_OBJECT_VERSION_NUMBER => p_obj_ver_numbers(i));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.set_name('IBE', 'IBE_SL_UPDATE_TO_LIST_ERROR');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
      END;
   END LOOP;

   -- End of API body.
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Delete(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO Delete_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END Delete;


PROCEDURE Delete_All_Lines(
   p_api_version     IN  NUMBER   := 1              ,
   p_init_msg_list   IN  VARCHAR2 := FND_API.G_TRUE ,
   p_commit          IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status   OUT NOCOPY VARCHAR2            ,
   x_msg_count       OUT NOCOPY NUMBER              ,
   x_msg_data        OUT NOCOPY VARCHAR2            ,
   p_shop_list_ids   IN  jtf_number_table           ,
   p_obj_ver_numbers IN  jtf_number_table
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Delete_All_Lines';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   L_USER_ID     CONSTANT NUMBER       := FND_GLOBAL.User_ID;
   l_shop_list_line_id     NUMBER;
   l_shop_list_rel_line_id NUMBER;
   l_return_value          NUMBER;
   l_usage_exists          NUMBER;

   CURSOR C_GET_LIST_LINES(l_shp_list_id NUMBER) IS

      SELECT SHP_LIST_ITEM_ID
      FROM IBE_SH_SHP_LIST_ITEMS
      WHERE SHP_LIST_ID = l_Shp_List_Id;

   CURSOR C_GET_REL_LINES(l_shp_list_id NUMBER) IS

      SELECT IBE_SH_SHLITEM_RELS.SHLITEM_REL_ID
      FROM IBE_SH_SHLITEM_RELS, IBE_SH_SHP_LIST_ITEMS
      WHERE IBE_SH_SHLITEM_RELS.SHP_LIST_ITEM_ID = IBE_SH_SHP_LIST_ITEMS.SHP_LIST_ITEM_ID
         AND IBE_SH_SHP_LIST_ITEMS.SHP_LIST_ID = l_Shp_List_Id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Delete_All_Lines_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Delete_All_Lines(+)');
   -- API body

      IBE_Util.Debug('Delete Configuration Using list ids - Start');
   END IF;
   Delete_Config_From_Shp_List(
                                   p_shp_list_ids      => p_shop_list_ids,
                                   p_shp_list_line_ids => NULL,
                                   p_usage_exists      => l_usage_exists,
                                   p_error_message     => x_msg_data,
                                   p_return_value      => l_return_value);
   IF l_return_value = 0 THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Done CZ_CF_API.delete_configuration at '
           || TO_CHAR(SYSDATE, 'mm/dd/yyyy:hh24:MI:SS'));
   END IF;

   FOR i IN 1..p_shop_list_ids.count LOOP
      -- delete line relationships
      OPEN C_GET_REL_LINES(p_shop_list_ids(i));
         LOOP
            FETCH C_GET_REL_LINES into l_shop_list_rel_line_id;
            EXIT WHEN C_GET_REL_LINES%NOTFOUND;

            IBE_ShopList_Line_Relation_PKG.Delete_Row(
               p_SHLITEM_REL_ID  => l_shop_list_rel_line_id);
         END LOOP;
      CLOSE C_GET_REL_LINES;

      -- delete list lines
      OPEN C_GET_LIST_LINES(p_shop_list_ids(i));
         LOOP
            FETCH C_GET_LIST_LINES into l_shop_list_line_id;
            EXIT WHEN C_GET_LIST_LINES%NOTFOUND;

            IBE_Shop_List_Line_PKG.Delete_Row(
               p_SHP_LIST_ITEM_ID  => l_shop_list_line_id);
          END LOOP;
      CLOSE C_GET_LIST_LINES;

      -- update object version NUMBER for shopping list
      UPDATE IBE_SH_SHP_LISTS
      SET OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
      WHERE SHP_LIST_ID = p_shop_list_ids(i)
      AND OBJECT_VERSION_NUMBER = p_obj_ver_numbers(i);

      IF (SQL%NOTFOUND) THEN
        FND_MESSAGE.set_name('IBE', 'IBE_SL_UPDATE_TO_LIST_ERROR');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;

   -- End of API body.
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Delete_All_Lines(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_All_Lines_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_All_Lines_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO Delete_All_Lines_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END Delete_All_Lines;


PROCEDURE Delete_Line(
  p_object_version_number IN  NUMBER,
  p_Shp_List_Item_Id      IN  NUMBER
)
IS
    l_shp_list_item_id_tbl  jtf_number_table;
    l_index                 NUMBER;
    l_count                 NUMBER;
    l_shp_list_item_id      NUMBER;
    l_shop_list_rel_line_id NUMBER;

    CURSOR c1 IS
       SELECT RELATED_SHP_LIST_ITEM_ID
       FROM IBE_SH_SHLITEM_RELS
       WHERE SHP_LIST_ITEM_ID = p_Shp_List_Item_Id;

    CURSOR C_GET_REL_LINES(l_shp_list_line_id NUMBER) IS
       SELECT SHLITEM_REL_ID
       FROM IBE_SH_SHLITEM_RELS
       WHERE SHP_LIST_ITEM_ID = l_shp_list_line_id;

BEGIN
    --   DBMS_OUTPUT.PUT_LINE('Inside Delete_line p_Shp_List_Item_Id = ' || p_Shp_List_Item_Id);
    --   DBMS_OUTPUT.PUT_LINE('Inside Delete_line p_object_version_number = ' || p_object_version_number);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('IBE_Shop_List_PVT.Delete_Line(+)...');
    END IF;

    l_shp_list_item_id_tbl := jtf_number_table();

    SELECT COUNT(*) into l_count
    FROM IBE_SH_SHLITEM_RELS
    WHERE SHP_LIST_ITEM_ID  = p_Shp_List_Item_Id;

    l_shp_list_item_id_tbl.extend(l_count);

    l_index := 1;

    OPEN c1;

    LOOP
       FETCH c1 into l_shp_list_item_id;
       EXIT WHEN c1%NOTFOUND;

       l_shp_list_item_id_tbl(l_index) := l_shp_list_item_id;

       -- increment counter
       l_index := l_index + 1;
    END LOOP;

    CLOSE c1;

    FOR i IN 1..l_count LOOP
       IBE_Shop_List_PVT.Delete_Line(
          p_object_version_number => p_object_version_number,
          p_Shp_List_Item_Id      => l_shp_list_item_id_tbl(i));

    END LOOP;

    -- delete line relationships
    OPEN C_GET_REL_LINES(p_SHP_LIST_ITEM_ID);

       LOOP

          FETCH C_GET_REL_LINES into l_shop_list_rel_line_id;
          EXIT WHEN C_GET_REL_LINES%NOTFOUND;

          IBE_ShopList_Line_Relation_PKG.Delete_Row(
             p_SHLITEM_REL_ID  => l_shop_list_rel_line_id);

       END LOOP;

    CLOSE C_GET_REL_LINES;

    IBE_Shop_List_Line_PKG.Delete_Row(
       p_SHP_LIST_ITEM_ID      => p_SHP_LIST_ITEM_ID,
       p_object_version_number => p_object_version_number);

END Delete_Line;

PROCEDURE Delete_Lines(
   p_api_version         IN  NUMBER   := 1              ,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_TRUE ,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status       OUT NOCOPY VARCHAR2            ,
   x_msg_count           OUT NOCOPY NUMBER              ,
   x_msg_data            OUT NOCOPY VARCHAR2            ,
   p_shop_list_line_ids  IN  jtf_number_table           ,
   p_obj_ver_numbers     IN  jtf_number_table
)
IS
   L_API_NAME    CONSTANT  VARCHAR2(30) := 'Delete_Lines';
   L_API_VERSION CONSTANT    NUMBER       := 1.0;
   L_USER_ID     CONSTANT    NUMBER       := FND_GLOBAL.User_ID;
   l_shop_list_id            NUMBER;
   l_shop_list_line_id       NUMBER;
   l_shop_list_rel_line_id   NUMBER;
   l_count                   NUMBER;
   l_usage_exists            NUMBER;
   l_return_value            NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Delete_Lines_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Delete_Lines(+)');
   END IF;
   -- API body

   l_count := p_shop_list_line_ids.COUNT;

   -- DBMS_OUTPUT.PUT_LINE('L_COUNT = ' || l_count);
   -- DBMS_OUTPUT.PUT_LINE('l_shop_list_id = ' || l_shop_list_id);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Delete Configuration Using line ids - Start');
   END IF;
   Delete_Config_From_Shp_List(
                                   p_shp_list_ids       => NULL,
                                   p_shp_list_line_ids => p_shop_list_line_ids,
                                   p_usage_exists      => l_usage_exists,
                                   p_error_message     => x_msg_data,
                                   p_return_value      => l_return_value);

   IF l_return_value = 0 THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Done CZ_CF_API.delete_configuration at '
           || TO_CHAR(SYSDATE, 'mm/dd/yyyy:hh24:MI:SS'));
   END IF;

   -- select shp_list_id to update object_version_number of the list
   IF l_count > 0 THEN
   BEGIN
      select SHP_LIST_ID into l_shop_list_id
      from IBE_SH_SHP_LIST_ITEMS
      where SHP_LIST_ITEM_ID = p_shop_list_line_ids(1);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.set_name('IBE', 'IBE_SL_UPDATE_TO_LIST_ERROR');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
   END;
   END IF;

   -- DBMS_OUTPUT.PUT_LINE('l_shop_list_id = ' || l_shop_list_id);

   FOR i IN 1..l_count LOOP
      BEGIN
         -- DBMS_OUTPUT.PUT_LINE('Calling Delete_line p_shop_list_line_id = ' || p_shop_list_line_ids(i));
         -- DBMS_OUTPUT.PUT_LINE('Calling Delete_line p_object_version_number = ' || p_obj_ver_numbers(i));

         Delete_Line(
            p_object_version_number => p_obj_ver_numbers(i),
            p_Shp_List_Item_Id      => p_shop_list_line_ids(i));
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.set_name('IBE', 'IBE_SL_UPDATE_TO_LIST_ERROR');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
      END;
   END LOOP;

   -- dbms_output.put_line('now updating header');
   -- update object version NUMBER for shopping list
   UPDATE IBE_SH_SHP_LISTS
   SET OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
   WHERE SHP_LIST_ID = l_shop_list_id;

   IF (SQL%NOTFOUND) THEN
      FND_MESSAGE.set_name('IBE', 'IBE_SL_UPDATE_TO_LIST_ERROR');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- End of API body.
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Delete_Lines(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Lines_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Lines_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Lines_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END Delete_Lines;

PROCEDURE Save(
   p_api_version       IN  NUMBER   := 1                                 ,
   p_init_msg_list     IN  VARCHAR2 := FND_API.G_TRUE                    ,
   p_commit            IN  VARCHAR2 := FND_API.G_FALSE                   ,
   x_return_status     OUT NOCOPY VARCHAR2                               ,
   x_msg_count         OUT NOCOPY NUMBER                                 ,
   x_msg_data          OUT NOCOPY VARCHAR2                               ,
   p_combine_same_item IN  VARCHAR2 := FND_API.G_MISS_CHAR               ,
   p_sl_header_rec     IN  SL_Header_Rec_Type                            ,
   p_sl_line_tbl       IN  SL_Line_Tbl_Type     := G_MISS_SL_LINE_TBL    ,
   p_sl_line_rel_tbl   IN  SL_Line_Rel_Tbl_Type := G_MISS_SL_LINE_REL_TBL,
   x_sl_header_id      OUT NOCOPY NUMBER
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Save';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   L_USER_ID     CONSTANT NUMBER       := FND_GLOBAL.User_ID;
   TYPE Number_Tbl_Type IS TABLE OF NUMBER
                           INDEX BY BINARY_INTEGER;
   l_line_id_tbl       Number_Tbl_Type;
   i                   PLS_INTEGER;
   l_shp_list_item_id  NUMBER;
   l_quantity          NUMBER;
   l_sl_line_rel_id    NUMBER;
   l_combine_same_item VARCHAR2(30);
   l_sl_line_rec       SL_Line_Rec_Type;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Save_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Save(+)');
   END IF;
   --dbms_output.put_line('IBE_Shop_List_PVT.Save(+)');
   -- API body

   IF p_combine_same_item = FND_API.G_MISS_CHAR THEN
      l_combine_same_item := FND_Profile.Value('IBE_SC_MERGE_SHOPCART_LINES');
   ELSE
      l_combine_same_item := p_combine_same_item;
   END IF;

   --dbms_output.put_line('Saving list header');

   IF p_sl_header_rec.shp_list_id = FND_API.G_MISS_NUM THEN
   --  A new shopping list.  Create a shopping list.
      --dbms_output.put_line('New line to be created for header');

      BEGIN

         --dbms_output.put_line('p_sl_header_rec.party_id = ' || p_sl_header_rec.party_id);
         --dbms_output.put_line('p_sl_header_rec.cust_account_id = ' || p_sl_header_rec.cust_account_id);
         --dbms_output.put_line('p_sl_header_rec.shopping_list_name = ' || p_sl_header_rec.shopping_list_name);
         --dbms_output.put_line('p_sl_header_rec.description = ' || p_sl_header_rec.description);
         --dbms_output.put_line('p_sl_header_rec.org_id = ' || p_sl_header_rec.org_id);
         --dbms_output.put_line('p_sl_header_rec.shp_list_id = ' || p_sl_header_rec.shp_list_id);

         IBE_Shop_List_Header_PKG.Insert_Row(
            x_shp_list_id            => x_sl_header_id                         ,
            p_request_id             => p_sl_header_rec.request_id             ,
            p_program_application_id => p_sl_header_rec.program_application_id ,
            p_program_id             => p_sl_header_rec.program_id             ,
            p_program_update_date    => p_sl_header_rec.program_update_date    ,
            p_object_version_number  => p_sl_header_rec.object_version_number  ,
            p_created_by             => p_sl_header_rec.created_by             ,
            p_creation_date          => p_sl_header_rec.creation_date          ,
            p_last_updated_by        => p_sl_header_rec.last_updated_by        ,
            p_last_update_date       => p_sl_header_rec.last_update_date       ,
            p_last_update_login      => p_sl_header_rec.last_update_login      ,
            p_party_id               => p_sl_header_rec.party_id               ,
            p_cust_account_id        => p_sl_header_rec.cust_account_id        ,
            p_shopping_list_name     => p_sl_header_rec.shopping_list_name     ,
            p_description            => p_sl_header_rec.description            ,
            p_attribute_category     => p_sl_header_rec.attribute_category     ,
            p_attribute1             => p_sl_header_rec.attribute1             ,
            p_attribute2             => p_sl_header_rec.attribute2             ,
            p_attribute3             => p_sl_header_rec.attribute3             ,
            p_attribute4             => p_sl_header_rec.attribute4             ,
            p_attribute5             => p_sl_header_rec.attribute5             ,
            p_attribute6             => p_sl_header_rec.attribute6             ,
            p_attribute7             => p_sl_header_rec.attribute7             ,
            p_attribute8             => p_sl_header_rec.attribute8             ,
            p_attribute9             => p_sl_header_rec.attribute9             ,
            p_attribute10            => p_sl_header_rec.attribute10            ,
            p_attribute11            => p_sl_header_rec.attribute11            ,
            p_attribute12            => p_sl_header_rec.attribute12            ,
            p_attribute13            => p_sl_header_rec.attribute13            ,
            p_attribute14            => p_sl_header_rec.attribute14            ,
            p_attribute15            => p_sl_header_rec.attribute15            ,
            p_org_id                 => p_sl_header_rec.org_id);

         --dbms_output.put_line('New line created for header, shp_list_id = ' || x_sl_header_id);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            FND_MESSAGE.set_name('IBE', 'IBE_SL_DUPLICATE_LISTNAME');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;

         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.set_name('IBE', 'IBE_SL_UPDATE_TO_LIST_ERROR');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
      END;
   ELSE
   --  Existing shopping list.  Update the shopping list.
      --dbms_output.put_line('Update header');
      BEGIN
         IBE_Shop_List_Header_PKG.Update_Row(
            p_shp_list_id            => p_sl_header_rec.shp_list_id            ,
            p_request_id             => p_sl_header_rec.request_id             ,
            p_program_application_id => p_sl_header_rec.program_application_id ,
            p_program_id             => p_sl_header_rec.program_id             ,
            p_program_update_date    => p_sl_header_rec.program_update_date    ,
            p_object_version_number  => p_sl_header_rec.object_version_number  ,
            p_created_by             => p_sl_header_rec.created_by             ,
            p_creation_date          => p_sl_header_rec.creation_date          ,
            p_last_updated_by        => p_sl_header_rec.last_updated_by        ,
            p_last_update_date       => p_sl_header_rec.last_update_date       ,
            p_last_update_login      => p_sl_header_rec.last_update_login      ,
            p_party_id               => p_sl_header_rec.party_id               ,
            p_cust_account_id        => p_sl_header_rec.cust_account_id        ,
            p_shopping_list_name     => p_sl_header_rec.shopping_list_name     ,
            p_description            => p_sl_header_rec.description            ,
            p_attribute_category     => p_sl_header_rec.attribute_category     ,
            p_attribute1             => p_sl_header_rec.attribute1             ,
            p_attribute2             => p_sl_header_rec.attribute2             ,
            p_attribute3             => p_sl_header_rec.attribute3             ,
            p_attribute4             => p_sl_header_rec.attribute4             ,
            p_attribute5             => p_sl_header_rec.attribute5             ,
            p_attribute6             => p_sl_header_rec.attribute6             ,
            p_attribute7             => p_sl_header_rec.attribute7             ,
            p_attribute8             => p_sl_header_rec.attribute8             ,
            p_attribute9             => p_sl_header_rec.attribute9             ,
            p_attribute10            => p_sl_header_rec.attribute10            ,
            p_attribute11            => p_sl_header_rec.attribute11            ,
            p_attribute12            => p_sl_header_rec.attribute12            ,
            p_attribute13            => p_sl_header_rec.attribute13            ,
            p_attribute14            => p_sl_header_rec.attribute14            ,
            p_attribute15            => p_sl_header_rec.attribute15            ,
            p_org_id                 => p_sl_header_rec.org_id);

         x_sl_header_id := p_sl_header_rec.shp_list_id;
         --dbms_output.put_line('header updated, shp_list_id = ' || x_sl_header_id);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            FND_MESSAGE.set_name('IBE', 'IBE_SL_DUPLICATE_LISTNAME');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;

         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.set_name('IBE', 'IBE_SL_UPDATE_TO_LIST_ERROR');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
      END;
   END IF;

   --dbms_output.put_line('After saving header x_sl_header_id = ' || x_sl_header_id);
   --dbms_output.put_line('p_sl_line_tbl.count = ' || p_sl_line_tbl.count);

   IF p_sl_line_tbl.COUNT > 0 THEN
   -- There are shopping list line
      FOR i IN 1..p_sl_line_tbl.COUNT LOOP
         l_sl_line_rec := p_sl_line_tbl(i);

         --dbms_output.put_line('Checking whether to update the quantity or insert new line');

         IF p_sl_header_rec.shp_list_id <> FND_API.G_MISS_NUM
         AND l_sl_line_rec.shp_list_item_id = FND_API.G_MISS_NUM
         AND l_sl_line_rec.item_type_code = 'STD'
         AND l_combine_same_item = 'Y' THEN
            BEGIN
               SELECT shp_list_item_id, quantity
               INTO l_shp_list_item_id, l_quantity
               FROM ibe_sh_shp_list_items
               WHERE shp_list_id = p_sl_header_rec.shp_list_id
                 AND inventory_item_id = l_sl_line_rec.inventory_item_id
                 AND organization_id   = l_sl_line_rec.organization_id
                 AND uom_code          = l_sl_line_rec.uom_code
                 AND item_type_code    = 'STD';

               l_sl_line_rec.shp_list_item_id := l_shp_list_item_id;
               l_sl_line_rec.quantity := l_sl_line_rec.quantity + l_quantity;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;
         END IF;

         --dbms_output.put_line('Checking for the line whether to insert or update the line');

         IF l_sl_line_rec.shp_list_item_id = FND_API.G_MISS_NUM THEN
         -- New line.  Add a line.
            --dbms_output.put_line('Inserting line ' || i);

            IBE_Shop_List_Line_PKG.Insert_Row(
               x_shp_list_item_id            => l_shp_list_item_id                           ,
               p_object_version_number       => l_sl_line_rec.object_version_number       ,
               p_creation_date               => l_sl_line_rec.creation_date               ,
               p_created_by                  => l_sl_line_rec.created_by                  ,
               p_last_updated_by             => l_sl_line_rec.last_updated_by             ,
               p_last_update_date            => l_sl_line_rec.last_update_date            ,
               p_last_update_login           => l_sl_line_rec.last_update_login           ,
               p_request_id                  => l_sl_line_rec.request_id                  ,
               p_program_id                  => l_sl_line_rec.program_id                  ,
               p_program_application_id      => l_sl_line_rec.program_application_id      ,
               p_program_update_date         => l_sl_line_rec.program_update_date         ,
               p_shp_list_id                 => x_sl_header_id                            ,
               p_inventory_item_id           => l_sl_line_rec.inventory_item_id           ,
               p_organization_id             => l_sl_line_rec.organization_id             ,
               p_uom_code                    => l_sl_line_rec.uom_code                    ,
               p_quantity                    => l_sl_line_rec.quantity                    ,
               p_config_header_id            => l_sl_line_rec.config_header_id            ,
               p_config_revision_num         => l_sl_line_rec.config_revision_num         ,
               p_complete_configuration_flag => l_sl_line_rec.complete_configuration_flag ,
               p_valid_configuration_flag    => l_sl_line_rec.valid_configuration_flag    ,
               p_item_type_code              => l_sl_line_rec.item_type_code              ,
               p_attribute_category          => l_sl_line_rec.attribute_category          ,
               p_attribute1                  => l_sl_line_rec.attribute1                  ,
               p_attribute2                  => l_sl_line_rec.attribute2                  ,
               p_attribute3                  => l_sl_line_rec.attribute3                  ,
               p_attribute4                  => l_sl_line_rec.attribute4                  ,
               p_attribute5                  => l_sl_line_rec.attribute5                  ,
               p_attribute6                  => l_sl_line_rec.attribute6                  ,
               p_attribute7                  => l_sl_line_rec.attribute7                  ,
               p_attribute8                  => l_sl_line_rec.attribute8                  ,
               p_attribute9                  => l_sl_line_rec.attribute9                  ,
               p_attribute10                 => l_sl_line_rec.attribute10                 ,
               p_attribute11                 => l_sl_line_rec.attribute11                 ,
               p_attribute12                 => l_sl_line_rec.attribute12                 ,
               p_attribute13                 => l_sl_line_rec.attribute13                 ,
               p_attribute14                 => l_sl_line_rec.attribute14                 ,
               p_attribute15                 => l_sl_line_rec.attribute15                 ,
               p_org_id                      => l_sl_line_rec.org_id);
            l_line_id_tbl(i) := l_shp_list_item_id;

            --dbms_output.put_line('l_line_id_tbl(' || i || ') = ' || l_line_id_tbl(i));

         ELSE
         -- Existing line.  Update the line.
            --dbms_output.put_line('Updating line ' || i);
            IBE_Shop_List_Line_PKG.Update_Row(
               p_shp_list_item_id            => l_sl_line_rec.shp_list_item_id            ,
               p_object_version_number       => l_sl_line_rec.object_version_number       ,
               p_creation_date               => l_sl_line_rec.creation_date               ,
               p_created_by                  => l_sl_line_rec.created_by                  ,
               p_last_updated_by             => l_sl_line_rec.last_updated_by             ,
               p_last_update_date            => l_sl_line_rec.last_update_date            ,
               p_last_update_login           => l_sl_line_rec.last_update_login           ,
               p_request_id                  => l_sl_line_rec.request_id                  ,
               p_program_id                  => l_sl_line_rec.program_id                  ,
               p_program_application_id      => l_sl_line_rec.program_application_id      ,
               p_program_update_date         => l_sl_line_rec.program_update_date         ,
               p_shp_list_id                 => l_sl_line_rec.shp_list_id                 ,
               p_inventory_item_id           => l_sl_line_rec.inventory_item_id           ,
               p_organization_id             => l_sl_line_rec.organization_id             ,
               p_uom_code                    => l_sl_line_rec.uom_code                    ,
               p_quantity                    => l_sl_line_rec.quantity                    ,
               p_config_header_id            => l_sl_line_rec.config_header_id            ,
               p_config_revision_num         => l_sl_line_rec.config_revision_num         ,
               p_complete_configuration_flag => l_sl_line_rec.complete_configuration_flag ,
               p_valid_configuration_flag    => l_sl_line_rec.valid_configuration_flag    ,
               p_item_type_code              => l_sl_line_rec.item_type_code              ,
               p_attribute_category          => l_sl_line_rec.attribute_category          ,
               p_attribute1                  => l_sl_line_rec.attribute1                  ,
               p_attribute2                  => l_sl_line_rec.attribute2                  ,
               p_attribute3                  => l_sl_line_rec.attribute3                  ,
               p_attribute4                  => l_sl_line_rec.attribute4                  ,
               p_attribute5                  => l_sl_line_rec.attribute5                  ,
               p_attribute6                  => l_sl_line_rec.attribute6                  ,
               p_attribute7                  => l_sl_line_rec.attribute7                  ,
               p_attribute8                  => l_sl_line_rec.attribute8                  ,
               p_attribute9                  => l_sl_line_rec.attribute9                  ,
               p_attribute10                 => l_sl_line_rec.attribute10                 ,
               p_attribute11                 => l_sl_line_rec.attribute11                 ,
               p_attribute12                 => l_sl_line_rec.attribute12                 ,
               p_attribute13                 => l_sl_line_rec.attribute13                 ,
               p_attribute14                 => l_sl_line_rec.attribute14                 ,
               p_attribute15                 => l_sl_line_rec.attribute15                 ,
               p_org_id                      => l_sl_line_rec.org_id);
            l_line_id_tbl(i) := l_sl_line_rec.shp_list_item_id;
         END IF;
      END LOOP;

      --dbms_output.put_line('After saving list lines');
      --dbms_output.put_line('Before saving related lines');

      IF p_sl_line_rel_tbl.COUNT > 0 THEN
      -- There are shopping list line relationships
         FOR i IN 1..p_sl_line_rel_tbl.COUNT LOOP
            IF p_sl_line_rel_tbl(i).shp_list_item_id = FND_API.G_MISS_NUM THEN
            -- New line relationship.  Add a line relationship.
               IBE_ShopList_Line_Relation_PKG.Insert_Row(
                  x_shlitem_rel_id           => l_sl_line_rel_id                          ,
                  p_request_id               => p_sl_line_rel_tbl(i).request_id               ,
                  p_program_application_id   => p_sl_line_rel_tbl(i).program_application_id   ,
                  p_program_id               => p_sl_line_rel_tbl(i).program_id               ,
                  p_program_update_date      => p_sl_line_rel_tbl(i).program_update_date      ,
                  p_object_version_number    => p_sl_line_rel_tbl(i).object_version_number    ,
                  p_created_by               => p_sl_line_rel_tbl(i).created_by               ,
                  p_creation_date            => p_sl_line_rel_tbl(i).creation_date            ,
                  p_last_updated_by          => p_sl_line_rel_tbl(i).last_updated_by          ,
                  p_last_update_date         => p_sl_line_rel_tbl(i).last_update_date         ,
                  p_last_update_login        => p_sl_line_rel_tbl(i).last_update_login        ,
                  p_shp_list_item_id         => l_line_id_tbl(p_sl_line_rel_tbl(i).line_index),
                  p_related_shp_list_item_id => l_line_id_tbl(p_sl_line_rel_tbl(i).related_line_index),
                  p_relationship_type_code   => p_sl_line_rel_tbl(i).relationship_type_code);
            END IF;
         END LOOP;
      END IF;

      --dbms_output.put_line('After saving related lines');

   END IF;
   -- End of API body.
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Save(-)');
   END IF;
   --dbms_output.put_line('IBE_Shop_List_PVT.Save(-)');

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Save_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Save_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO Save_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END Save;


PROCEDURE Update_Config_Item_Lines(
   x_return_status     OUT NOCOPY     VARCHAR2,
   x_msg_count         OUT NOCOPY     NUMBER  ,
   x_msg_data          OUT NOCOPY     VARCHAR2,
   px_sl_line_tbl      IN OUT NOCOPY  SL_Line_Tbl_Type
)
IS
   L_API_NAME       CONSTANT VARCHAR2(30) := 'Update_Config_Item_Lines';
   l_old_config_header_id    NUMBER;
   l_new_config_header_id    NUMBER;
   l_old_config_revision_num NUMBER;
   l_new_config_revision_num NUMBER;

   -- ER#4025142
   --l_return_value            NUMBER;
   l_api_version    CONSTANT NUMBER         := 1.0;
   l_ret_status VARCHAR2(1);
   l_msg_count  INTEGER;
   l_orig_item_id_tbl  CZ_API_PUB.number_tbl_type;
   l_new_item_id_tbl   CZ_API_PUB.number_tbl_type;

BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Update_Config_Item_Lines(+)');
   END IF;

   -- API body
   FOR i IN 1..px_sl_line_tbl.COUNT LOOP
      IF px_sl_line_tbl(i).item_type_code = 'MDL' THEN
         l_old_config_header_id    := px_sl_line_tbl(i).config_header_id;
         l_old_config_revision_num := px_sl_line_tbl(i).config_revision_num;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('old config header id = '|| l_old_config_header_id);
            IBE_Util.Debug('old config revision NUMBER = '|| l_old_config_revision_num);
            IBE_Util.Debug('Call CZ_CONFIG_API_PUB.copy_configuration at'
                  || TO_CHAR(SYSDATE, 'mm/dd/yyyy:hh24:MI:SS'));
        END IF;

         --ER#4025142
         CZ_CONFIG_API_PUB.copy_configuration(p_api_version => l_api_version
                            ,p_config_hdr_id        => l_old_config_header_id
                            ,p_config_rev_nbr       => l_old_config_revision_num
                            ,p_copy_mode            => CZ_API_PUB.G_NEW_HEADER_COPY_MODE
                            ,x_config_hdr_id        => l_new_config_header_id
                            ,x_config_rev_nbr       => l_new_config_revision_num
                            ,x_orig_item_id_tbl     => l_orig_item_id_tbl
                            ,x_new_item_id_tbl      => l_new_item_id_tbl
                            ,x_return_status        => l_ret_status
                            ,x_msg_count            => l_msg_count
                            ,x_msg_data             => x_msg_data);
         IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Done CZ_CONFIG_API_PUB.Copy_Configuration at'
                 || TO_CHAR(SYSDATE, 'mm/dd/yyyy:hh24:MI:SS'));
         END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('new config header id = '|| l_new_config_header_id);
            IBE_Util.Debug('new config revision NUMBER = '|| l_new_config_revision_num);
         END IF;

         -- update all other dtl table
         FOR j IN 1..px_sl_line_tbl.COUNT LOOP
            IF  px_sl_line_tbl(j).config_header_id    = l_old_config_header_id
            AND px_sl_line_tbl(j).config_revision_num = l_old_config_revision_num THEN
               px_sl_line_tbl(j).config_header_id    := l_new_config_header_id;
               px_sl_line_tbl(j).config_revision_num := l_new_config_revision_num;
            END IF;
         END LOOP;
      END IF;
   END LOOP;
   -- End of API body.

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Update_Config_Item_Lines(-)');
   END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END Update_Config_Item_Lines;


PROCEDURE Save_List_From_Items(
   p_api_version       IN  NUMBER   := 1                  ,
   p_init_msg_list     IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit            IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status     OUT NOCOPY VARCHAR2                ,
   x_msg_count         OUT NOCOPY NUMBER                  ,
   x_msg_data          OUT NOCOPY VARCHAR2                ,
   p_sl_line_ids       IN  jtf_number_table               ,
   p_sl_line_ovns      IN  jtf_number_table := NULL       ,
   p_mode              IN  VARCHAR2 := 'MERGE'            ,
   p_combine_same_item IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_sl_header_rec     IN  SL_Header_Rec_Type             ,
   x_sl_header_id      OUT NOCOPY NUMBER
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Save_List_From_Items';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   L_USER_ID     CONSTANT NUMBER       := FND_GLOBAL.User_ID;

   l_list_line_id_map_tbl  jtf_number_table := jtf_number_table();
   l_list_line_index_tbl   jtf_number_table := jtf_number_table();
   l_list_header_id_tbl    jtf_number_table;
   l_obj_ver_num_tbl       jtf_number_table;
   l_list_line_id_tbl      jtf_number_table := jtf_number_table();
   l_sl_header_rec         SL_Header_Rec_Type;
   l_sl_line_tbl           SL_Line_Tbl_Type;
   l_sl_line_rel_tbl       SL_Line_Rel_Tbl_Type;
   l_qte_line_relation_tbl ASO_Quote_Pub.Line_Rltship_Tbl_Type;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Save_List_From_Items_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Save_List_From_Items(+)');
   END IF;
   -- API body

   -- IF p_sl_header_rec.shp_list_id is not null, i.e. mode will be either 'ADDTO' or 'REPLACE'.
   -- IN this case we just take leave header information as it is, but is p_sl_header_rec.shp_list_id
   -- is null, we create new line for shopping list header.

   --dbms_output.put_line('p_sl_header_rec.shp_list_id = ' || p_sl_header_rec.shp_list_id);
   l_sl_header_rec := p_sl_header_rec;

   IF (l_sl_header_rec.shp_list_id <> FND_API.G_MISS_NUM) THEN
      IF (p_mode = 'REPLACE') THEN
         -- create jtf_number_table of list id and obj. ver num to pass to Delete_All_Lines
         l_list_header_id_tbl := jtf_number_table(l_sl_header_rec.shp_list_id);
         l_obj_ver_num_tbl := jtf_number_table(l_sl_header_rec.object_version_number);

         IBE_Shop_List_PVT.Delete_All_Lines(
            p_api_version         =>  p_api_version,
            p_init_msg_list       =>  p_init_msg_list,
            p_commit              =>  p_commit,
            x_return_status       =>  x_return_status,
            x_msg_count           =>  x_msg_count,
            x_msg_data            =>  x_msg_data,
            p_shop_list_ids       =>  l_list_header_id_tbl,
            p_obj_ver_numbers     =>  l_obj_ver_num_tbl);

         IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- Delete_All_Lines updates object_version_number of shopping list
         -- header, therefore IF we pass p_object_version_number IN save THEN
         -- it will fail as it has been incremented by one. Set it to
         -- FND_API.G_MISS_NUM so that save() will not fail.
         l_sl_header_rec.object_version_number := FND_API.G_MISS_NUM;
      END IF;
   END IF;

   /*
    * Call Include_Related_Lines() to include all the related lines, i.e.,
    * all the children lines of configurable items.
    */
   Include_Related_Lines(
      p_qte_line_rel_tbl       => FND_API.G_FALSE   ,
      p_list_line_id_tbl       => p_sl_line_ids     ,
      x_list_line_id_tbl       => l_list_line_id_tbl,
      x_qte_line_relation_tbl  => l_qte_line_relation_tbl,
      x_list_line_relation_tbl => l_sl_line_rel_tbl);

   Set_List_Lines_From_List_Lines(
      p_list_line_id_tbl     => l_list_line_id_tbl         ,
      p_list_header_id       => l_sl_header_rec.shp_list_id,
      p_combine_same_item    => p_combine_same_item        ,
      x_list_line_tbl        => l_sl_line_tbl              ,
      x_list_line_id_map_tbl => l_list_line_id_map_tbl     ,
      x_list_line_index_tbl  => l_list_line_index_tbl);

   Update_Config_Item_Lines(
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count    ,
      x_msg_data      => x_msg_data     ,
      px_sl_line_tbl  => l_sl_line_tbl);

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --dbms_output.put_line('p_sl_header_rec.shp_list_id = ' || p_sl_header_rec.shp_list_id);
   --dbms_output.put_line('p_sl_header_rec.party_id = ' || p_sl_header_rec.party_id);
   --dbms_output.put_line('p_sl_header_rec.cust_account_id = ' || p_sl_header_rec.cust_account_id);
   --dbms_output.put_line('p_sl_header_rec.shopping_list_name = ' || p_sl_header_rec.shopping_list_name);
   --dbms_output.put_line('p_sl_header_rec.description = ' || p_sl_header_rec.description);
   --dbms_output.put_line('p_sl_header_rec.org_id = ' || p_sl_header_rec.org_id);


   --dbms_output.put_line('l_sl_line_tbl.count = ' || l_sl_line_tbl.count);
/*
   for k IN 1..l_sl_line_tbl.count loop
      --dbms_output.put_line('l_sl_line_tbl(' || k || ').inventory_item_id = ' || l_sl_line_tbl(k).inventory_item_id);
      --dbms_output.put_line('l_sl_line_tbl(' || k || ').organization_id = ' || l_sl_line_tbl(k).organization_id);
      --dbms_output.put_line('l_sl_line_tbl(' || k || ').uom_code = ' || l_sl_line_tbl(k).uom_code);
      --dbms_output.put_line('l_sl_line_tbl(' || k || ').quantity = ' || l_sl_line_tbl(k).quantity);
      --dbms_output.put_line('l_sl_line_tbl(' || k || ').item_type_code = ' || l_sl_line_tbl(k).item_type_code);
      --dbms_output.put_line('l_sl_line_tbl(' || k || ').org_id = ' || l_sl_line_tbl(k).org_id);
   end loop;
*/
   --dbms_output.put_line('l_sl_line_rel_tbl.count = ' || l_sl_line_rel_tbl.count);
/*
   for l IN 1..l_sl_line_rel_tbl.count loop
      --dbms_output.put_line('l_sl_line_rel_tbl(' || l || ').line_index = ' || l_sl_line_rel_tbl(l).line_index);
      --dbms_output.put_line('l_sl_line_rel_tbl(' || l || ').related_line_index = ' || l_sl_line_rel_tbl(l).related_line_index);
      --dbms_output.put_line('l_sl_line_rel_tbl(' || l || ').relationship_type_code =' || l_sl_line_rel_tbl(l).relationship_type_code);
   end loop;
*/
   --dbms_output.put_line('Calling Save...');

   BEGIN
      IBE_Shop_List_PVT.Save(
         p_api_version       => p_api_version,
         p_init_msg_list     => p_init_msg_list,
         p_commit            => p_commit,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
         p_combine_same_item => p_combine_same_item,
         p_sl_header_rec     => l_sl_header_rec,
         p_sl_line_tbl       => l_sl_line_tbl,
         p_sl_line_rel_tbl   => l_sl_line_rel_tbl,
         x_sl_header_id      => x_sl_header_id
      );
      --dbms_output.put_line('x_return_status = ' || x_return_status);
      --dbms_output.put_line('x_msg_count = ' || x_msg_count);
      --dbms_output.put_line('x_msg_data = ' || x_msg_data);
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.set_name('IBE', 'IBE_SL_UPDATE_TO_LIST_ERROR');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
   END;

   --dbms_output.put_line('After Save...');

   -- End of API body.
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Save_List_From_Items(-)');
   END IF;
   --dbms_output.put_line('IBE_Shop_List_PVT.Save_List_From_Items(-)');

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Save_List_From_Items_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Save_List_From_Items_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO Save_List_From_Items_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END Save_List_From_Items;


PROCEDURE Save_List_From_Quote(
   p_api_version            IN  NUMBER   := 1                  ,
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                 IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status          OUT NOCOPY VARCHAR2                ,
   x_msg_count              OUT NOCOPY NUMBER                  ,
   x_msg_data               OUT NOCOPY VARCHAR2                ,
   p_quote_header_id        IN  NUMBER                         ,
   p_quote_retrieval_number IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_minisite_id            IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_last_update_date       IN  DATE     := FND_API.G_MISS_DATE,
   p_mode                   IN  VARCHAR2 := 'MERGE'            ,
   p_combine_same_item      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_sl_header_rec          IN  SL_Header_Rec_Type             ,
   x_sl_header_id           OUT NOCOPY NUMBER
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Save_List_From_Quote';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   L_USER_ID     CONSTANT NUMBER       := FND_GLOBAL.User_ID;
   L_ORG_ID      CONSTANT NUMBER       := FND_Profile.Value('ORG_ID');

   TYPE Csr_Type IS REF CURSOR;
   l_csr                         Csr_Type;
   l_csr_rel                     Csr_Type;
   l_sl_header_rec               SL_Header_Rec_Type;
   l_sl_line_tbl                 SL_Line_Tbl_Type
                                    := IBE_Shop_List_PVT.G_MISS_SL_LINE_TBL;
   l_sl_line_rel_tbl             SL_Line_Rel_Tbl_Type
                                    := IBE_Shop_List_PVT.G_MISS_SL_LINE_REL_TBL;

   i                             NUMBER := 1;  -- index for l_sl_line_tbl
   j                             NUMBER := 1;  -- index for l_sl_line_rel_tbl

   l_list_header_id_tbl          jtf_number_table;
   l_obj_ver_num_tbl             jtf_number_table;

   l_quote_line_id               NUMBER;
   l_inventory_item_id           NUMBER;
   l_quantity                    NUMBER;
   l_uom_code                    VARCHAR2(30);
   l_organization_id             NUMBER;
   l_shp_list_item_id            NUMBER;
   l_config_header_id            NUMBER := -2;
   l_config_revision_num         NUMBER;
   l_complete_configuration_flag VARCHAR2(3);
   l_valid_configuration_flag    VARCHAR2(3);
   l_item_type_code              VARCHAR2(30);
   l_attribute_category          VARCHAR2(30);
   l_attribute1                  VARCHAR2(150);
   l_attribute2                  VARCHAR2(150);
   l_attribute3                  VARCHAR2(150);
   l_attribute4                  VARCHAR2(150);
   l_attribute5                  VARCHAR2(150);
   l_attribute6                  VARCHAR2(150);
   l_attribute7                  VARCHAR2(150);
   l_attribute8                  VARCHAR2(150);
   l_attribute9                  VARCHAR2(150);
   l_attribute10                 VARCHAR2(150);
   l_attribute11                 VARCHAR2(150);
   l_attribute12                 VARCHAR2(150);
   l_attribute13                 VARCHAR2(150);
   l_attribute14                 VARCHAR2(150);
   l_attribute15                 VARCHAR2(150);
   l_pricing_line_type_indicator VARCHAR2(3);

   l_quote_line_id_tbl           jtf_number_table := jtf_number_table();
   l_quote_line_index_tbl        jtf_number_table := jtf_number_table();

   l_related_quote_line_id       NUMBER;
   l_relationship_type_code      VARCHAR2(30);

   l_PRG_configHdrId_tbl         jtf_number_table := jtf_number_table();
   l_PRGchildren_lineId_tbl      jtf_number_table := jtf_number_table();
   l_checkPRGChild               NUMBER := 0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Save_List_From_Quote_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Save_List_From_Quote(+)');
   END IF;
   -- API body


   -- User Authentication
   IBE_Quote_Misc_pvt.Validate_User_Update
   (	 p_init_msg_list                => FND_API.G_TRUE
	 ,p_quote_header_id		=> p_quote_header_id
	 ,p_party_id     		=> p_sl_header_rec.party_id
	 ,p_cust_account_id		=> p_sl_header_rec.cust_account_id
	 ,p_quote_retrieval_number      => p_quote_retrieval_number
	 ,p_validate_user		=> FND_API.G_TRUE
	 ,x_return_status               => x_return_status
         ,x_msg_count                   => x_msg_count
         ,x_msg_data                    => x_msg_data
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- IF p_sl_header_rec.shp_list_id is not null, i.e. mode will be either 'ADDTO' or 'REPLACE'.
   -- In this case we just take leave header information as it is, but is p_sl_header_rec.shp_list_id
   -- is null, we create new line for shopping list header.
   l_sl_header_rec := p_sl_header_rec;

   IF (p_sl_header_rec.shp_list_id <> FND_API.G_MISS_NUM) THEN
      IF (p_mode = 'REPLACE') THEN
         -- create jtf_number_table of list id and obj. ver num to pass to Delete_All_Lines
         l_list_header_id_tbl := jtf_number_table(l_sl_header_rec.shp_list_id);
         l_obj_ver_num_tbl    := jtf_number_table(l_sl_header_rec.object_version_number);

         IBE_Shop_List_PVT.Delete_All_Lines(
            p_api_version         =>  p_api_version,
            p_init_msg_list       =>  p_init_msg_list,
            p_commit              =>  p_commit,
            x_return_status       =>  x_return_status,
            x_msg_count           =>  x_msg_count,
            x_msg_data            =>  x_msg_data,
            p_shop_list_ids       =>  l_list_header_id_tbl,
            p_obj_ver_numbers     =>  l_obj_ver_num_tbl);

         IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- Delete_All_Lines updates object_version_number of shopping list
         -- header, therefore IF we pass p_object_version_number IN save THEN
         -- it will fail as it has been incremented by one. Set it to
         -- FND_API.G_MISS_NUM so that save() will not fail.
         l_sl_header_rec.object_version_number := FND_API.G_MISS_NUM;
      END IF;
   END IF;

   --commented by makulkar
   /*
   SELECT DECODE(l_sl_header_rec.attribute_category, FND_API.G_MISS_CHAR, attribute_category, l_sl_header_rec.attribute_CATEGORY),
          DECODE(l_sl_header_rec.attribute1,  FND_API.G_MISS_CHAR, attribute1,  l_sl_header_rec.attribute1),
          DECODE(l_sl_header_rec.attribute2,  FND_API.G_MISS_CHAR, attribute2,  l_sl_header_rec.attribute2),
          DECODE(l_sl_header_rec.attribute3,  FND_API.G_MISS_CHAR, attribute3,  l_sl_header_rec.attribute3),
          DECODE(l_sl_header_rec.attribute4,  FND_API.G_MISS_CHAR, attribute4,  l_sl_header_rec.attribute4),
          DECODE(l_sl_header_rec.attribute5,  FND_API.G_MISS_CHAR, attribute5,  l_sl_header_rec.attribute5),
          DECODE(l_sl_header_rec.attribute6,  FND_API.G_MISS_CHAR, attribute6,  l_sl_header_rec.attribute6),
          DECODE(l_sl_header_rec.attribute7,  FND_API.G_MISS_CHAR, attribute7,  l_sl_header_rec.attribute7),
          DECODE(l_sl_header_rec.attribute8,  FND_API.G_MISS_CHAR, attribute8,  l_sl_header_rec.attribute8),
          DECODE(l_sl_header_rec.attribute9,  FND_API.G_MISS_CHAR, attribute9,  l_sl_header_rec.attribute9),
          DECODE(l_sl_header_rec.attribute10, FND_API.G_MISS_CHAR, attribute10, l_sl_header_rec.attribute10),
          DECODE(l_sl_header_rec.attribute11, FND_API.G_MISS_CHAR, attribute11, l_sl_header_rec.attribute11),
          DECODE(l_sl_header_rec.attribute12, FND_API.G_MISS_CHAR, attribute12, l_sl_header_rec.attribute12),
          DECODE(l_sl_header_rec.attribute13, FND_API.G_MISS_CHAR, attribute13, l_sl_header_rec.attribute13),
          DECODE(l_sl_header_rec.attribute14, FND_API.G_MISS_CHAR, attribute14, l_sl_header_rec.attribute14),
          DECODE(l_sl_header_rec.attribute15, FND_API.G_MISS_CHAR, attribute15, l_sl_header_rec.attribute15)
   INTO l_sl_header_rec.attribute_category,
        l_sl_header_rec.attribute1,
        l_sl_header_rec.attribute2,
        l_sl_header_rec.attribute3,
        l_sl_header_rec.attribute4,
        l_sl_header_rec.attribute5,
        l_sl_header_rec.attribute6,
        l_sl_header_rec.attribute7,
        l_sl_header_rec.attribute8,
        l_sl_header_rec.attribute9,
        l_sl_header_rec.attribute10,
        l_sl_header_rec.attribute11,
        l_sl_header_rec.attribute12,
        l_sl_header_rec.attribute13,
        l_sl_header_rec.attribute14,
        l_sl_header_rec.attribute15
   FROM aso_quote_headers
   WHERE quote_header_id = p_quote_header_id;
   */
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('IBE_Shop_List_PVT pl1-' || p_quote_header_id);
   END IF;

   OPEN l_csr FOR SELECT AQL.quote_line_id               ,
                         AQL.inventory_item_id           ,
                         AQL.quantity                    ,
                         AQL.uom_code                    ,
                         AQL.organization_id             ,
                         AQL.item_type_code              ,
                         AQLD.config_header_id           ,
                         AQLD.config_revision_num        ,
                         AQLD.complete_configuration_flag,
                         AQLD.valid_configuration_flag   ,
                         AQL.attribute_category          ,
                         AQL.attribute1                  ,
                         AQL.attribute2                  ,
                         AQL.attribute3                  ,
                         AQL.attribute4                  ,
                         AQL.attribute5                  ,
                         AQL.attribute6                  ,
                         AQL.attribute7                  ,
                         AQL.attribute8                  ,
                         AQL.attribute9                  ,
                         AQL.attribute10                 ,
                         AQL.attribute11                 ,
                         AQL.attribute12                 ,
                         AQL.attribute13                 ,
                         AQL.attribute14                 ,
                         AQL.attribute15                 ,
                         AQL.pricing_line_type_indicator
               FROM aso_quote_lines        AQL,
                    aso_quote_line_details AQLD
               WHERE AQL.quote_header_id = p_quote_header_id
                 AND AQL.quote_line_id   = AQLD.quote_line_id(+)
               ORDER BY AQL.quote_line_id;


   LOOP
      FETCH l_csr INTO l_quote_line_id              ,
                       l_inventory_item_id          ,
                       l_quantity                   ,
                       l_uom_code                   ,
                       l_organization_id            ,
                       l_item_type_code             ,
                       l_config_header_id           ,
                       l_config_revision_num        ,
                       l_complete_configuration_flag,
                       l_valid_configuration_flag   ,
                       l_attribute_category         ,
                       l_attribute1                 ,
                       l_attribute2                 ,
                       l_attribute3                 ,
                       l_attribute4                 ,
                       l_attribute5                 ,
                       l_attribute6                 ,
                       l_attribute7                 ,
                       l_attribute8                 ,
                       l_attribute9                 ,
                       l_attribute10                ,
                       l_attribute11                ,
                       l_attribute12                ,
                       l_attribute13                ,
                       l_attribute14                ,
                       l_attribute15                ,
                       l_pricing_line_type_indicator;
      EXIT WHEN l_csr%NOTFOUND;


      -- added 12/24/03: PRG shop list
      if (l_pricing_line_type_indicator = 'F') then
        l_PRG_configHdrId_tbl.EXTEND;
        l_PRG_configHdrId_tbl(l_PRG_configHdrId_tbl.LAST) := l_config_header_id;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	  IBE_Util.Debug('IBE_Shop_List_PVT: FreeLine! l_PRG_configHdrId=' || l_config_header_id);
        end if;
      end if;

        -- check to see if the config child's parent is a PRG
      l_checkPRGChild := Find_Index(l_config_header_id, l_PRG_configHdrId_tbl);
      if (l_checkPRGChild <> 0) then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	      IBE_Util.Debug('IBE_Shop_List_PVT: l_config_header_id is that of the PRG MDL!');
        end if;
        l_PRGchildren_lineId_tbl.EXTEND;
        l_PRGchildren_lineId_tbl(l_PRGchildren_lineId_tbl.LAST) := l_quote_line_Id;
      end if;

      -- add 3/26/03: avoid saving SRV info and PRG lines
      if ((l_item_type_code <> 'SRV') and
         ((l_pricing_line_type_indicator is null) or (l_pricing_line_type_indicator <> 'F')) and
         ((l_config_header_id is null) or (l_checkPRGChild = 0)) ) then

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	      IBE_Util.Debug('IBE_Shop_List_PVT: !SRV and !PRG');
        end if;

        l_sl_line_tbl(i).inventory_item_id           := l_inventory_item_id;
        l_sl_line_tbl(i).quantity                    := l_quantity;
        l_sl_line_tbl(i).uom_code                    := l_uom_code;
        l_sl_line_tbl(i).organization_id             := l_organization_id;
        l_sl_line_tbl(i).item_type_code              := l_item_type_code;
        l_sl_line_tbl(i).config_header_id            := l_config_header_id;
        l_sl_line_tbl(i).config_revision_num         := l_config_revision_num;
        l_sl_line_tbl(i).complete_configuration_flag := l_complete_configuration_flag;
        l_sl_line_tbl(i).valid_configuration_flag    := l_valid_configuration_flag;
        l_sl_line_tbl(i).org_id                      := L_ORG_ID;

        --commented by makulkar
	/*
        l_sl_line_tbl(i).attribute_category          := l_attribute_category;
        l_sl_line_tbl(i).attribute1                  := l_attribute1;
        l_sl_line_tbl(i).attribute2                  := l_attribute2;
        l_sl_line_tbl(i).attribute3                  := l_attribute3;
        l_sl_line_tbl(i).attribute4                  := l_attribute4;
        l_sl_line_tbl(i).attribute5                  := l_attribute5;
        l_sl_line_tbl(i).attribute6                  := l_attribute6;
        l_sl_line_tbl(i).attribute7                  := l_attribute7;
        l_sl_line_tbl(i).attribute8                  := l_attribute8;
        l_sl_line_tbl(i).attribute9                  := l_attribute9;
        l_sl_line_tbl(i).attribute10                 := l_attribute10;
        l_sl_line_tbl(i).attribute11                 := l_attribute11;
        l_sl_line_tbl(i).attribute12                 := l_attribute12;
        l_sl_line_tbl(i).attribute13                 := l_attribute13;
        l_sl_line_tbl(i).attribute14                 := l_attribute14;
        l_sl_line_tbl(i).attribute15                 := l_attribute15;
        */
        l_quote_line_id_tbl.EXTEND;
        l_quote_line_index_tbl.EXTEND;
        l_quote_line_id_tbl(l_quote_line_id_tbl.LAST)       := l_quote_line_id;
        l_quote_line_index_tbl(l_quote_line_index_tbl.LAST) := i;

        i := i + 1;

      end if; --if ((l_item_type_code <> 'SRV') and (l_pricing_line_type_indicator <> 'F'))

   END LOOP;
   CLOSE l_csr;

   -- get the related lines
   OPEN l_csr_rel FOR SELECT ALR.quote_line_id,
                         ALR.related_quote_line_id,
                         ALR.relationship_type_code
                  FROM aso_line_relationships ALR,
                       aso_quote_lines        AQL
                  WHERE ALR.quote_line_id   = AQL.quote_line_id
                    AND AQL.quote_header_id = p_quote_header_id;

   LOOP
      FETCH l_csr_rel INTO l_quote_line_id        ,
                       l_related_quote_line_id,
                       l_relationship_type_code;
      EXIT WHEN l_csr_rel%NOTFOUND;

      l_checkPRGChild := Find_Index(l_quote_line_id, l_PRGchildren_lineId_tbl);
      -- 3/26/03: avoid saving SRV info
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	    IBE_Util.Debug('IBE_Shop_List_PVT: l_checkPRGChild='||l_checkPRGChild);
      end if;

      if ((l_relationship_type_code <> 'SERVICE') and (l_checkPRGChild = 0)) then

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	      IBE_Util.Debug('IBE_Shop_List_PVT: relationship -- !SRV and !PRG');
        end if;

        l_sl_line_rel_tbl(j).line_index
           := Find_Index(l_quote_line_id, l_quote_line_id_tbl, l_quote_line_index_tbl);
        l_sl_line_rel_tbl(j).related_line_index
           := Find_Index(l_related_quote_line_id, l_quote_line_id_tbl, l_quote_line_index_tbl);
        l_sl_line_rel_tbl(j).relationship_type_code := l_relationship_type_code;

        j := j + 1;

      end if;
   END LOOP;
   CLOSE l_csr_rel;

   --dbms_output.put_line('p_sl_header_rec.shp_list_id = ' || p_sl_header_rec.shp_list_id);
   --dbms_output.put_line('p_sl_header_rec.party_id = ' || p_sl_header_rec.party_id);
   --dbms_output.put_line('p_sl_header_rec.cust_account_id = ' || p_sl_header_rec.cust_account_id);
   --dbms_output.put_line('p_sl_header_rec.shopping_list_name = ' || p_sl_header_rec.shopping_list_name);
   --dbms_output.put_line('p_sl_header_rec.description = ' || p_sl_header_rec.description);
   --dbms_output.put_line('p_sl_header_rec.org_id = ' || p_sl_header_rec.org_id);

   --dbms_output.put_line('l_sl_line_tbl.count = ' || l_sl_line_tbl.count);
   /*
   for k IN 1..l_sl_line_tbl.count loop
      --dbms_output.put_line('l_sl_line_tbl(' || k || ').inventory_item_id = ' || l_sl_line_tbl(k).inventory_item_id);
      --dbms_output.put_line('l_sl_line_tbl(' || k || ').organization_id = ' || l_sl_line_tbl(k).organization_id);
      --dbms_output.put_line('l_sl_line_tbl(' || k || ').uom_code = ' || l_sl_line_tbl(k).uom_code);
      --dbms_output.put_line('l_sl_line_tbl(' || k || ').quantity = ' || l_sl_line_tbl(k).quantity);
      --dbms_output.put_line('l_sl_line_tbl(' || k || ').item_type_code = ' || l_sl_line_tbl(k).item_type_code);
      --dbms_output.put_line('l_sl_line_tbl(' || k || ').org_id = ' || l_sl_line_tbl(k).org_id);
   end loop;

   --dbms_output.put_line('l_sl_line_rel_tbl.count = ' || l_sl_line_rel_tbl.count);
   for l IN 1..l_sl_line_rel_tbl.count loop
      --dbms_output.put_line('l_sl_line_rel_tbl(' || l || ').line_index = ' || l_sl_line_rel_tbl(l).line_index);
      --dbms_output.put_line('l_sl_line_rel_tbl(' || l || ').related_line_index = ' || l_sl_line_rel_tbl(l).related_line_index);
      --dbms_output.put_line('l_sl_line_rel_tbl(' || l || ').relationship_type_code =' || l_sl_line_rel_tbl(l).relationship_type_code);
   end loop;
   */
   --dbms_output.put_line('Calling Save...');

   Update_Config_Item_Lines(
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count    ,
      x_msg_data      => x_msg_data     ,
      px_sl_line_tbl  => l_sl_line_tbl);

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   BEGIN

      IBE_Shop_List_PVT.Save(
         p_api_version         =>  p_api_version,
         p_init_msg_list       =>  p_init_msg_list,
         p_commit              =>  p_commit,
         x_return_status       =>  x_return_status,
         x_msg_count           =>  x_msg_count,
         x_msg_data            =>  x_msg_data,
         p_combine_same_item   =>  p_combine_same_item,
         p_sl_header_rec       =>  l_sl_header_rec,
         p_sl_line_tbl         =>  l_sl_line_tbl,
         p_sl_line_rel_tbl     =>  l_sl_line_rel_tbl,
         x_sl_header_id        =>  x_sl_header_id
      );

      --dbms_output.put_line('x_return_status = ' || x_return_status);
      --dbms_output.put_line('x_msg_count = ' || x_msg_count);
      --dbms_output.put_line('x_msg_data = ' || x_msg_data);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FND_MESSAGE.set_name('IBE', 'IBE_SL_UPDATE_TO_LIST_ERROR');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
   END;

   --dbms_output.put_line('After Save...');

   -- End of API body.
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Save_List_From_Quote(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Save_List_From_Quote_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Save_List_From_Quote_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO Save_List_From_Quote_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END Save_List_From_Quote;

PROCEDURE Set_Qte_Lines_From_List_Lines(
   p_list_line_id_tbl     IN  jtf_number_table                   ,
   p_quote_header_id      IN  NUMBER                             ,
   p_price_list_id        IN  NUMBER                             ,
   p_currency_code        IN  VARCHAR2                           ,
   p_combine_same_item    IN  VARCHAR2 := FND_API.G_MISS_CHAR    ,
   p_minisite_id          IN  NUMBER   := FND_API.G_MISS_CHAR    ,
   x_qte_line_tbl         OUT NOCOPY ASO_Quote_Pub.Qte_Line_Tbl_Type    ,
   x_qte_line_detail_tbl  OUT NOCOPY ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type,
   x_list_line_id_map_tbl OUT NOCOPY jtf_number_table                   ,
   x_qte_line_index_tbl   OUT NOCOPY jtf_number_table                   ,
   x_ql_line_codes        OUT NOCOPY jtf_number_table                   ,
   x_contMDL              OUT NOCOPY VARCHAR2
)
IS
   TYPE Csr_Type IS REF CURSOR;
   l_csr                         Csr_Type;
   l_shp_list_item_id            NUMBER;
   l_inventory_item_id           NUMBER;
   l_organization_id             NUMBER;
   l_uom_code                    VARCHAR2(3);
   l_quantity                    NUMBER;
   l_item_type_code              VARCHAR2(30);
   l_config_header_id            NUMBER;
   l_config_revision_num         NUMBER;
   l_complete_configuration_flag VARCHAR2(3);
   l_valid_configuration_flag    VARCHAR2(3);
   l_relationship_type_code      VARCHAR2(30);
   l_attribute_category          VARCHAR2(30);
   l_attribute1                  VARCHAR2(150);
   l_attribute2                  VARCHAR2(150);
   l_attribute3                  VARCHAR2(150);
   l_attribute4                  VARCHAR2(150);
   l_attribute5                  VARCHAR2(150);
   l_attribute6                  VARCHAR2(150);
   l_attribute7                  VARCHAR2(150);
   l_attribute8                  VARCHAR2(150);
   l_attribute9                  VARCHAR2(150);
   l_attribute10                 VARCHAR2(150);
   l_attribute11                 VARCHAR2(150);
   l_attribute12                 VARCHAR2(150);
   l_attribute13                 VARCHAR2(150);
   l_attribute14                 VARCHAR2(150);
   l_attribute15                 VARCHAR2(150);

   l_quote_line_id               NUMBER;
   l_list_line_id_tbl            jtf_number_table := jtf_number_table();
   i                             PLS_INTEGER      := 1; -- index for x_qte_line_tbl
   j                             PLS_INTEGER      := 1; -- index for x_qte_line_detail_tbl
   l_qte_line_tbl_index          PLS_INTEGER;
   l_line_id                     NUMBER;
   l_component_code              VARCHAR2(1000);

BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Set_Qte_Lines_From_List_Lines(+)...');
   END IF;
   x_list_line_id_map_tbl := jtf_number_table();
   x_qte_line_index_tbl   := jtf_number_table();

   -- add 3/26/03: to be used for ibe_quote_save_pvt.save api
   x_ql_line_codes        := jtf_number_table();

   -- added on 5/30/03: SBM -- for checking to see if the cart has a MDL item
   x_contMDL              := 'N';
   FOR k IN 1..p_list_line_id_tbl.COUNT LOOP
      SELECT shp_list_item_id,
             inventory_item_id,
             quantity,
             uom_code,
             organization_id,
             config_header_id,
             config_revision_num,
             complete_configuration_flag,
             valid_configuration_flag,
             item_type_code,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15
      INTO l_shp_list_item_id,
           l_inventory_item_id,
           l_quantity,
           l_uom_code,
           l_organization_id,
           l_config_header_id,
           l_config_revision_num,
           l_complete_configuration_flag,
           l_valid_configuration_flag,
           l_item_type_code,
           l_attribute_category,
           l_attribute1,
           l_attribute2,
           l_attribute3,
           l_attribute4,
           l_attribute5,
           l_attribute6,
           l_attribute7,
           l_attribute8,
           l_attribute9,
           l_attribute10,
           l_attribute11,
           l_attribute12,
           l_attribute13,
           l_attribute14,
           l_attribute15
      FROM ibe_sh_shp_list_items
      WHERE shp_list_item_id = p_list_line_id_tbl(k);

    -- added 3/26/03: avoid saving SRV info
    if (l_item_type_code <> 'SRV') then

      IF p_combine_same_item = 'Y' AND l_item_type_code = 'STD' THEN
         l_qte_line_tbl_index := Find_Same_Item_In_qte_Line_Tbl(
                                    p_qte_line_tbl      => x_qte_line_tbl     ,
                                    p_inventory_item_id => l_inventory_item_id,
                                    p_uom_code          => l_uom_code);

         /*
          * if l_qte_line_tbl_index <> 0, there is already a line in x_qte_line_tbl
          * for same standard item.  Don't add a new line and just update the quantity.
          */
         IF l_qte_line_tbl_index <> 0 THEN
            x_qte_line_tbl(l_qte_line_tbl_index).quantity
               := x_qte_line_tbl(l_qte_line_tbl_index).quantity + l_quantity;
         ELSE
            x_qte_line_tbl(i).quote_header_id    := p_quote_header_id;
            x_qte_line_tbl(i).inventory_item_id  := l_inventory_item_id;
            x_qte_line_tbl(i).organization_id    := l_organization_id;
            x_qte_line_tbl(i).uom_code           := l_uom_code;
            x_qte_line_tbl(i).item_type_code     := l_item_type_code;
            x_qte_line_tbl(i).quantity           := l_quantity;
            x_qte_line_tbl(i).minisite_id        := p_minisite_id;

            /*
             * find same item IN aso_quote_lines view where item_type_code is 'STD',
             * and inventory_item_id, organization_id, and uom_code matches with this line
             */
            BEGIN
               SELECT quote_line_id,
                      quantity
               INTO l_quote_line_id,
                    l_quantity
               FROM aso_quote_lines
               WHERE quote_header_id   = p_quote_header_id
                 AND organization_id   = l_organization_id
                 AND item_type_code    = 'STD'
                 AND inventory_item_id = l_inventory_item_id
                 AND uom_code          = l_uom_code
                 AND currency_code     = p_currency_code;

               x_qte_line_tbl(i).operation_code := 'UPDATE';
               x_qte_line_tbl(i).quote_line_id  := l_quote_line_id;
               x_qte_line_tbl(i).quantity := x_qte_line_tbl(i).quantity + l_quantity;
            EXCEPTION
               /*
                * We get to NO_DATA_FOUND block when there is no line in
                * x_qte_line_tbl nor in aso_quote_lines table for the same item.
                */
               WHEN NO_DATA_FOUND THEN
                  x_qte_line_tbl(i).operation_code     := 'CREATE';
			   --commented by makulkar
			   /*
                  x_qte_line_tbl(i).attribute_category := l_attribute_category;
                  x_qte_line_tbl(i).attribute1         := l_attribute1;
                  x_qte_line_tbl(i).attribute2         := l_attribute2;
                  x_qte_line_tbl(i).attribute3         := l_attribute3;
                  x_qte_line_tbl(i).attribute4         := l_attribute4;
                  x_qte_line_tbl(i).attribute5         := l_attribute5;
                  x_qte_line_tbl(i).attribute6         := l_attribute6;
                  x_qte_line_tbl(i).attribute7         := l_attribute7;
                  x_qte_line_tbl(i).attribute8         := l_attribute8;
                  x_qte_line_tbl(i).attribute9         := l_attribute9;
                  x_qte_line_tbl(i).attribute10        := l_attribute10;
                  x_qte_line_tbl(i).attribute11        := l_attribute11;
                  x_qte_line_tbl(i).attribute12        := l_attribute12;
                  x_qte_line_tbl(i).attribute13        := l_attribute13;
                  x_qte_line_tbl(i).attribute14        := l_attribute14;
                  x_qte_line_tbl(i).attribute15        := l_attribute15;
			   */
            END;

            x_list_line_id_map_tbl.EXTEND;
            x_qte_line_index_tbl.EXTEND;
            x_list_line_id_map_tbl(x_list_line_id_map_tbl.LAST)
               := p_list_line_id_tbl(k);
            x_qte_line_index_tbl(x_qte_line_index_tbl.LAST) := i;

            i := i + 1;
         END IF;
      /*
       * p_combine_same_item = 'N' OR l_item_type_code <> 'STD',
       * which means that we are safe to add a new line
       */
      ELSE
         -- added on 5/21/03: SBM -- don't populate Configuration Children lines
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Else not STD and combine items');
         END IF;

         if ((l_config_header_id is null) or (l_item_type_code = 'MDL') ) then

           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('if non-config or MDL: j='||j);
           END IF;

           x_qte_line_tbl(i).operation_code     := 'CREATE';
           x_qte_line_tbl(i).quote_header_id    := p_quote_header_id;
           x_qte_line_tbl(i).inventory_item_id  := l_inventory_item_id;
           x_qte_line_tbl(i).organization_id    := l_organization_id;
           x_qte_line_tbl(i).uom_code           := l_uom_code;
           x_qte_line_tbl(i).item_type_code     := l_item_type_code;
           x_qte_line_tbl(i).quantity           := l_quantity;
           x_qte_line_tbl(i).minisite_id        := p_minisite_id;

           --commented by makulkar
	   /*
           x_qte_line_tbl(i).attribute_category := l_attribute_category;
           x_qte_line_tbl(i).attribute1         := l_attribute1;
           x_qte_line_tbl(i).attribute2         := l_attribute2;
           x_qte_line_tbl(i).attribute3         := l_attribute3;
           x_qte_line_tbl(i).attribute4         := l_attribute4;
           x_qte_line_tbl(i).attribute5         := l_attribute5;
           x_qte_line_tbl(i).attribute6         := l_attribute6;
           x_qte_line_tbl(i).attribute7         := l_attribute7;
           x_qte_line_tbl(i).attribute8         := l_attribute8;
           x_qte_line_tbl(i).attribute9         := l_attribute9;
           x_qte_line_tbl(i).attribute10        := l_attribute10;
           x_qte_line_tbl(i).attribute11        := l_attribute11;
           x_qte_line_tbl(i).attribute12        := l_attribute12;
           x_qte_line_tbl(i).attribute13        := l_attribute13;
           x_qte_line_tbl(i).attribute14        := l_attribute14;
           x_qte_line_tbl(i).attribute15        := l_attribute15;
           */
           IF l_config_header_id IS NOT NULL THEN
              IF l_item_type_code = 'MDL' THEN
                 --x_qte_line_tbl(i).currency_code := p_currency_code;-- Bug fix 3378817
                 x_contMDL                       := 'Y';
              END IF;

              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_Util.Debug('for configuration items ,: j='||j ||'and i='||i);
              END IF;
              --x_qte_line_tbl(i).price_list_id              := p_price_list_id;-- Bug fix 3378817

              x_qte_line_detail_tbl(j).qte_line_index      := i;
              x_qte_line_detail_tbl(j).config_header_id    := l_config_header_id;
              x_qte_line_detail_tbl(j).config_revision_num := l_config_revision_num;
              x_qte_line_detail_tbl(j).complete_configuration_flag
                 := l_complete_configuration_flag;
              x_qte_line_detail_tbl(j).valid_configuration_flag
                 := l_valid_configuration_flag;
              x_qte_line_detail_tbl(j).operation_code      := 'CREATE';

              l_component_code := TO_CHAR(x_qte_line_tbl(i).inventory_item_id);

              /* commented out on 5/21/03: SBM -- we won't be needing component code info
              OPEN l_csr FOR 'SELECT shp_list_item_id '||
                             'FROM ibe_sh_shlitem_rels ' ||
                             'START WITH related_shp_list_item_id = :1 '||
                             'CONNECT BY related_shp_list_item_id = PRIOR shp_list_item_id'
                         USING p_list_line_id_tbl(k);
              LOOP
                 FETCH l_csr INTO l_line_id;
                 EXIT WHEN l_csr%NOTFOUND;
                 l_component_code := TO_CHAR(x_qte_line_tbl(Find_Index(l_line_id, x_list_line_id_map_tbl, x_qte_line_index_tbl)).inventory_item_id)
                                     || '-' || l_component_code;
              END LOOP;

              CLOSE l_csr;

              x_qte_line_detail_tbl(j).component_code      := l_component_code;
              */

              j := j + 1;
           END IF;

           x_list_line_id_map_tbl.EXTEND;
           x_qte_line_index_tbl.EXTEND;
           x_list_line_id_map_tbl(x_list_line_id_map_tbl.LAST)
              := p_list_line_id_tbl(k);
           x_qte_line_index_tbl(x_qte_line_index_tbl.LAST) := i;

           i := i + 1;

         END IF; -- if <non-Config Items> or <MDL Items>
      END IF;

      -- add 3/26/03: to be used for ibe_quote_save_pvt.save api
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('l_item_type_code='||l_item_type_code);
      END IF;
      x_ql_line_codes.extend;
      if (l_item_type_code = 'SVA') then
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('l_item_type_code=SVA!');
         END IF;
         x_ql_line_codes(x_ql_line_codes.LAST) := IBE_QUOTE_SAVE_PVT.SERVICEABLE_LINE_CODE;

      elsif (l_item_type_code = 'STD') then
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('l_item_type_code=STD!');
         END IF;
         x_ql_line_codes(x_ql_line_codes.LAST) := IBE_QUOTE_SAVE_PVT.STANDARD_LINE_CODE;
      end if;

   END IF; -- if (l_item_type_code <> 'SRV') then
   END LOOP;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Set_Qte_Lines_From_List_Lines: x_contMDL='||x_contMDL);
   END IF;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Set_Qte_Lines_From_List_Lines(-)...');
   END IF;
END Set_Qte_Lines_From_List_Lines;


PROCEDURE Save_Quote_From_List_Items(
   p_api_version               IN  NUMBER   := 1                    ,
   p_init_msg_list             IN  VARCHAR2 := FND_API.G_TRUE       ,
   p_commit                    IN  VARCHAR2 := FND_API.G_FALSE      ,
   x_return_status             OUT NOCOPY VARCHAR2                  ,
   x_msg_count                 OUT NOCOPY NUMBER                    ,
   x_msg_data                  OUT NOCOPY VARCHAR2                  ,
   p_sl_line_ids               IN  jtf_number_table                 ,
   p_sl_line_ovns              IN  jtf_number_table := NULL         ,
   p_quote_retrieval_number    IN  NUMBER   := FND_API.G_MISS_NUM   ,
   p_recipient_party_id        IN  NUMBER   := FND_API.G_MISS_NUM   ,
   p_recipient_cust_account_id IN  NUMBER   := FND_API.G_MISS_NUM   ,
   p_minisite_id               IN  NUMBER   := FND_API.G_MISS_NUM   ,
   p_mode                      IN  VARCHAR2 := 'MERGE'              ,
   p_combine_same_item         IN  VARCHAR2 := FND_API.G_MISS_CHAR  ,
   p_control_rec               IN  ASO_Quote_Pub.control_rec_type   ,
   p_q_header_rec              IN  ASO_Quote_Pub.qte_header_rec_type,
   p_password                  IN  VARCHAR2 := FND_API.G_MISS_CHAR  ,
   p_email_address             IN  jtf_varchar2_table_2000 := NULL  ,
   p_privilege_type            IN  jtf_varchar2_table_100  := NULL  ,
   p_url                       IN  VARCHAR2                         ,
   p_comments                  IN  VARCHAR2                         ,
   p_promocode                 IN  VARCHAR2 := FND_API.G_MISS_CHAR  ,
   x_q_header_id               OUT NOCOPY NUMBER
)
IS
   L_API_NAME    CONSTANT   VARCHAR2(30) := 'Save_Quote_From_List_Items';
   L_API_VERSION CONSTANT   NUMBER       := 1.0;
   L_USER_ID     CONSTANT   NUMBER       := FND_GLOBAL.User_ID;

   l_list_line_id_tbl       jtf_number_table;
   l_list_line_id_map_tbl   jtf_number_table;
   l_qte_line_index_tbl     jtf_number_table;
   l_qte_line_tbl           ASO_Quote_Pub.Qte_Line_Tbl_Type;
   l_qte_line_detail_tbl    ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type;
   l_qte_line_relation_tbl  ASO_Quote_Pub.Line_Rltship_Tbl_Type;
   l_list_line_relation_tbl IBE_Shop_List_PVT.SL_Line_Rel_Tbl_Type;
   lx_quote_header_id       NUMBER;
   lx_last_update_date      DATE;

   -- add 3/26/03: to be used for ibe_quote_save_pvt.save api
   l_ql_line_codes          jtf_number_table;
   lx_Qte_Line_Tbl          ASO_Quote_Pub.Qte_Line_Tbl_Type;

   -- added on 5/21/03: SBM --
   l_qte_line_detail_indx   number;
   l_qte_line_id            number;
   l_control_rec            ASO_Quote_Pub.control_rec_type;
   lx_contMDL               varchar2(1);

   --Maithili- added for Offer code integration.
   l_Hd_Price_Attributes_Tbl   ASO_Quote_Pub.Price_Attributes_Tbl_Type;

   Cursor c_get_promo_details(p_promocode VARCHAR2, p_currency_code VARCHAR2) is
     SELECT list_header_id
     FROM qp_list_headers_vl
     WHERE NVL(start_date_active, SYSDATE) <= SYSDATE
     AND NVL(end_date_active+1, SYSDATE) >= SYSDATE
     AND list_type_code = 'PRO'
     AND active_flag = 'Y'
     AND automatic_flag = 'Y'
     AND ask_for_flag = 'Y'
     AND currency_code = p_currency_code
     AND name = p_promocode;

    l_pricing_attribute1  varchar2(240);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Save_Quote_From_List_Items_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Save_Quote_From_List_Items(+)');
   END IF;
   --dbms_output.put_line('IBE_Shop_List_PVT.Save_Quote_From_List_Items(+)');
   -- API body

   -- IF p_q_header_rec.quote_header_id is not null, i.e. mode will be either 'ADDTO' or 'REPLACE'.
   -- IN this case we just take leave header information as it is, but IF p_q_header_rec.quote_header_id
   -- is null, we create new line for quote header.

   IF (p_q_header_rec.quote_header_id <> FND_API.G_MISS_NUM) THEN
      IF (p_mode = 'REPLACE') THEN
         --dbms_output.put_line('calling IBE_Shop_List_PVT.DeleteAllLines()..');
         IBE_Quote_Save_pvt.DeleteAllLines(
            p_api_version_number => p_api_version,
            p_init_msg_list      => FND_API.G_TRUE,
            p_commit             => FND_API.G_FALSE,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_quote_header_id    => p_q_header_rec.quote_header_id,
            p_last_update_date   => p_q_header_rec.last_update_date,
	    p_sharee_number      => p_quote_retrieval_number,
            x_quote_header_id    => lx_quote_header_id,
            x_last_update_date   => lx_last_update_date);

         --dbms_output.put_line('back from IBE_Shop_List_PVT.DeleteAllLines()..');
         --dbms_output.put_line('x_return_status = ' || x_return_status);
         --dbms_output.put_line('x_msg_count = ' || x_msg_count);
         --dbms_output.put_line('x_msg_data = ' || x_msg_data);
/*
         FOR I IN 1..x_msg_count LOOP
            --dbms_OUTPUT.Put_Line(FND_MSG_PUB.Get(p_encoded => FND_API.g_false));
         END LOOP;
*/
         IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
   END IF;

   --dbms_output.put_line('p_q_header_rec.quote_header_id = ' || p_q_header_rec.quote_header_id);
   --dbms_output.put_line('p_q_header_rec.total_list_price = ' || p_q_header_rec.total_list_price);
   --dbms_output.put_line('p_q_header_rec.quote_source_code = ' || p_q_header_rec.quote_source_code);
   --dbms_output.put_line('p_q_header_rec.currency_code = ' || p_q_header_rec.currency_code);
   --dbms_output.put_line('p_q_header_rec.party_id = ' || p_q_header_rec.party_id);
   --dbms_output.put_line('p_q_header_rec.cust_account_id = ' || p_q_header_rec.cust_account_id);
   --dbms_output.put_line('p_q_header_rec.quote_name = ' || p_q_header_rec.quote_name);
   --dbms_output.put_line('p_q_header_rec.order_type_id = ' || p_q_header_rec.order_type_id);
   --dbms_output.put_line('p_q_header_rec.price_list_id = ' || p_q_header_rec.price_list_id);
   --dbms_output.put_line('p_q_header_rec.quote_category_code = ' || p_q_header_rec.quote_category_code);
   --dbms_output.put_line('calling Set_Qte_Lines_From_List_Lines()..');

   /*
    * Call Include_Related_Lines() to include all the related lines, i.e.,
    * all the children lines of configurable items.
    */

   /* commented out on 5/21/03: SBM
   Include_Related_Lines(
      p_qte_line_rel_tbl       => FND_API.G_TRUE    ,
      p_list_line_id_tbl       => p_sl_line_ids     ,
      x_list_line_id_tbl       => l_list_line_id_tbl,
      x_qte_line_relation_tbl  => l_qte_line_relation_tbl,
      x_list_line_relation_tbl => l_list_line_relation_tbl);
   */

   Set_Qte_Lines_From_List_Lines(
      p_list_line_id_tbl     => p_sl_line_ids            ,
      p_quote_header_id      => p_q_header_rec.quote_header_id,
      p_price_list_id        => p_q_header_rec.price_list_id  ,
      p_currency_code        => p_q_header_rec.currency_code  ,
      p_combine_same_item    => p_combine_same_item           ,
      p_minisite_id          => p_minisite_id                 ,
      x_qte_line_tbl         => l_qte_line_tbl                ,
      x_qte_line_detail_tbl  => l_qte_line_detail_tbl         ,
      x_list_line_id_map_tbl => l_list_line_id_map_tbl        ,
      x_qte_line_index_tbl   => l_qte_line_index_tbl          ,
      x_ql_line_codes        => l_ql_line_codes               ,
      x_contMDL              => lx_contMDL);

   if (l_ql_line_codes is not null) then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('back from Set_Qte_Lines_From_List_Lines -- l_ql_line_codes is not null!='||l_ql_line_codes(1));
         IBE_Util.Debug('back from Set_Qte_Lines_From_List_Lines -- lx_contMDL='||lx_contMDL);
      END IF;
   end if;

         --dbms_output.put_line('back from Set_Qte_Lines_From_List_Lines()..');
   --dbms_output.put_line('l_qte_line_tbl.count = ' || l_qte_line_tbl.count);
/*
   for i IN 1..l_qte_line_tbl.count loop

      --dbms_output.put_line('l_qte_line_tbl(' || i || ').inventory_item_id = ' || l_qte_line_tbl(i).inventory_item_id);
      --dbms_output.put_line('l_qte_line_tbl(' || i || ').uom_code = ' || l_qte_line_tbl(i).uom_code);
      --dbms_output.put_line('l_qte_line_tbl(' || i || ').quantity = ' || l_qte_line_tbl(i).quantity);
      --dbms_output.put_line('l_qte_line_tbl(' || i || ').organization_id = ' || l_qte_line_tbl(i).organization_id);
      --dbms_output.put_line('l_qte_line_tbl(' || i || ').item_type_code = ' || l_qte_line_tbl(i).item_type_code);
      --dbms_output.put_line('l_qte_line_tbl(' || i || ').currency_code = ' || l_qte_line_tbl(i).currency_code);

   end loop;
*/
   --dbms_output.put_line('l_qte_line_relation_tbl.count = ' || l_qte_line_relation_tbl.count);

   --dbms_output.put_line('Calling IBE_Quote_Save_pvt.Save()...');

   IBE_Quote_Misc_pvt.Update_Config_Item_Lines(
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count    ,
      x_msg_data          => x_msg_data     ,
      px_qte_line_dtl_tbl => l_qte_line_detail_tbl);

   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- added on 5/21/03: SBM
   --   if the lx_contMDL = Y, then there must be at least a MDL in the shop list
   --     1) make the first transaction call (Save) not do a pricing call
   l_control_rec         := p_control_rec;
   if (lx_contMDL = 'Y') then
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Coming back from update_config_item_lines: lx_contMDL is Y');
     END IF;
     l_control_rec         := aso_quote_pub.G_MISS_Control_Rec;
   end if;

   --Maithili
   IF (p_promocode is not null and p_promocode <> FND_API.G_MISS_CHAR) THEN
     -- set header pricing attribute record with promo code and other stuff.
     OPEN c_get_promo_details(p_promocode,p_q_header_rec.currency_code);
     FETCH c_get_promo_details INTO l_pricing_attribute1;
     CLOSE c_get_promo_details;

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('promocode = '||p_promocode||',currency code = '||p_q_header_rec.currency_code||'and pricing attribute1='||l_pricing_attribute1);
     END IF;

     IF l_pricing_attribute1 is not null THEN
       l_Hd_Price_Attributes_Tbl(1).pricing_attribute1   := l_pricing_attribute1;
       l_Hd_Price_Attributes_Tbl(1).flex_title           := 'QP_ATTR_DEFNS_QUALIFIER';
       l_Hd_Price_Attributes_Tbl(1).pricing_context      := 'MODLIST';
       l_Hd_Price_Attributes_Tbl(1).quote_header_id      := p_q_header_rec.quote_header_id;
       l_Hd_Price_Attributes_Tbl(1).operation_code       := 'CREATE';
     END IF;

   END IF; --p_promocode not null

   IBE_Quote_Save_pvt.AddItemsToCart(
      p_api_version_number     => p_api_version,
      p_init_msg_list          => FND_API.G_TRUE,
      p_commit                 => FND_API.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_combineSameItem        => p_combine_same_item,
      p_sharee_Number          => p_quote_retrieval_number,
      p_sharee_party_id        => p_recipient_party_id,
      p_sharee_cust_account_id => p_recipient_cust_account_id,
      p_minisite_id            => p_minisite_id,
      p_Control_Rec            => l_control_rec,
      p_Qte_Header_Rec         => p_q_header_rec,
      p_hd_Price_Attributes_Tbl=> l_Hd_Price_Attributes_Tbl,
      p_Qte_Line_Tbl           => l_qte_line_tbl,
      --p_Qte_Line_Dtl_Tbl       => l_qte_line_detail_tbl,
      --p_line_rltship_tbl       => l_qte_line_relation_tbl,
      p_ql_line_codes          => l_ql_line_codes,
      x_quote_header_id        => lx_quote_header_id,
      x_last_update_date       => lx_last_update_date,
      x_Qte_Line_Tbl           => lx_Qte_Line_Tbl);

   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

      --dbms_output.put_line('After Save() .. lx_quote_header_id = ' || lx_quote_header_id);

   -- added on 5/21/03: SBM --
   --   if lx_contMDL = Y, then there must be at least a MDL in the shop list
   --     1) get line det record from 1st index of line det Tbl
   if (lx_contMDL = 'Y') then
     for i in 1..l_qte_line_detail_tbl.count loop
        l_control_rec         := aso_quote_pub.G_MISS_Control_Rec;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Begin ASO_CFG_PUB.get_config_details');
        END IF;

        l_qte_line_detail_indx                 := l_qte_line_detail_tbl(i).qte_line_index;
        l_qte_line_detail_tbl(i).quote_line_id := lx_Qte_Line_Tbl(l_qte_line_detail_indx).quote_line_id;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('l_qte_line_detail_indx='||l_qte_line_detail_indx);
        END IF;

        -- make the Last transaction call do a pricing call
        if (i = l_qte_line_detail_tbl.count) then
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('This is the last item in the line details record -- making a pricing call');
          END IF;
          l_control_rec         := p_control_rec;
        end if;

        /*Call GET_CONFIG_DETAILS here*/
        if (lx_Qte_Line_Tbl(l_qte_line_detail_indx).item_type_code = 'MDL') then

          aso_cfg_pub.get_config_details(P_Api_Version_Number => p_api_version,
                                         P_Init_Msg_List      => p_init_msg_list,
                                         p_commit             => p_commit ,
                                         p_control_rec        => l_control_rec,
                                         p_config_rec         => l_qte_line_detail_tbl(i),
                                         p_model_line_rec     => lx_Qte_Line_Tbl(l_qte_line_detail_indx),
                                         p_config_hdr_id      => l_qte_line_detail_tbl(i).config_header_id ,
                                         p_config_rev_nbr     => l_qte_line_detail_tbl(i).config_revision_num,
                                         p_quote_header_id    => lx_quote_header_id ,

                                         x_return_status      => x_return_status,
                                         x_msg_count          => x_msg_count,
                                         x_msg_data           => x_msg_data
                                         );
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('End ASO_CFG_PUB.get_config_details');
          END IF;

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

        end if;

     end loop;
   end if; -- if contMDL = 'Y'

   IF (p_email_address IS NOT NULL) THEN
      --dbms_output.put_line('Calling IBE_QUOTE_SAVESHARE_pvt.ShareQuote()...');
      IBE_QUOTE_SAVESHARE_pvt.ShareQuote(
         p_api_version_number    => p_api_version,
         p_init_msg_list         => FND_API.G_FALSE,
         p_commit                => FND_API.G_FALSE,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_quote_header_id       => lx_quote_header_id,
         p_url                   => p_url,
         p_sharee_email_address  => p_email_address,
         p_sharee_privilege_type => p_privilege_type,
         p_comments              => p_comments);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   x_q_header_id := lx_quote_header_id;
   -- End of API body.
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Shop_List_PVT.Save_Quote_From_List_Items(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Save_Quote_From_List_Items_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Save_Quote_From_List_Items_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO Save_Quote_From_List_Items_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END Save_Quote_From_List_Items;

END IBE_Shop_List_PVT;

/
