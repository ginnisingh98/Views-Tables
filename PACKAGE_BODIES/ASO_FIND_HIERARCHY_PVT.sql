--------------------------------------------------------
--  DDL for Package Body ASO_FIND_HIERARCHY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_FIND_HIERARCHY_PVT" AS
/* $Header: asovqreb.pls 120.1 2005/06/29 12:44:01 appldev ship $ */

  G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASO_FIND_HIERARCHY_PVT';
  G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovqreb.pls';

  Function Is_Child(P_quote_line_id  NUMBER )
  RETURN BOOLEAN IS
  BEGIN
    If G_relation_tbl.FIRST IS NULL Then
       Return False;
    End IF;

    For i IN G_relation_tbl.FIRST .. G_relation_tbl.LAST Loop
      If G_relation_tbl(i).related_quote_line_id = p_quote_line_id Then
         Return TRUE;
      End If;
    End Loop;
    RETURN FALSE;
  END Is_Child;

  PROCEDURE Print_Quote(P_quote_line_id IN NUMBER := FND_API.G_MISS_NUM ,
                        p_parent_line_id IN NUMBER := FND_API.G_MISS_NUM ,
                        p_parent_qty     IN NUMBER := 0 ,
                        p_depth         IN NUMBER) IS
    l_index  BINARY_INTEGER ;
  BEGIN
    If G_hier_tbl.LAST IS NULL Then
       l_index := 1;
    Else
       l_index := G_hier_tbl.LAST + 1;
    End If;

    For i IN G_qte_lines_tbl.FIRST .. G_qte_lines_tbl.LAST Loop
      If ( G_qte_lines_tbl(i).quote_line_id = p_quote_line_id ) Then
        G_hier_tbl(l_index).depth := p_depth ;
        G_hier_tbl(l_index).line_num := G_qte_lines_tbl(i).line_num ;
        G_hier_tbl(l_index).parent_line_id := p_parent_line_id ;
        G_hier_tbl(l_index).quote_line_id := G_qte_lines_tbl(i).quote_line_id;
        G_hier_tbl(l_index).inventory_item_id :=
                            G_qte_lines_tbl(i).inventory_item_id ;
        G_hier_tbl(l_index).inventory_item :=
                            G_qte_lines_tbl(i).inventory_item ;
        G_hier_tbl(l_index).description := G_qte_lines_tbl(i).description ;
        G_hier_tbl(l_index).item_revision := G_qte_lines_tbl(i).item_revision ;
        G_hier_tbl(l_index).uom_code := G_qte_lines_tbl(i).uom_code;
        G_hier_tbl(l_index).quantity := G_qte_lines_tbl(i).quantity ;
        G_hier_tbl(l_index).amount := G_qte_lines_tbl(i).amount ;
        G_hier_tbl(l_index).adjusted_amount :=
                                    G_qte_lines_tbl(i).adjusted_amount ;
        G_hier_tbl(l_index).included_flag := 'Y';
        --set included flag in qte_lines as Y ,so that we do not include it
       -- again.
        G_qte_lines_tbl(i).included_flag := 'Y' ;

        If p_parent_line_id <> FND_API.G_MISS_NUM Then
          G_hier_tbl(l_index).qty_factor :=
               NVL(G_qte_lines_tbl(i).quantity,0) / p_parent_qty ;
        End If;

        If G_relation_tbl.FIRST IS NOT NULL Then
          For j IN G_relation_tbl.FIRST .. G_relation_tbl.LAST Loop
            If G_relation_tbl(j).quote_line_id = p_quote_line_id Then
               Print_quote(p_quote_line_id =>
                                 G_relation_tbl(j).related_quote_line_id ,
                           p_parent_line_id => p_quote_line_id ,
                           p_parent_qty     => G_qte_lines_tbl(i).quantity ,
                           p_depth         => p_depth + 1 );
            End If;
          End Loop;
         End If;
         RETURN;
       End If;
    End Loop;

  End Print_Quote;

  Procedure Populate_hier(p_quote_header_id   IN    NUMBER ,
                          x_hier_tbl  OUT NOCOPY /* file.sql.39 change */    hier_tbl_type ,
                          x_return_status  OUT NOCOPY /* file.sql.39 change */    VARCHAR2  ,
                          x_msg_count      OUT NOCOPY /* file.sql.39 change */    NUMBER    ,
                          x_msg_data       OUT NOCOPY /* file.sql.39 change */    VARCHAR2 ) IS

    l_index     BINARY_INTEGER := 1;
    l_depth     NUMBER := 0;
    l_quote_line_id NUMBER ;
    l_api_name      CONSTANT VARCHAR2(2000) := 'Populate_Hier' ;
    l_api_version_number CONSTANT NUMBER := 1.0;
   -- l_api_name      CONSTANT VARCHAR2(30) := 'Populate_Hier' ;
   -- l_api_version_number CONSTANT NUMBER := '1.0';

-- Changes to uptake Install Base 11.5.6
/**    Cursor c_qte_lines IS
      Select 0  depth ,
              qte_lines.line_number  line_num ,
              qte_lines.quote_line_id quote_line_id ,
              items.concatenated_segments inventory_item ,
             -- items.segment1  inventory_item ,
              items.description description,
              qte_lines.uom_code uom_code ,
              qte_lines.quantity quantity ,
              (qte_lines.line_list_price * qte_lines.quantity)   amount ,
              (qte_lines.line_adjusted_amount  * qte_lines.quantity)  line_adjusted_amount
        From   ASO_QUOTE_LINES_ALL qte_lines ,
               ASO_I_ITEMS_V       items
        Where  qte_lines.quote_header_id   = p_quote_header_id
        AND    qte_lines.inventory_item_id = items.inventory_item_id
        AND    qte_lines.organization_id   = items.organization_id
        ORDER BY line_num ; **/

    Cursor c_qte_lines IS
      Select 0  depth ,
              qte_lines.line_number  line_num ,
              qte_lines.quote_line_id quote_line_id ,
              items.inventory_item_id inventory_item_id ,
              items.organization_id organization_id ,
              items.concatenated_segments inventory_item ,
             -- items.segment1  inventory_item ,
              msit.description description,
              qte_lines.uom_code uom_code ,
              qte_lines.quantity quantity ,
              (qte_lines.line_list_price * qte_lines.quantity)   amount ,
              (qte_lines.line_adjusted_amount  * qte_lines.quantity)  line_adjusted_amount
        From   ASO_QUOTE_LINES_ALL qte_lines ,
			MTL_SYSTEM_ITEMS_B_KFV items,
			MTL_SYSTEM_ITEMS_TL msit
        Where  qte_lines.quote_header_id   = p_quote_header_id
        AND    qte_lines.inventory_item_id = items.inventory_item_id
        AND    qte_lines.organization_id   = items.organization_id
        AND    items.inventory_item_id = msit.inventory_item_id
        AND    items.organization_id = msit.organization_id
	   AND    msit.language = userenv('LANG')
        ORDER BY line_num;

    Cursor c_item_revision(p_inventory_item_id Number,
                           p_organization_id Number) Is
    Select MAX(Revision)
    From   mtl_item_revisions
    Where  inventory_item_id = p_inventory_item_id
    and    organization_id = p_organization_id
    and    trunc(sysdate) >= trunc(effectivity_date);

    l_max_revision varchar2(3);

    Cursor c_relationship Is
    (SELECT  rel.quote_line_id ,
             rel.related_quote_line_id
     FROM    ASO_LINE_RELATIONSHIPS rel,
             ASO_QUOTE_LINES_ALL qte_line
     WHERE   qte_line.quote_header_id = p_quote_header_id
     AND     qte_line.quote_line_id = rel.quote_line_id );

  BEGIN

   SAVEPOINT POPULATE_HIER_PVT ;

   aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    --reset the table variables to g_miss
    G_qte_lines_tbl := G_Miss_tbl ;
    G_hier_tbl      := G_Miss_tbl ;
    G_relation_tbl  := G_Miss_reln_tbl ;

    FOR i_rec IN c_qte_lines LOOP
      G_qte_lines_tbl(l_index).depth := i_rec.depth;
      G_qte_lines_tbl(l_index).line_num := i_rec.line_num ;
      G_qte_lines_tbl(l_index).quote_line_id := i_rec.quote_line_id ;
      G_qte_lines_tbl(l_index).inventory_item_id := i_rec.inventory_item_id ;
      G_qte_lines_tbl(l_index).inventory_item := i_rec.inventory_item ;
      G_qte_lines_tbl(l_index).description := i_rec.description ;
    --  G_qte_lines_tbl(l_index).item_revision := i_rec.item_revision ;
      G_qte_lines_tbl(l_index).uom_code := i_rec.uom_code ;
      G_qte_lines_tbl(l_index).quantity := i_rec.quantity ;
      G_qte_lines_tbl(l_index).amount   := i_rec.amount ;
      G_qte_lines_tbl(l_index).adjusted_amount := i_rec.line_adjusted_amount ;
      l_index := l_index + 1;

	 Open c_item_revision(p_inventory_item_id => i_rec.inventory_item_id,
	                      p_organization_id => i_rec.organization_id);
	 Fetch c_item_revision into l_max_revision;
	 IF c_item_revision%FOUND Then
         G_qte_lines_tbl(l_index).item_revision := l_max_revision ;
      End If;
	 Close c_item_revision;

    End Loop;

    --reset l_index to 1
    l_index := 1;

    FOR i_rec IN c_relationship Loop
      G_relation_tbl(l_index).quote_line_id := i_rec.quote_line_id ;
      G_relation_tbl(l_index).related_quote_line_id :=
                                       i_rec.related_quote_line_id ;
      l_index := l_index + 1 ;
    End Loop;

    l_index := 1;
    l_depth := 0;

    If G_qte_lines_tbl.FIRST IS NULL Then
      Return;
    end if;

    For i IN G_qte_lines_tbl.FIRST .. G_qte_lines_tbl.LAST Loop
      If G_qte_lines_tbl(i).included_flag = 'Y' Then
         NULL;
      Else
         If (Is_Child(G_qte_lines_tbl(i).quote_line_id)) Then
            Null;
         else
            l_quote_line_id := G_qte_lines_tbl(i).quote_line_id ;
            Print_Quote(p_quote_line_id =>l_quote_line_id,
                        p_depth         => l_depth );
         End If;
      End If;
    End Loop;

   x_hier_tbl := G_hier_tbl ;

  EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
             ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_SQLCODE  => SQLCODE
                  ,P_SQLERRM  => SQLERRM
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  End Populate_hier;
End ASO_FInd_Hierarchy_PVT ;

/
