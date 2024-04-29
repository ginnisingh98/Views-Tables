--------------------------------------------------------
--  DDL for Package Body ASO_BI_QOT_PC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_BI_QOT_PC_PVT" AS
/* $Header: asovbiqpcb.pls 120.2 2005/09/16 04:40:54 kedukull noship $*/

 -- Returns the various clauses and coloumns that are common to all conditions.

PROCEDURE getCommonClauses(p_sr_id_num      IN NUMBER
                          ,p_conv_rate      IN NUMBER
                          ,p_asof_date      IN DATE
                          ,p_priorasof_date IN DATE
                          ,p_fdcp_date      IN DATE
                          ,p_fdpp_date      IN DATE
                          ,x_main_clause0   OUT NOCOPY VARCHAR2
                          ,x_main_clause1   OUT NOCOPY VARCHAR2
                          ,x_main_clause2   OUT NOCOPY VARCHAR2
                          ,x_res_query      OUT NOCOPY VARCHAR2
                          ,x_time_clause0   OUT NOCOPY VARCHAR2
                          ,x_time_clause1   OUT NOCOPY VARCHAR2
                          ,x_summ           OUT NOCOPY VARCHAR2)
AS
       l_sec_prefix	VARCHAR2(100);
BEGIN

      -- 7.0 rup1 changes - secondary Currency uptake. --

       IF    p_conv_rate = 0
       THEN
             l_sec_prefix := 'sec_';
       ELSE
             l_sec_prefix := NULL;
       END IF;
       -- ITD Measures --
       x_main_clause0 :=',(CASE
		             WHEN report_date = :p_fdcp_date
                             THEN '|| l_sec_prefix||'openqot_amnt
                             ELSE NULL
                          END) ASO_VALUE1
		         ,(CASE
                             WHEN report_date = :p_fdcp_date
                             THEN openqot_number
                             ELSE NULL
                           END) ASO_VALUE2
                         ,(CASE
                             WHEN report_date = :p_fdpp_date
                             THEN '|| l_sec_prefix||'openqot_amnt
                             ELSE NULL
                           END) ASO_VALUE3
                         ,(CASE
                             WHEN report_date = :p_fdpp_date
                             THEN openqot_number
                             ELSE NULL
                          END) ASO_VALUE4,
                          NULL ASO_VALUE5,
                          NULL ASO_VALUE6,
                          NULL ASO_VALUE7,
                          NULL ASO_VALUE8 ';

         -- PTD Measures --
         x_main_clause1 :=',(CASE
		               WHEN report_date = :p_asof_date
                               THEN '||l_sec_prefix||'newqot_amnt
                               ELSE NULL
                             END) ASO_VALUE1
                           ,(CASE
                               WHEN report_date = :p_asof_date
                               THEN newqot_number
                               ELSE NULL
                            END) ASO_VALUE2
                          ,(CASE
                             WHEN report_date = :p_priorasof_date
                             THEN '||l_sec_prefix||'newqot_amnt
                             ELSE NULL
                            END) ASO_VALUE3
		          ,(CASE
                             WHEN report_date = :p_priorasof_date
                             THEN newqot_number
                             ELSE NULL
                           END) ASO_VALUE4
                          ,(CASE
                              WHEN report_date = :p_asof_date
                              THEN  '||l_sec_prefix||'convqot_amnt
                              ELSE NULL
                           END) ASO_VALUE5
                          ,(CASE
                               WHEN report_date = :p_asof_date
                               THEN convqot_number
                               ELSE NULL
                           END) ASO_VALUE6
                          ,(CASE
                               WHEN report_date = :p_priorasof_date
                               THEN '|| l_sec_prefix||'convqot_amnt
                               ELSE NULL
                           END) ASO_VALUE7
                           ,(CASE
                               WHEN report_date = :p_priorasof_date
                               THEN convqot_number
                             ELSE NULL
                             END) ASO_VALUE8 ';

         -- Elimination of Duplicate Quotes for Total Quotes Calculation --
         x_main_clause2 := ',(CASE
                                WHEN (SUMRY.Time_id = :p_fdcp_date_j)
                                THEN SUMRY.'|| l_sec_prefix||'openqot_amnt * -1
                             END) ASO_VALUE1
                            ,(CASE
                                WHEN (SUMRY.Time_id = :p_fdcp_date_j)
                                THEN SUMRY.openqot_number * -1
                              END)  ASO_VALUE2
                            ,(CASE
                                 WHEN (SUMRY.Time_id = :p_fdpp_date_j)
                                 THEN  SUMRY.'|| l_sec_prefix||'openqot_amnt * -1
                               END)  ASO_VALUE3
                            ,(CASE
                                WHEN (SUMRY.Time_id = :p_fdpp_date_j)
                                THEN  SUMRY.openqot_number * -1
                              END)  ASO_VALUE4
                             ,NULL  ASO_VALUE5
                             ,NULL  ASO_VALUE6
                             ,NULL  ASO_VALUE7
                             ,NULL  ASO_VALUE8 ';

         IF p_sr_id_num IS NULL THEN
            x_res_query :=  ' AND Resource_grp_id = :p_sg_id_num
                              AND Resource_grp_flag = ''Y'' ';
         ELSE
            x_res_query :=  ' AND Resource_grp_id = :p_sg_id_num
                              AND Resource_id = :p_sr_id_num
                              AND Resource_grp_flag = ''N'' ';
         END IF;

        x_time_clause0 :=  ' CAL.Calendar_id = -1
                             AND CAL.Period_type_id = Sumry.Period_type_id
                             AND CAL.Time_id = Sumry.Time_id
                             AND CAL.Report_Date IN (:p_fdcp_date,:p_fdpp_date)
                             AND BITAND(CAL.Record_Type_Id, 1143) = CAL.Record_Type_Id';

        x_time_clause1 :=  ' CAL.Calendar_id = -1
                             AND CAL.Period_type_id = Sumry.Period_type_id
                             AND CAL.Time_id = Sumry.Time_id
                             AND CAL.Report_Date IN (:p_asof_date,:p_priorasof_date)
                             AND BITAND(CAL.Record_Type_Id, :p_record_type_id) = CAL.Record_Type_Id';

         x_summ := ',SUM(ASO_VALUE1)  ASO_VALUE1
                    ,SUM(ASO_VALUE2) ASO_VALUE2
                    ,SUM(ASO_VALUE3) ASO_VALUE3
                    ,SUM(ASO_VALUE4) ASO_VALUE4
                    ,SUM(ASO_VALUE5) ASO_VALUE5
                    ,SUM(ASO_VALUE6) ASO_VALUE6
                    ,SUM(ASO_VALUE7) ASO_VALUE7
                    ,SUM(ASO_VALUE8) ASO_VALUE8 ';

END getCommonClauses;

PROCEDURE executeQuery(p_query          IN VARCHAR2
                      ,p_product_id     IN VARCHAR2
                      ,p_conv_rate      IN NUMBER
                      ,p_record_type_id IN NUMBER
                      ,p_sg_id_num      IN NUMBER
                      ,p_sr_id_num      IN NUMBER
                      ,p_fdcp_date_j    IN NUMBER
                      ,p_fdpp_date_j    IN NUMBER
                      ,p_asof_date      IN DATE
                      ,p_priorasof_date IN DATE
                      ,p_fdcp_date      IN DATE
                      ,p_fdpp_date      IN DATE)
AS

l_insert_stmt VARCHAR2(3000);

BEGIN

         l_insert_stmt := ' INSERT INTO ASO_BI_RPT_TMP1(ASO_ATTRIBUTE1,VIEWBY,ASO_VALUE1,ASO_VALUE2,ASO_VALUE3,ASO_VALUE4,ASO_VALUE5
                                                       ,ASO_VALUE6,ASO_VALUE7,ASO_VALUE8,ASO_URL1) ';

         IF p_product_id IS NULL THEN

             IF p_sr_id_num IS NULL THEN

                   EXECUTE IMMEDIATE l_insert_stmt || p_query
                   USING p_fdcp_date , p_fdcp_date , p_fdpp_date , p_fdpp_date
                        ,p_fdcp_date , p_fdpp_date

                        ,p_sg_id_num

                        ,p_asof_date , p_asof_date , p_priorasof_date , p_priorasof_date
                        ,p_asof_date ,p_asof_date , p_priorasof_date , p_priorasof_date

                        ,p_asof_date , p_priorasof_date , p_record_type_id

                        ,p_sg_id_num

                        ,p_fdcp_date_j , p_fdcp_date_j , p_fdpp_date_j ,p_fdpp_date_j

                        ,p_fdcp_date_j , p_fdpp_date_j

			,p_sg_id_num;

             ELSE

                   EXECUTE IMMEDIATE l_insert_stmt || p_query
                   USING p_fdcp_date , p_fdcp_date , p_fdpp_date , p_fdpp_date
                        ,p_fdcp_date , p_fdpp_date

                        ,p_sg_id_num , p_sr_id_num

                        ,p_asof_date , p_asof_date , p_priorasof_date , p_priorasof_date
                        ,p_asof_date ,p_asof_date , p_priorasof_date , p_priorasof_date

                        ,p_asof_date , p_priorasof_date , p_record_type_id

                        ,p_sg_id_num , p_sr_id_num

                        ,p_fdcp_date_j , p_fdcp_date_j , p_fdpp_date_j ,p_fdpp_date_j

                        ,p_fdcp_date_j , p_fdpp_date_j

	   	        ,p_sg_id_num , p_sr_id_num;
             END IF;

         ELSE
             IF p_sr_id_num IS NULL THEN

                   EXECUTE IMMEDIATE l_insert_stmt || p_query
                   USING p_fdcp_date , p_fdcp_date , p_fdpp_date , p_fdpp_date
                        ,p_fdcp_date , p_fdpp_date

                        ,p_sg_id_num

                        ,p_product_id

                        ,p_asof_date , p_asof_date , p_priorasof_date , p_priorasof_date
                        ,p_asof_date ,p_asof_date , p_priorasof_date , p_priorasof_date

                        ,p_asof_date , p_priorasof_date , p_record_type_id

                        ,p_sg_id_num

                        ,p_product_id

                        ,p_fdcp_date_j , p_fdcp_date_j , p_fdpp_date_j ,p_fdpp_date_j

                        ,p_fdcp_date_j , p_fdpp_date_j

                        ,p_product_id

		        ,p_sg_id_num ;
                ELSE

                   EXECUTE IMMEDIATE l_insert_stmt || p_query
                   USING p_fdcp_date , p_fdcp_date , p_fdpp_date , p_fdpp_date
                        ,p_fdcp_date , p_fdpp_date

                        ,p_sg_id_num , p_sr_id_num

                        ,p_product_id

                        ,p_asof_date , p_asof_date , p_priorasof_date , p_priorasof_date
                        ,p_asof_date ,p_asof_date , p_priorasof_date , p_priorasof_date

                        ,p_asof_date , p_priorasof_date , p_record_type_id

                       ,p_sg_id_num , p_sr_id_num

                       ,p_product_id

                       ,p_fdcp_date_j , p_fdcp_date_j , p_fdpp_date_j ,p_fdpp_date_j

                       ,p_fdcp_date_j , p_fdpp_date_j

                       ,p_product_id

		       ,p_sg_id_num , p_sr_id_num;

                END IF;
         END IF;

END executeQuery;

-- Product category : All, Product : All , View by : Product category

PROCEDURE PCAll(p_conv_rate      IN NUMBER
               ,p_record_type_id IN NUMBER
               ,p_sg_id_num      IN NUMBER
               ,p_sr_id_num      IN NUMBER
               ,p_asof_date      IN DATE
               ,p_priorasof_date IN DATE
               ,p_fdcp_date      IN DATE
               ,p_fdpp_date      IN DATE
               ,p_fdcp_date_j    IN NUMBER
               ,p_fdpp_date_j    IN NUMBER)

AS

l_summ          VARCHAR2(5000);
l_query         VARCHAR2(32000);
l_main_clause0  VARCHAR2(32000);
l_main_clause1  VARCHAR2(32000);
l_main_clause2  VARCHAR2(32000);
l_res_clause    VARCHAR2(3000);
l_time_clause0  VARCHAR2(3000);
l_time_clause1  VARCHAR2(3000);

BEGIN

         getCommonClauses(p_sr_id_num,p_conv_rate,p_asof_date,p_priorasof_date,p_fdcp_date,p_fdpp_date
                         ,l_main_clause0,l_main_clause1,l_main_clause2,l_res_clause,l_time_clause0,l_time_clause1,l_summ);

         l_query := ' SELECT PCD.ID
                            ,PCD.Value
                            ,ASO_VALUE1,ASO_VALUE2,ASO_VALUE3,ASO_VALUE4,ASO_VALUE5,ASO_VALUE6,ASO_VALUE7,ASO_VALUE8
                            ,DECODE(PCD.leaf_node_flag,''Y''
                                  ,''pFunctionName=ASO_BI_SUM_BY_PC_PHP&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM&VIEW_BY_NAME=VIEW_BY_ID''
                                  ,''pFunctionName=ASO_BI_SUM_BY_PC_PHP&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'')
                      FROM (
                          SELECT Inn0.Category_id '|| l_summ ||
                          ' FROM
                               (SELECT Sumry.Category_id '|| l_main_clause0 ||
                               'FROM  ASO_BI_QLIN_PC_MV Sumry
                                     ,FII_TIME_RPT_STRUCT_V CAL
                                WHERE '|| l_time_clause0 || l_res_clause ||
                                      'AND Sumry.Top_node_flag = ''Y''
                              AND Sumry.Category_flag = ''Y'' ';
        l_query := l_query ||
                      ' UNION ALL
                         (SELECT Sumry.Category_id '|| l_main_clause1 ||
                               'FROM  ASO_BI_QLIN_PC_MV Sumry
                                     ,FII_TIME_RPT_STRUCT_V CAL
                                WHERE '|| l_time_clause1 || l_res_clause ||
                                      'AND Sumry.Top_node_flag = ''Y''
                                      AND Sumry.Category_flag = ''Y'')';

          l_query := l_query ||
                     ' UNION ALL
                       SELECT Sumry.Category_id '|| l_main_clause2 ||
                      'FROM  ASO_BI_QLIN_PC_MV Sumry
                       WHERE Sumry.Time_id in (:p_fdcp_date_j,:p_fdpp_date_j)
                             AND Sumry.Period_Type_Id = 1
                             AND Sumry.Top_node_flag = ''Y''
                             AND Sumry.Category_flag = ''Y'' '|| l_res_clause;


         l_query := l_query ||') Inn0
                               GROUP BY Inn0.Category_id
                         )Inn1
                         ,ENI_ITEM_VBH_NODES_V PCD
                         WHERE PCD.Parent_id = Inn1.Category_id
                               AND Inn1.Category_id = PCD.Child_id
                               AND Inn1.Category_id = PCD.Id ';

          executeQuery(l_query
                     ,NULL
                     ,p_conv_rate
                     ,p_record_type_id
                     ,p_sg_id_num
                     ,p_sr_id_num
                     ,p_fdcp_date_j
                     ,p_fdpp_date_j
                     ,p_asof_date
                     ,p_priorasof_date
                     ,p_fdcp_date
                     ,p_fdpp_date);

END PCAll;

-- Product category : Selected, Product : All , View by : Product category

PROCEDURE PCSPrA(p_asof_date      IN DATE
                ,p_priorasof_date IN DATE
                ,p_fdcp_date      IN DATE
                ,p_fdpp_date      IN DATE
                ,p_conv_rate      IN NUMBER
                ,p_record_type_id IN NUMBER
                ,p_sg_id_num      IN NUMBER
                ,p_sr_id_num      IN NUMBER
                ,p_fdcp_date_j    IN NUMBER
                ,p_fdpp_date_j    IN NUMBER
                ,p_product_cat    IN NUMBER)
AS

l_summ          VARCHAR2(5000);
l_query         VARCHAR2(32000);
l_main_clause0  VARCHAR2(32000);
l_main_clause1  VARCHAR2(32000);
l_main_clause2  VARCHAR2(32000);
l_res_clause    VARCHAR2(3000);
l_time_clause0  VARCHAR2(3000);
l_time_clause1  VARCHAR2(3000);

BEGIN

         getCommonClauses(p_sr_id_num,p_conv_rate,p_asof_date,p_priorasof_date,p_fdcp_date,p_fdpp_date
                         ,l_main_clause0,l_main_clause1,l_main_clause2,l_res_clause,l_time_clause0,l_time_clause1,l_summ);

         INSERT INTO ASO_BI_RPT_TMP2(ASO_VALUE1)
         SELECT PCD.Imm_child_id
         FROM ENI_DENORM_HIERARCHIES PCD
             ,MTL_DEFAULT_CATEGORY_SETS MDFT
         WHERE PCD.Parent_id = p_product_cat
               AND PCD.Imm_child_id = PCD.Child_id
               AND (PCD.Leaf_node_flag = 'Y' OR (PCD.Leaf_node_flag = 'N' AND PCD.Parent_id<>PCD.Imm_child_id))
               AND MDFT.Functional_area_id = 11
               AND MDFT.Category_set_id = PCD.Object_id
               AND PCD.Object_type = 'CATEGORY_SET'
               AND PCD.Dbi_flag = 'Y';

         l_query := 'SELECT PCD.Id
                           ,PCD.Value
                           ,ASO_VALUE1,ASO_VALUE2,ASO_VALUE3,ASO_VALUE4,ASO_VALUE5,ASO_VALUE6,ASO_VALUE7,ASO_VALUE8
                           ,DECODE(PCD.Leaf_node_flag,''Y''
                                ,''pFunctionName=ASO_BI_SUM_BY_PC_PHP&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM&VIEW_BY_NAME=VIEW_BY_ID''
                                ,''pFunctionName=ASO_BI_SUM_BY_PC_PHP&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'')
                    FROM
                        (SELECT Inn0.Category_id '|| l_summ ||
                        ' FROM
                           (SELECT /*+ Ordered */ Sumry.Category_id '|| l_main_clause0 ||
                           ' FROM FII_TIME_RPT_STRUCT_V CAL
                                 ,ASO_BI_RPT_TMP2 TMP
                                 ,ASO_BI_QLIN_PC_MV SUMRY
                             WHERE '|| l_time_clause0 || l_res_clause ||
                                   'AND Sumry.Category_id = TMP.ASO_VALUE1
                                    AND Sumry.Category_flag = ''Y'' ';
         l_query := l_query ||
                      'UNION ALL
                          (SELECT /*+ Ordered */ Sumry.Category_id '|| l_main_clause1 ||
                           ' FROM FII_TIME_RPT_STRUCT_V CAL
                                 ,ASO_BI_RPT_TMP2 TMP
                                 ,ASO_BI_QLIN_PC_MV SUMRY
                             WHERE '|| l_time_clause1 || l_res_clause ||
                                   'AND Sumry.Category_id = TMP.ASO_VALUE1
                                    AND Sumry.Category_flag = ''Y'')';


          l_query := l_query ||
                      'UNION ALL
                       SELECT  /*+ Leading(TMP) */ Sumry.Category_id '|| l_main_clause2 ||
                     ' FROM ASO_BI_QLIN_PC_MV Sumry
                           ,ASO_BI_RPT_TMP2 TMP
                       WHERE Sumry.Time_id in (:p_fdcp_date_j,:p_fdpp_date_j)
                             AND Sumry.Period_Type_Id = 1
                             AND Sumry.Category_id = TMP.ASO_VALUE1
                             AND Sumry.Category_flag = ''Y'' '|| l_res_clause;

          l_query := l_query ||' ) Inn0
                                  GROUP BY Inn0.Category_id
                       )Inn1
                       ,ENI_ITEM_VBH_NODES_V PCD
                    WHERE Inn1.Category_id = PCD.Parent_id
                          AND Inn1.Category_id = PCD.Id
                          AND Inn1.Category_id = PCD.Child_id ';


         executeQuery(l_query
                     ,NULL
                     ,p_conv_rate
                     ,p_record_type_id
                     ,p_sg_id_num
                     ,p_sr_id_num
                     ,p_fdcp_date_j
                     ,p_fdpp_date_j
                     ,p_asof_date
                     ,p_priorasof_date
                     ,p_fdcp_date
                     ,p_fdpp_date);

END PCSPrA;

-- Product category : All, Product : Selected, View by : Product category

PROCEDURE PCAPrS(p_asof_date      IN DATE
                ,p_priorasof_date IN DATE
                ,p_fdcp_date      IN DATE
                ,p_fdpp_date      IN DATE
                ,p_conv_rate      IN NUMBER
                ,p_record_type_id IN NUMBER
                ,p_sg_id_num      IN NUMBER
                ,p_sr_id_num      IN NUMBER
                ,p_fdcp_date_j    IN NUMBER
                ,p_fdpp_date_j    IN NUMBER
                ,p_product_id     IN VARCHAR2)
AS

l_summ         VARCHAR2(5000);
l_query        VARCHAR2(32000);
l_main_clause0 VARCHAR2(32000);
l_main_clause1 VARCHAR2(32000);
l_main_clause2 VARCHAR2(32000);
l_res_clause   VARCHAR2(3000);
l_time_clause0  VARCHAR2(3000);
l_time_clause1  VARCHAR2(3000);

BEGIN

         getCommonClauses(p_sr_id_num,p_conv_rate,p_asof_date,p_priorasof_date,p_fdcp_date,p_fdpp_date
                         ,l_main_clause0,l_main_clause1,l_main_clause2,l_res_clause,l_time_clause0,l_time_clause1,l_summ);

         l_query := ' SELECT PCD.Id
                            ,PCD.Value
                            ,ASO_VALUE1,ASO_VALUE2,ASO_VALUE3,ASO_VALUE4,ASO_VALUE5,ASO_VALUE6,ASO_VALUE7,ASO_VALUE8
                            ,DECODE(PCD.Leaf_node_flag,''Y''
                                   ,''pFunctionName=ASO_BI_SUM_BY_PC_PHP&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM&VIEW_BY_NAME=VIEW_BY_ID''
                                   ,''pFunctionName=ASO_BI_SUM_BY_PC_PHP&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'')
                      FROM
                          (SELECT Inn0.Category_id '|| l_summ ||
                          ' FROM
                               (SELECT Sumry.Category_id '|| l_main_clause0 ||
                              ' FROM  ASO_BI_QLIN_PC_MV Sumry
                                     ,FII_TIME_RPT_STRUCT_V CAL
                                WHERE '|| l_time_clause0 || l_res_clause ||
                                      ' AND Sumry.Master_id = :p_product_id
                                        AND Sumry.Category_flag = ''N''  ';

            l_query := l_query ||
                     ' UNION ALL
                           (SELECT Sumry.Category_id '|| l_main_clause1 ||
                              ' FROM  ASO_BI_QLIN_PC_MV Sumry
                                     ,FII_TIME_RPT_STRUCT_V CAL
                                WHERE '|| l_time_clause1 || l_res_clause ||
                                      ' AND Sumry.Master_id = :p_product_id
                                        AND Sumry.Category_flag = ''N'')';

            l_query := l_query ||
                     ' UNION ALL
                       SELECT Sumry.Category_id '|| l_main_clause2 ||
                     ' FROM  ASO_BI_QLIN_PC_MV Sumry
                       WHERE  Sumry.Time_id IN (:p_fdcp_date_j,:p_fdpp_date_j)
                              AND Sumry.Period_Type_Id = 1
                              AND Sumry.Master_id = :p_product_id
                              AND Sumry.Category_flag = ''N''  '|| l_res_clause;


         -- To get the name of the top-level parent this type of join becomes necesarry
         l_query := l_query ||' ) Inn0
                                  GROUP BY Inn0.Category_id
                        )Inn1
                        ,ENI_ITEM_VBH_NODES_V PCD
                        ,ENI_ITEM_VBH_NODES_V PCD1
                    WHERE PCD1.Child_id = Inn1.Category_id
                          AND PCD1.Parent_id = PCD.Id
                          AND PCD.Top_node_flag = ''Y''
                          AND PCD.Id = PCD.Parent_id ';


         executeQuery(l_query
                     ,p_product_id
                     ,p_conv_rate
                     ,p_record_type_id
                     ,p_sg_id_num
                     ,p_sr_id_num
                     ,p_fdcp_date_j
                     ,p_fdpp_date_j
                     ,p_asof_date
                     ,p_priorasof_date
                     ,p_fdcp_date
                     ,p_fdpp_date);


END PCAPrS;

-- Product category : Selected, Product : Selected, View by : Product category

PROCEDURE PCSPrS(p_asof_date      IN DATE
                ,p_priorasof_date IN DATE
                ,p_fdcp_date      IN DATE
                ,p_fdpp_date      IN DATE
                ,p_conv_rate      IN NUMBER
                ,p_record_type_id IN NUMBER
                ,p_sg_id_num      IN NUMBER
                ,p_sr_id_num      IN NUMBER
                ,p_fdcp_date_j    IN NUMBER
                ,p_fdpp_date_j    IN NUMBER
                ,p_product_cat    IN NUMBER
                ,p_product_id     IN VARCHAR2)
AS

l_summ         VARCHAR2(5000);
l_query        VARCHAR2(32000);
l_main_clause0 VARCHAR2(32000);
l_main_clause1 VARCHAR2(32000);
l_main_clause2 VARCHAR2(32000);
l_res_clause   VARCHAR2(3000);
l_time_clause0  VARCHAR2(3000);
l_time_clause1  VARCHAR2(3000);

BEGIN

         getCommonClauses(p_sr_id_num,p_conv_rate,p_asof_date,p_priorasof_date,p_fdcp_date,p_fdpp_date
                         ,l_main_clause0,l_main_clause1,l_main_clause2,l_res_clause,l_time_clause0,l_time_clause1,l_summ);

         INSERT INTO ASO_BI_RPT_TMP2(ASO_VALUE1,ASO_VALUE2)
         SELECT PCD.Child_id,PCD.Imm_child_id
         FROM ENI_DENORM_HIERARCHIES PCD
             ,MTL_DEFAULT_CATEGORY_SETS MDFT
         WHERE PCD.Parent_id = p_product_cat
               AND (PCD.Leaf_node_flag = 'Y' OR (PCD.Leaf_node_flag = 'N' AND PCD.Parent_id<>PCD.Imm_child_id))
               AND MDFT.Functional_area_id = 11
               AND MDFT.Category_set_id = PCD.Object_id
               AND PCD.Object_type = 'CATEGORY_SET'
               AND PCD.Dbi_flag = 'Y';

         l_query := ' SELECT PCD.Id
                            ,PCD.Value
                            ,ASO_VALUE1,ASO_VALUE2,ASO_VALUE3,ASO_VALUE4,ASO_VALUE5,ASO_VALUE6,ASO_VALUE7,ASO_VALUE8
                            ,DECODE(PCD.Leaf_node_flag,''Y''
                                   ,''pFunctionName=ASO_BI_SUM_BY_PC_PHP&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM&VIEW_BY_NAME=VIEW_BY_ID''
                                   ,''pFunctionName=ASO_BI_SUM_BY_PC_PHP&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'')
                      FROM
                         (SELECT Inn0.Id '|| l_summ ||
                        ' FROM
                             (SELECT /*+ Ordered */ TMP.ASO_VALUE2 Id '|| l_main_clause0 ||
                             ' FROM FII_TIME_RPT_STRUCT_V CAL
                                   ,ASO_BI_RPT_TMP2 TMP
                                   ,ASO_BI_QLIN_PC_MV SUMRY
                               WHERE '|| l_time_clause0 || l_res_clause ||
                                     ' AND SUMRY.Category_id = TMP.ASO_VALUE1
                                       AND SUMRY.Master_id = :p_product_id
                                       AND SUMRY.Category_flag = ''N''';

        l_query := l_query ||
                      ' UNION ALL
                             (SELECT /*+ Ordered */ TMP.ASO_VALUE2 Id '|| l_main_clause1 ||
                             ' FROM FII_TIME_RPT_STRUCT_V CAL
                                   ,ASO_BI_RPT_TMP2 TMP
                                   ,ASO_BI_QLIN_PC_MV SUMRY
                               WHERE '|| l_time_clause1 || l_res_clause ||
                                     ' AND SUMRY.Category_id = TMP.ASO_VALUE1
                                       AND SUMRY.Master_id = :p_product_id
                                       AND SUMRY.Category_flag = ''N'')';

        l_query := l_query ||
                      ' UNION ALL
                        SELECT  /*+ Leading(TMP) */ TMP.ASO_VALUE2 '|| l_main_clause2 ||
                      ' FROM ASO_BI_QLIN_PC_MV SUMRY
                            ,ASO_BI_RPT_TMP2 TMP
                        WHERE SUMRY.Time_id IN (:p_fdcp_date_j,:p_fdpp_date_j)
                              AND SUMRY.Period_Type_Id = 1
                              AND SUMRY.Category_id = TMP.ASO_VALUE1
                              AND SUMRY.Master_id = :p_product_id
                              AND SUMRY.Category_flag = ''N'' '|| l_res_clause ;


         l_query := l_query ||' ) Inn0
                                 GROUP BY Inn0.Id
                   ) Inn1
                   ,ENI_ITEM_VBH_NODES_V PCD
                   WHERE PCD.Id = Inn1.Id
                         AND PCD.Parent_id = Inn1.Id
                         AND PCD.Child_id = Inn1.Id ';

         executeQuery(l_query
                     ,p_product_id
                     ,p_conv_rate
                     ,p_record_type_id
                     ,p_sg_id_num
                     ,p_sr_id_num
                     ,p_fdcp_date_j
                     ,p_fdpp_date_j
                     ,p_asof_date
                     ,p_priorasof_date
                     ,p_fdcp_date
                     ,p_fdpp_date);

END PCSPrS;

-- Product category : All, Product : All, View by : Product

PROCEDURE PCAllProd(p_conv_rate      IN NUMBER
                   ,p_record_type_id IN NUMBER
                   ,p_sg_id_num      IN NUMBER
                   ,p_sr_id_num      IN NUMBER
                   ,p_fdcp_date_j    IN NUMBER
                   ,p_fdpp_date_j    IN NUMBER
                   ,p_asof_date      IN DATE
                   ,p_priorasof_date IN DATE
                   ,p_fdcp_date      IN DATE
                   ,p_fdpp_date      IN DATE)
AS

l_summ         VARCHAR2(5000);
l_query        VARCHAR2(32000);
l_main_clause0 VARCHAR2(32000);
l_main_clause1 VARCHAR2(32000);
l_main_clause2 VARCHAR2(32000);
l_res_clause   VARCHAR2(3000);
l_time_clause0  VARCHAR2(3000);
l_time_clause1  VARCHAR2(3000);

BEGIN

         getCommonClauses(p_sr_id_num,p_conv_rate,p_asof_date,p_priorasof_date,p_fdcp_date,p_fdpp_date
                         ,l_main_clause0,l_main_clause1,l_main_clause2,l_res_clause,l_time_clause0,l_time_clause1,l_summ);

         /*ASO_ATTRIBUTE1,VIEWBY,ASO_VALUE1,ASO_VALUE2,ASO_VALUE3,ASO_VALUE4,ASO_VALUE5
                                                       ,ASO_VALUE6,ASO_VALUE7,ASO_VALUE8,ASO_URL1*/

         l_query := ' SELECT PCD.Id,PCD.Value,ASO_VALUE1,ASO_VALUE2,ASO_VALUE3,ASO_VALUE4,ASO_VALUE5,ASO_VALUE6,ASO_VALUE7,ASO_VALUE8,PCD.description
                      FROM
                          (SELECT Inn0.Master_id '|| l_summ ||
                         ' FROM
                               (SELECT Sumry.Master_id '|| l_main_clause0 ||
                              ' FROM ASO_BI_QLIN_PC_MV SUMRY
                                    ,FII_TIME_RPT_STRUCT_V CAL
                                WHERE '|| l_time_clause0 || l_res_clause ||
                                      ' AND SUMRY.Category_flag = ''N'' ';
          l_query := l_query ||
                         ' UNION ALL
                              (SELECT Sumry.Master_id '|| l_main_clause1 ||
                              ' FROM ASO_BI_QLIN_PC_MV SUMRY
                                    ,FII_TIME_RPT_STRUCT_V CAL
                                WHERE '|| l_time_clause1 || l_res_clause ||
                                      ' AND SUMRY.Category_flag = ''N'')';

           l_query := l_query ||
                       ' UNION ALL
                         SELECT Sumry.Master_id '|| l_main_clause2 ||
                       ' FROM ASO_BI_QLIN_PC_MV SUMRY
                         WHERE SUMRY.Time_id in (:p_fdcp_date_j,:p_fdpp_date_j)
                               AND SUMRY.Period_Type_Id = 1
                               AND SUMRY.Category_flag = ''N''  '|| l_res_clause ;


         l_query := l_query ||' ) Inn0
                                  GROUP BY Inn0.Master_id
                      ) Inn1,
                        ENI_ITEM_V PCD
                        WHERE Inn1.Master_id = PCD.Id ';

         executeQuery(l_query
                     ,NULL
                     ,p_conv_rate
                     ,p_record_type_id
                     ,p_sg_id_num
                     ,p_sr_id_num
                     ,p_fdcp_date_j
                     ,p_fdpp_date_j
                     ,p_asof_date
                     ,p_priorasof_date
                     ,p_fdcp_date
                     ,p_fdpp_date);

END PCAllProd;

--Quote summary by PC : PC - selected, prod - all:View by product

PROCEDURE PCSPrAProd(p_asof_date      IN DATE
                    ,p_priorasof_date IN DATE
                    ,p_fdcp_date      IN DATE
                    ,p_fdpp_date      IN DATE
                    ,p_conv_rate      IN NUMBER
                    ,p_record_type_id IN NUMBER
                    ,p_sg_id_num      IN NUMBER
                    ,p_sr_id_num      IN NUMBER
                    ,p_fdcp_date_j    IN NUMBER
                    ,p_fdpp_date_j    IN NUMBER
                    ,p_product_cat    IN NUMBER)
AS

l_summ         VARCHAR2(5000);
l_query        VARCHAR2(32000);
l_main_clause0 VARCHAR2(32000);
l_main_clause1 VARCHAR2(32000);
l_main_clause2 VARCHAR2(32000);
l_res_clause   VARCHAR2(3000);
l_time_clause0  VARCHAR2(3000);
l_time_clause1  VARCHAR2(3000);
BEGIN

         getCommonClauses(p_sr_id_num,p_conv_rate,p_asof_date,p_priorasof_date,p_fdcp_date,p_fdpp_date
                         ,l_main_clause0,l_main_clause1,l_main_clause2,l_res_clause,l_time_clause0,l_time_clause1,l_summ);

         INSERT INTO ASO_BI_RPT_TMP2(ASO_VALUE1)
         SELECT PCD.Child_id
         FROM ENI_DENORM_HIERARCHIES PCD
             ,MTL_DEFAULT_CATEGORY_SETS MDFT
         WHERE PCD.Parent_id = p_product_cat
               AND (PCD.Leaf_node_flag = 'Y' OR (PCD.Leaf_node_flag = 'N' AND PCD.Parent_id<>PCD.Imm_child_id))
               AND MDFT.Functional_area_id = 11
               AND MDFT.Category_set_id = PCD.Object_id
               AND PCD.Object_type = 'CATEGORY_SET'
               AND PCD.Dbi_flag = 'Y';

         l_query := ' SELECT PCD.ID,PCD.VALUE,ASO_VALUE1,ASO_VALUE2,ASO_VALUE3,ASO_VALUE4,ASO_VALUE5,ASO_VALUE6,ASO_VALUE7,ASO_VALUE8,PCD.description
                      FROM
                        (SELECT Inn0.Master_id '|| l_summ ||
                       ' FROM
                             (SELECT /*+ Ordered */ SUMRY.Master_Id '|| l_main_clause0 ||
                            ' FROM FII_TIME_RPT_STRUCT_V CAL
                                  ,ASO_BI_RPT_TMP2 TMP
                                  ,ASO_BI_QLIN_PC_MV SUMRY
                              WHERE '|| l_time_clause0 || l_res_clause ||
                            ' AND SUMRY.Category_flag = ''N''
                              AND SUMRY.Category_id = TMP.ASO_VALUE1 ';

            l_query := l_query ||
                      ' UNION ALL
                             (SELECT /*+ Ordered */ SUMRY.Master_Id '|| l_main_clause1 ||
                            ' FROM FII_TIME_RPT_STRUCT_V CAL
                                  ,ASO_BI_RPT_TMP2 TMP
                                  ,ASO_BI_QLIN_PC_MV SUMRY
                              WHERE '|| l_time_clause1 || l_res_clause ||
                            ' AND SUMRY.Category_flag = ''N''
                              AND SUMRY.Category_id = TMP.ASO_VALUE1)';

            l_query := l_query ||
                      ' UNION ALL
                        SELECT /*+ Leading(TMP) */ SUMRY.Master_Id '|| l_main_clause2 ||
                      ' FROM ASO_BI_QLIN_PC_MV SUMRY
                            ,ASO_BI_RPT_TMP2 TMP
                        WHERE SUMRY.Time_id in (:p_fdcp_date_j,:p_fdpp_date_j)
                              AND SUMRY.Period_Type_Id = 1
                              AND SUMRY.Category_flag = ''N''
                              AND SUMRY.Category_id = TMP.ASO_VALUE1 '|| l_res_clause ;


         l_query := l_query ||' ) Inn0
                                 GROUP BY Inn0.Master_id
                    ) Inn1
                     ,ENI_ITEM_V PCD
                   WHERE Inn1.Master_id = PCD.ID ';

         executeQuery(l_query
                     ,NULL
                     ,p_conv_rate
                     ,p_record_type_id
                     ,p_sg_id_num
                     ,p_sr_id_num
                     ,p_fdcp_date_j
                     ,p_fdpp_date_j
                     ,p_asof_date
                     ,p_priorasof_date
                     ,p_fdcp_date
                     ,p_fdpp_date);

END PCSPrAProd;

--Quote summary by PC : PC - All, prod - Selected : View by product

PROCEDURE PCAPrSProd(p_asof_date      IN DATE
                    ,p_priorasof_date IN DATE
                    ,p_fdcp_date      IN DATE
                    ,p_fdpp_date      IN DATE
                    ,p_conv_rate      IN NUMBER
                    ,p_record_type_id IN NUMBER
                    ,p_sg_id_num      IN NUMBER
                    ,p_sr_id_num      IN NUMBER
                    ,p_fdcp_date_j    IN NUMBER
                    ,p_fdpp_date_j    IN NUMBER
                    ,p_product_id     IN VARCHAR2)
AS

l_summ         VARCHAR2(5000);
l_query        VARCHAR2(32000);
l_main_clause0 VARCHAR2(32000);
l_main_clause1 VARCHAR2(32000);
l_main_clause2 VARCHAR2(32000);
l_res_clause   VARCHAR2(3000);
l_time_clause0  VARCHAR2(3000);
l_time_clause1  VARCHAR2(3000);

BEGIN

         getCommonClauses(p_sr_id_num,p_conv_rate,p_asof_date,p_priorasof_date,p_fdcp_date,p_fdpp_date
                         ,l_main_clause0,l_main_clause1,l_main_clause2,l_res_clause,l_time_clause0,l_time_clause1,l_summ);

         l_query := ' SELECT PCD.Id,PCD.Value,ASO_VALUE1,ASO_VALUE2,ASO_VALUE3,ASO_VALUE4,ASO_VALUE5,ASO_VALUE6,ASO_VALUE7,ASO_VALUE8,PCD.description
                      FROM
                         (SELECT Inn0.Master_id '|| l_summ ||
                        '  FROM
                             (SELECT Sumry.Master_id '|| l_main_clause0 ||
                            ' FROM ASO_BI_QLIN_PC_MV SUMRY
                                  ,FII_TIME_RPT_STRUCT_V CAL
                              WHERE '|| l_time_clause0 || l_res_clause ||
                                    ' AND SUMRY.Category_flag = ''N''
                                      AND SUMRY.Master_id = :p_product_id ';

           l_query := l_query ||
                       ' UNION ALL
                              (SELECT Sumry.Master_id '|| l_main_clause1 ||
                            ' FROM ASO_BI_QLIN_PC_MV SUMRY
                                  ,FII_TIME_RPT_STRUCT_V CAL
                              WHERE '|| l_time_clause1 || l_res_clause ||
                                    ' AND SUMRY.Category_flag = ''N''
                                      AND SUMRY.Master_id = :p_product_id )';


	    l_query := l_query ||
                       ' UNION ALL
                         SELECT Sumry.Master_id '|| l_main_clause2 ||
                       ' FROM ASO_BI_QLIN_PC_MV SUMRY
                         WHERE SUMRY.Time_id in (:p_fdcp_date_j,:p_fdpp_date_j)
                               AND SUMRY.Period_Type_Id = 1
                               AND SUMRY.Category_flag = ''N''
                               AND SUMRY.Master_id = :p_product_id '|| l_res_clause ;


         l_query := l_query ||' ) Inn0
                              GROUP BY Inn0.Master_id
                    ) Inn1
                     ,ENI_ITEM_V PCD
                     WHERE PCD.Id = Inn1.Master_id ';

         executeQuery(l_query
                     ,p_product_id
                     ,p_conv_rate
                     ,p_record_type_id
                     ,p_sg_id_num
                     ,p_sr_id_num
                     ,p_fdcp_date_j
                     ,p_fdpp_date_j
                     ,p_asof_date
                     ,p_priorasof_date
                     ,p_fdcp_date
                     ,p_fdpp_date);

END PCAPrSProd;

--Quote summary by PC : PC - selected, prod - selected:View by product

PROCEDURE PCSPrSProd(p_asof_date      IN DATE
                    ,p_priorasof_date IN DATE
                    ,p_fdcp_date      IN DATE
                    ,p_fdpp_date      IN DATE
                    ,p_conv_rate      IN NUMBER
                    ,p_record_type_id IN NUMBER
                    ,p_sg_id_num      IN NUMBER
                    ,p_sr_id_num      IN NUMBER
                    ,p_fdcp_date_j    IN NUMBER
                    ,p_fdpp_date_j    IN NUMBER
                    ,p_product_cat    IN NUMBER
                    ,p_product_id     IN VARCHAR2)
AS

l_summ         VARCHAR2(5000);
l_query        VARCHAR2(32000);
l_main_clause0 VARCHAR2(32000);
l_main_clause1 VARCHAR2(32000);
l_main_clause2 VARCHAR2(32000);
l_res_clause   VARCHAR2(3000);
l_time_clause0  VARCHAR2(3000);
l_time_clause1  VARCHAR2(3000);

BEGIN

         getCommonClauses(p_sr_id_num,p_conv_rate,p_asof_date,p_priorasof_date,p_fdcp_date,p_fdpp_date
                         ,l_main_clause0,l_main_clause1,l_main_clause2,l_res_clause,l_time_clause0,l_time_clause1,l_summ);

         INSERT INTO ASO_BI_RPT_TMP2(ASO_VALUE1)
         SELECT PCD.Child_id
         FROM ENI_DENORM_HIERARCHIES PCD
             ,MTL_DEFAULT_CATEGORY_SETS MDFT
         WHERE PCD.Parent_id = p_product_cat
               AND (PCD.Leaf_node_flag = 'Y' OR (PCD.Leaf_node_flag = 'N' AND PCD.Parent_id<>PCD.Imm_child_id))
               AND MDFT.Functional_area_id = 11
               AND MDFT.Category_set_id = PCD.Object_id
               AND PCD.Object_type = 'CATEGORY_SET'
               AND PCD.Dbi_flag = 'Y';

         l_query := ' SELECT PCD.Id,PCD.Value,ASO_VALUE1,ASO_VALUE2,ASO_VALUE3,ASO_VALUE4,ASO_VALUE5,ASO_VALUE6,ASO_VALUE7,ASO_VALUE8,PCD.description
                      FROM
                          (SELECT Inn0.Master_id '|| l_summ ||
                        '  FROM
                              (SELECT /*+ Ordered */ Sumry.Master_id '|| l_main_clause0 ||
                             ' FROM  FII_TIME_RPT_STRUCT_V CAL
                                    ,ASO_BI_RPT_TMP2 TMP
                                    ,ASO_BI_QLIN_PC_MV SUMRY
                               WHERE '|| l_time_clause0 || l_res_clause ||
                                     ' AND SUMRY.Category_flag = ''N''
                                       AND SUMRY.Master_id = :p_product_id
                                       AND SUMRY.Category_id = TMP.ASO_VALUE1 ';

          l_query := l_query ||
                       ' UNION ALL
                            (SELECT /*+ Ordered */ Sumry.Master_id '|| l_main_clause1 ||
                             ' FROM  FII_TIME_RPT_STRUCT_V CAL
                                    ,ASO_BI_RPT_TMP2 TMP
                                    ,ASO_BI_QLIN_PC_MV SUMRY
                               WHERE '|| l_time_clause1 || l_res_clause ||
                                     ' AND SUMRY.Category_flag = ''N''
                                       AND SUMRY.Master_id = :p_product_id
                                        AND SUMRY.Category_id = TMP.ASO_VALUE1) ';


          l_query := l_query ||
                       ' UNION ALL
                       SELECT /*+ Leading(TMP) */ Sumry.Master_id '|| l_main_clause2 ||
                     ' FROM  ASO_BI_QLIN_PC_MV SUMRY
                            ,ASO_BI_RPT_TMP2 TMP
                       WHERE SUMRY.Time_id IN (:p_fdcp_date_j,:p_fdcp_date_j)
                             AND SUMRY.Period_Type_Id = 1
                             AND SUMRY.Category_flag = ''N''
                             AND SUMRY.Master_id = :l_product_id
                             AND SUMRY.Category_id = TMP.ASO_VALUE1 '|| l_res_clause ;


         l_query := l_query ||' ) Inn0
                                  GROUP BY Inn0.Master_id
                    ) Inn1
                   ,ENI_ITEM_V PCD
                   WHERE PCD.Id = Inn1.Master_id ';

         executeQuery(l_query
                     ,p_product_id
                     ,p_conv_rate
                     ,p_record_type_id
                     ,p_sg_id_num
                     ,p_sr_id_num
                     ,p_fdcp_date_j
                     ,p_fdpp_date_j
                     ,p_asof_date
                     ,p_priorasof_date
                     ,p_fdcp_date
                     ,p_fdpp_date);

END PCSPrSProd;
END ASO_BI_QOT_PC_PVT;

/
