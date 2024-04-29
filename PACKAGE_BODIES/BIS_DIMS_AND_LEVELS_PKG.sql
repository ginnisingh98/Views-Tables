--------------------------------------------------------
--  DDL for Package Body BIS_DIMS_AND_LEVELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_DIMS_AND_LEVELS_PKG" AS
/* $Header: BISKDDLB.pls 120.2 2006/09/01 04:59:17 ankgoel noship $ */


FUNCTION bis_kpi_report ( p_params IN BIS_PMV_PAGE_PARAMETER_TBL  )
RETURN VARCHAR2 IS

	l_ret_string 	 VARCHAR2(8000) := NULL;
	l_startdate  	 VARCHAR2(1000)  := NULL;
	l_enddate		 VARCHAR2(1000)  := NULL;
      l_pname      	 VARCHAR2(2000)  := NULL;
	l_pvalue     	 VARCHAR2(2000)  := NULL;
	l_name 		     VARCHAR(500)	:= NULL;
	l_developer 	 VARCHAR2(500)	:= NULL;
	l_kpi_name_filter VARCHAR2(1500)   := NULL ; -- ' AND 1 = 1 ';
	l_lvl_nm_filter  VARCHAR2(1500)   := NULL ; -- ' AND 1 = 1 ';
	l_app_nm_filter VARCHAR2(1500)   := NULL ; -- ' AND 1 = 1 ';
	l_dim_name_filter VARCHAR2(1500)   := NULL ; -- ' AND 1 = 1 ';
	l_kpi_desc_filter VARCHAR2(1500)   := NULL ; -- ' AND 1 = 1 ';
	l_order_by        VARCHAR2(150)  := NULL;
	l_group_by        VARCHAR2(150) := ' GROUP BY bi.name, bi.description, bi.indicator_id, f.application_name ';
  l_source_filter   VARCHAR2(1500) := NULL;
	l_where_clause    VARCHAR2(1500)   := NULL;


BEGIN

 -- insert into tmp2 (seq, value) values (temp_seq.nextval, ' <*************** begin ***************> '|| to_char(sysdate, 'dd-mon-yyyy hh:mi:ss') ); commit;

 FOR i IN 1..p_params.count LOOP

    l_pname  := p_params(i).parameter_name;
    l_pvalue := BIS_UTILITIES_PVT.filter_quotes(p_params(i).parameter_value);

    -- insert into tmp2 (seq, value) values (temp_seq.nextval, '(<---------------- pname ->'||l_pname||'<-pvalue->'||l_pvalue||'<------------------>)' ); commit;


    IF ( l_pname = 'KPI_DESCRIPTION2' ) THEN

	  IF (l_pvalue <> 'All') THEN
	    l_kpi_desc_filter := ' AND UPPER(bi.description) LIKE UPPER(''' || '%' || l_pvalue || '%' || ''') ';
	  END IF;


    ELSIF ( l_pname = 'APPLX+APPLX' ) THEN

	  IF (l_pvalue <> 'All') THEN
	    l_app_nm_filter := ' AND f.application_name = ''' || l_pvalue || ''' ' ;
	  END IF;

    ELSIF ( l_pname = 'LVL_NM+LVL_NM' ) THEN

	  IF (l_pvalue <> 'All') THEN
	    l_lvl_nm_filter := ' AND bl.name = ''' || l_pvalue || ''' ';
	  END IF;

    ELSIF ( l_pname = 'KPI_NAME1' ) THEN
	  IF (l_pvalue <> 'All') THEN
	  	l_kpi_name_filter := ' AND UPPER(bi.name) LIKE UPPER(''' || '%' || l_pvalue || '%' || ''') ';
	  END IF;

	ELSIF (l_pname LIKE '%ORDERBY%') THEN

	    -- Select * from tmp2 order by seq desc;
		-- l_order_by := ' WHERE ';
		l_order_by := ' ORDER BY ';

  	    IF (l_pvalue LIKE '%LEVEL_NAME , DIMENSION_NAME1, LEVEL_DESCRIPTION%') THEN
		  l_order_by := l_order_by || ' LEVEL_NAME , DIMENSION_NAME1, LEVEL_DESCRIPTION ';
	    ELSIF (l_pvalue LIKE '%LEVEL_NAME%') THEN
		  l_order_by := l_order_by || ' LEVEL_NAME ';
	    ELSIF (l_pvalue LIKE '%DIMENSION_NAME1%') THEN
		  l_order_by := l_order_by || ' DIMENSION_NAME1 ';
	    ELSIF (l_pvalue LIKE '%LEVEL_DESCRIPTION%') THEN
		  l_order_by := l_order_by || ' LEVEL_DESCRIPTION ';
		ELSE
		  l_order_by := l_order_by || ' LEVEL_NAME , DIMENSION_NAME1, LEVEL_DESCRIPTION ';
		END IF;

	    IF (l_pvalue LIKE '%DESC') THEN
		  l_order_by := l_order_by || ' DESC ' ;
	    ELSE
		  IF (l_pvalue IS NOT NULL ) THEN
		    l_order_by := l_order_by || ' ' ;
		  END IF;
		END IF;

        -- insert into tmp2 (seq, value) values (temp_seq.nextval, ' l_order_by: ' || l_order_by ); commit;

	  END IF;
   END LOOP;

   l_where_clause := l_app_nm_filter || l_kpi_desc_filter || l_lvl_nm_filter || l_kpi_name_filter;


   -- decode (product_id, 163, ''BIS'', 205, ''BSC'')
-- Used SUBSTR on the queries as PMV restricts the length to 180 characters
-- For NLS issues, an error occurs if the length exceeds 180 characters
   l_ret_string := '
SELECT
     bi.name KPI_NAME2
   , SUBSTR(NVL(bi.description, '' ''),1,180) KPI_DESCRIPTION1
   , SUBSTR(NVL(BIS_DIMS_AND_LEVELS_PKG.get_level_names(bi.indicator_id), '' ''),1,180) LEVEL_NAMES
   , SUBSTR(NVL(f.application_name, '' ''),1,180) Owning_applicn_name2
FROM
     bis_indicators_vl bi
   , bis_levels_vl bl
   , BIS_IND_TL_LVL_V bitlv
   , bis_application_measures bam
   , fnd_application_vl f
WHERE bitlv.indicator_id = bi.indicator_id
  AND bitlv.level_id = bl.level_id
  AND bi.indicator_id = bam.indicator_id
  AND bam.application_id = f.application_id
'
  || l_where_clause
  || l_group_by
  || ' ORDER BY bi.name,  bi.description ';

    -- insert into tmp2 (seq, value) values (temp_seq.nextval, l_ret_string); commit;

    -- insert into tmp2 (seq, value) values (temp_seq.nextval, ' <*************** end ***************> '|| to_char(sysdate, 'dd-mon-yyyy hh:mi:ss') ); commit;

	return l_ret_string;

END bis_kpi_report;

FUNCTION bis_measure_report ( p_params IN BIS_PMV_PAGE_PARAMETER_TBL  )
RETURN VARCHAR2 IS
  l_ret_string 	       VARCHAR2(8000) := NULL;
  l_pname      	       VARCHAR2(2000) := NULL;
  l_pvalue     	       VARCHAR2(2000) := NULL;
  l_pid                VARCHAR2(100)  := NULL;
  l_kpi_name_filter    VARCHAR2(1500) := NULL;
  l_app_nm_filter      VARCHAR2(1500) := NULL;
  l_kpi_source_filter  VARCHAR2(1500) := NULL;
  l_source_filter      VARCHAR2(1500) := NULL;
  l_where_clause       VARCHAR2(1500) := NULL;
BEGIN
  FOR i IN 1..p_params.count LOOP
    l_pname  := p_params(i).parameter_name;
    l_pvalue := BIS_UTILITIES_PVT.filter_quotes(p_params(i).parameter_value);
    l_pid    := p_params(i).parameter_id;
    IF ( l_pname = 'LVLNM+LVLNM' ) THEN -- Filter according to KPI Indicator
      IF (l_pvalue <> 'All') THEN
	l_kpi_name_filter := ' AND bi.indicator_id = '||l_pid ;
      END IF;
    ELSIF ( l_pname = 'APPLX+APPLX' ) THEN -- Filter according to Application
      IF (l_pvalue <> 'All') THEN
	l_app_nm_filter := ' AND f.application_name = ''' || l_pvalue || ''' ' ;
      END IF;
    ELSIF ( l_pname = 'KTYPE+KTYPE' ) THEN -- -- Filter according to Source
      IF (l_pvalue <> 'All') THEN
        l_kpi_source_filter := ' AND sys.source = '||l_pid;
      END IF;
    END IF;
   END LOOP;
   l_where_clause := l_app_nm_filter || l_kpi_source_filter ||l_kpi_name_filter;
   l_ret_string := '
     SELECT
       bi.name KPI_NAME2
       ,SUBSTR(NVL(bi.description, '' ''),1,180) KPI_DESCRIPTION1
       ,bi.short_name LEVEL_NAMES
       ,SUBSTR(NVL(f.application_name, '' ''),1,180) Owning_applicn_name2
      FROM
        bis_indicators_vl bi,
        bis_application_measures measures,
        bis_indicators indicators,
        bsc_sys_datasets_vl datasets,
        bsc_sys_measures sys,
        fnd_application_vl f
      WHERE
        bi.indicator_id = measures.indicator_id AND
        measures.application_id = f.application_id(+) AND
        indicators.dataset_id = datasets.dataset_id AND
        datasets.measure_id1 = sys.measure_id AND
        indicators.indicator_id = bi.indicator_id '
        || l_where_clause
        || ' ORDER BY bi.name,  bi.description ';
   return l_ret_string;
END bis_measure_report;

FUNCTION bis_levels_report ( p_params IN BIS_PMV_PAGE_PARAMETER_TBL  )
RETURN VARCHAR2 IS

	l_ret_string 	 VARCHAR2(8000) := NULL;
	l_startdate  	 VARCHAR2(1000)  := NULL;
	l_enddate		 VARCHAR2(1000)  := NULL;
    l_pname      	 VARCHAR2(2000)  := NULL;
	l_pvalue     	 VARCHAR2(2000)  := NULL;
	l_name 		     VARCHAR(500)	:= NULL;
	l_developer 	 VARCHAR2(500)	:= NULL;
	l_kpi_nm_filter    VARCHAR2(1500)   := NULL ; -- ' AND 1 = 1 ';
	l_lvl_nm_filter    VARCHAR2(1500)   := NULL ; -- ' AND 1 = 1 ';
	l_app_nm_filter   VARCHAR2(1500)   := NULL ; -- ' AND 1 = 1 ';
	l_dim_nm_filter    VARCHAR2(1500)   := NULL ; -- ' AND 1 = 1 ';
	l_lvl_desc_filter    VARCHAR2(1500)   := NULL ; -- ' AND 1 = 1 ';
	l_order_by       VARCHAR2(150)  := NULL;
    l_source_filter   VARCHAR2(1500) := NULL;
	l_where_clause    VARCHAR2(1500)   := NULL;
	l_group_by        VARCHAR2(150) := ' GROUP BY bd.name, bl.name, bl.description, bl.level_values_view_name ';
	l_src_filter        VARCHAR2(1500) := NULL;
	l_dyn_table	    VARCHAR2(50) := NULL;
	l_kpi_table_names   VARCHAR2(100) := NULL;
  l_kpi_where_clause  VARCHAR2(100) := NULL;

BEGIN

 -- insert into tmp2 (seq, value) values (temp_seq.nextval, ' <*************** begin ***************> '|| to_char(sysdate, 'dd-mon-yyyy hh:mi:ss') ); commit;

 -- LEVEL_NAME1  KPI_NM+KPI_NM  APPLX+APPLX  LEVEL_DESCRIPTION

 FOR i IN 1..p_params.count LOOP

    l_pname  := p_params(i).parameter_name;
    l_pvalue := BIS_UTILITIES_PVT.filter_quotes(p_params(i).parameter_value);

	-- insert into tmp2 (seq, value) values (temp_seq.nextval, '(<---------------- pname ->'||l_pname||'<-pvalue->'||l_pvalue||'<------------------>)' ); commit;

	IF ( l_pname = 'LEVEL_NAME1' ) THEN

	  IF (l_pvalue <> 'All') THEN
	      l_lvl_nm_filter := ' AND UPPER(bl.name) LIKE UPPER( ''' || '%' ||  l_pvalue || '%' || ''')  ' ;
	  END IF;

    ELSIF ( l_pname = 'LVL_SRC_TYP+LVL_SRC_TYP' ) THEN

	  IF (l_pvalue <> 'All') THEN
	    l_src_filter  := ' AND bl.source = ''' || l_pvalue || '''  ';
	  END IF;

    ELSIF ( l_pname = 'DIM_NMX+DIM_NMX' ) THEN

	  IF (l_pvalue <> 'All') THEN
	    l_dim_nm_filter  := ' AND bd.name = ''' || l_pvalue || ''' '	;
	  END IF;

    ELSIF ( l_pname = 'KPI_NM+KPI_NM' ) THEN

	  IF (l_pvalue <> 'All') THEN
	    l_kpi_nm_filter  := ' AND bi.name = ''' || l_pvalue || ''' ';
	    l_kpi_table_names := ' , bis_indicators_vl bi ' ||
				 ' , BIS_IND_TL_LVL_V bitlv ';
	    l_kpi_where_clause := ' AND bitlv.indicator_id = bi.indicator_id ' ||
				  ' AND bitlv.level_id = bl.level_id ';
	  END IF;

    ELSIF ( l_pname = 'APPLX+APPLX' ) THEN

	  IF (l_pvalue <> 'All') THEN
	    l_app_nm_filter := ' AND bl.application_id = f.application_id AND f.application_name = ''' || l_pvalue || ''' ' ;
	    l_dyn_table := ' , fnd_application_vl f ' ;
	  END IF;

    ELSIF ( l_pname = 'LEVEL_DESCRIPTION' ) THEN

	  IF (l_pvalue <> 'All') THEN
	      l_lvl_desc_filter := ' AND UPPER(bl.description) LIKE UPPER( ''' || '%' ||  l_pvalue || '%' || ''')  ' ;
	  END IF;

	ELSIF (l_pname LIKE '%ORDERBY%') THEN

	    -- Select * from tmp2 order by seq desc;
		-- l_order_by := ' WHERE ';

  	    IF (l_pvalue LIKE '%DIMENSION_NAME1%') THEN
		  l_order_by := ' DIMENSION_NAME1, LEVEL_NAME , LEVEL_DESCRIPTION ';
	    ELSIF (l_pvalue LIKE '%APPLICATION_SHORT_NAME%') THEN
		  l_order_by := ' APPLICATION_SHORT_NAME ';
	    ELSIF (l_pvalue LIKE '%APPLICATION_NAME%') THEN
		  l_order_by := ' APPLICATION_NAME , DIMENSION_NAME1, LEVEL_NAME , LEVEL_DESCRIPTION ';
	    ELSIF (l_pvalue LIKE '%DIMENSION_SHORT_NAME%') THEN
		  l_order_by := ' DIMENSION_SHORT_NAME , DIMENSION_NAME1, LEVEL_NAME , LEVEL_DESCRIPTION ';
	    ELSIF (l_pvalue LIKE '%DIMENSION_DESCRIPTION%') THEN
		  l_order_by := ' DIMENSION_DESCRIPTION , DIMENSION_NAME1, LEVEL_NAME ';
	    ELSIF (l_pvalue LIKE '%LEVEL_SHORT_NAME%') THEN
		  l_order_by := ' LEVEL_SHORT_NAME , DIMENSION_NAME1, LEVEL_NAME , LEVEL_DESCRIPTION ';
	    ELSIF (l_pvalue LIKE '%LEVEL_NAME%') THEN
		  l_order_by := ' LEVEL_NAME , DIMENSION_NAME1, LEVEL_DESCRIPTION';
	    ELSIF (l_pvalue LIKE '%LEVEL_DESCRIPTION%') THEN
		  l_order_by := ' LEVEL_DESCRIPTION , DIMENSION_NAME1, LEVEL_NAME ';
	    ELSIF (l_pvalue LIKE '%LEVEL_VALUES_VIEW_NAME%') THEN
		  l_order_by := ' LEVEL_VALUES_VIEW_NAME , DIMENSION_NAME1, LEVEL_NAME , LEVEL_DESCRIPTION ';
	    ELSIF (l_pvalue LIKE '%LEVEL_VAL_SOURCE%') THEN
		  l_order_by := ' LEVEL_VAL_SOURCE , DIMENSION_NAME1, LEVEL_NAME , LEVEL_DESCRIPTION ';
		ELSE
		  l_order_by := ' DIMENSION_NAME1, LEVEL_NAME , LEVEL_DESCRIPTION ';
		END IF;

	    IF (l_pvalue LIKE '%DESC') THEN
		  l_order_by := l_order_by || ' DESC ' ;
	    ELSE
		  IF (l_pvalue IS NOT NULL ) THEN
		    l_order_by := l_order_by || ' ' ;
		  END IF;
		END IF;

        -- insert into tmp2 (seq, value) values (temp_seq.nextval, ' l_order_by: ' || l_order_by ); commit;

	  END IF;
   END LOOP;

  l_where_clause := l_kpi_where_clause || l_lvl_nm_filter || l_kpi_nm_filter || l_app_nm_filter
                 || l_lvl_desc_filter || l_src_filter || l_dim_nm_filter ;

  -- decode (product_id, 163, ''BIS'', 205, ''BSC'')
  l_ret_string := '
SELECT
    SUBSTR(bd.name,1,180) Dimension_name2
  , SUBSTR(bl.name,1,180) Level_name2
  , SUBSTR(NVL(bl.description, '' ''),1,180) Level_description2
  , NVL(bl.level_values_view_name, '' '') Level_value_Source_view2
FROM
    Bis_dimensions_vl bd
  , bis_levels_vl bl
  '
  || l_kpi_table_names
  || l_dyn_table ||
  '
WHERE
      bl.dimension_id = bd.dimension_id
  AND NVL(bd.hide_in_design, ''F'') <> ''T''
  AND NVL(bl.hide_in_design, ''F'') <> ''T''
'
|| l_where_clause
|| l_group_by
|| ' ORDER BY bd.name, bl.name ' ;

    -- insert into tmp2 (seq, value) values (temp_seq.nextval, l_ret_string); commit;

    -- insert into tmp2 (seq, value) values (temp_seq.nextval, ' <*************** end ***************> '|| to_char(sysdate, 'dd-mon-yyyy hh:mi:ss') ); commit;

	return l_ret_string;

END bis_levels_report;


FUNCTION bis_levels_details_report ( p_params IN BIS_PMV_PAGE_PARAMETER_TBL  )
RETURN VARCHAR2 IS

	l_ret_string 	 VARCHAR2(8000) := NULL;
	l_startdate  	 VARCHAR2(1000)  := NULL;
	l_enddate		 VARCHAR2(1000)  := NULL;
    l_pname      	 VARCHAR2(2000)  := NULL;
	l_pvalue     	 VARCHAR2(2000)  := NULL;
	l_name 		     VARCHAR(500)	:= NULL;
	l_developer 	 VARCHAR2(500)	:= NULL;
	l_lvl_nm_filter    VARCHAR2(1500)   := NULL;
	l_kpi_nm_filter    VARCHAR2(1500)   := NULL;
	l_dim_nm_filter    VARCHAR2(1500) := NULL;
	l_dim_gen_filter    VARCHAR2(1500) := NULL;
	l_src_filter        VARCHAR2(1500) := NULL;
	l_lvl_desc_filter   VARCHAR2(1500) := NULL;
	l_app_nm_filter     VARCHAR2(1500) := NULL;
	l_order_by       VARCHAR2(150)  := NULL;
    l_source_filter   VARCHAR2(1500) := NULL;
	l_where_clause    VARCHAR2(1500)   := NULL;
	l_group_by        VARCHAR2(1500) := ' GROUP BY bl.name, bl.short_name, aa.attribute_label_long, bl.description, bl.source, bl.level_id' ;
	l_dyn_table	  VARCHAR2(50) := NULL;

BEGIN

 -- insert into tmp2 (seq, value) values (temp_seq.nextval, ' <*************** begin ***************> '); commit;

 FOR i IN 1..p_params.count LOOP

    l_pname  := p_params(i).parameter_name;
    l_pvalue := BIS_UTILITIES_PVT.filter_quotes(p_params(i).parameter_value);

	-- insert into tmp2 (seq, value) values (temp_seq.nextval, '(<---------------- pname ->'||l_pname||'<-pvalue->'||l_pvalue||'<------------------>)' ); commit;

	IF ( l_pname = 'LEVEL_NAME1' ) THEN

	  IF (l_pvalue <> 'All') THEN
	      l_lvl_nm_filter := ' AND UPPER(bl.name) LIKE UPPER( ''' || '%' ||  l_pvalue || '%' || ''')  ' ;
	  END IF;

    ELSIF ( l_pname = 'LVL_SRC_TYP+LVL_SRC_TYP' ) THEN

	  IF (l_pvalue <> 'All') THEN
	    l_src_filter  := ' AND bl.source = ''' || l_pvalue || '''  ';
	  END IF;

    ELSIF ( l_pname = 'DIM_NMX+DIM_NMX' ) THEN

	  IF (l_pvalue <> 'All') THEN
	    l_dim_nm_filter  := ' AND bd.name = ''' || l_pvalue || ''' '	;
	  END IF;

    ELSIF ( l_pname = 'LEVEL_DESCRIPTION1' ) THEN

	  IF (l_pvalue <> 'All') THEN
	      l_lvl_desc_filter := ' AND UPPER(bl.description) LIKE UPPER( ''' || '%' ||  l_pvalue || '%' || ''')  ' ;
	  END IF;

    ELSIF ( l_pname = 'APPLX+APPLX' ) THEN

	  IF (l_pvalue <> 'All') THEN
	    l_app_nm_filter := ' AND bl.application_id = f.application_id AND f.application_name = ''' || l_pvalue || ''' ' ;
	    l_dyn_table := ' , fnd_application_vl f ' ;
	  END IF;

	ELSIF (l_pname LIKE '%ORDERBY%') THEN

	    -- Select * from tmp2 order by seq desc;

		-- l_order_by := ' WHERE ';

  	    IF ( l_pvalue LIKE '%NAME%DESKRIPTION%SHORT_NAME%' ) THEN
		  l_order_by := ' NAME ';
		ELSIF (l_pvalue LIKE '%SHORT_NAME%') THEN
		  l_order_by := ' SHORT_NAME ';
	    ELSIF (l_pvalue LIKE '%DESKRIPTION%') THEN
		  l_order_by := ' DESKRIPTION ';
	    ELSIF (l_pvalue LIKE '%NAME%') THEN
		  l_order_by := ' NAME ';
		END IF;

	    IF (l_pvalue LIKE '%DESC%') THEN
		  l_order_by := l_order_by || ' DESC ' ;
	    ELSE
		  IF (l_pvalue IS NOT NULL ) THEN
		    l_order_by := l_order_by || ' ' ;
		  END IF;
		END IF;

        -- insert into tmp2 (seq, value) values (temp_seq.nextval, ' l_order_by: ' || l_order_by ); commit;

	  END IF;
   END LOOP;

   l_where_clause := l_lvl_nm_filter || l_src_filter || l_dim_nm_filter
	                  || l_lvl_desc_filter || l_app_nm_filter;

  -- decode (product_id, 163, ''BIS'', 205, ''BSC'')
  l_ret_string := '
SELECT
    SUBSTR(bl.name,1,180) Level_name
  , bl.short_name Level_Internal_name
  , aa.attribute_label_long Level_Short_name
  , SUBSTR(NVL(bl.description, '' ''),1,180) Level_description
  , bl.source Level_value_Source_type1
  , SUBSTR(NVL(BIS_DIMS_AND_LEVELS_PKG.get_kpi_names(bl.level_id), '' ''),1,180) Kpi_names
FROM
    bis_levels_vl bl
  , ak_attributes_vl aa
  , bis_dimensions_vl bd
  '
  || l_dyn_table ||
  '
WHERE
     bl.attribute_code = aa.attribute_code
 AND bl.dimension_id = bd.dimension_id
 AND NVL(bd.hide_in_design, ''F'') <> ''T''
 AND NVL(bl.hide_in_design, ''F'') <> ''T''
'
|| l_where_clause
|| l_group_by
|| '
ORDER BY bl.name, bl.short_name, aa.attribute_label_long
     , bl.description, bl.source ' ;


    -- insert into tmp2 (seq, value) values (temp_seq.nextval, l_ret_string); commit;

    -- insert into tmp2 (seq, value) values (temp_seq.nextval, ' <*************** end ***************> '); commit;

	return l_ret_string;

END bis_levels_details_report;



FUNCTION bis_dimensions_report ( p_params IN BIS_PMV_PAGE_PARAMETER_TBL  )
RETURN VARCHAR2 IS

	l_ret_string 	 VARCHAR2(8000) := NULL;
	l_startdate  	 VARCHAR2(1000)  := NULL;
	l_enddate		 VARCHAR2(1000)  := NULL;
    l_pname      	 VARCHAR2(2000)  := NULL;
	l_pvalue     	 VARCHAR2(2000)  := NULL;
	l_name 		     VARCHAR(500)	:= NULL;
	l_developer 	 VARCHAR2(500)	:= NULL;
	l_lvl_sht_nm_filter VARCHAR2(1500)   := NULL;
	l_dim_nm_filter  VARCHAR2(1500)   := NULL;
	l_dim_sht_nm_filter    VARCHAR2(1500) := NULL;
	l_app_nm_filter  VARCHAR2(1500) := NULL;
	l_dim_desc_filter VARCHAR2(1500) := NULL;
	l_order_by       VARCHAR2(150)  := NULL;
	l_group_by       VARCHAR2(150)  := ' group by bd.name, bd.description, bd.short_name, bl.source ' ;
    l_source_filter   VARCHAR2(1500) := NULL;
	l_where_clause    VARCHAR2(1500)   := NULL;
	l_group_by        VARCHAR2(150) := ' GROUP BY bd.name, bl.name, bl.description, bl.level_values_view_name ';
	l_dyn_table	  VARCHAR2(50) := NULL;

BEGIN

 -- -- insert into tmp2 (seq, value) values (temp_seq.nextval, ' <*************** begin ***************> '); commit;

 FOR i IN 1..p_params.count LOOP

    l_pname  := p_params(i).parameter_name;
    l_pvalue := BIS_UTILITIES_PVT.filter_quotes(p_params(i).parameter_value);

	-- insert into tmp2 (seq, value) values (temp_seq.nextval, '(<---------------- pname ->'||l_pname||'<-pvalue->'||l_pvalue||'<------------------>)' ); commit;

	IF ( l_pname = 'DIMENSION_NAME' ) THEN

	  IF (l_pvalue <> 'All') THEN
	      l_dim_nm_filter := ' AND UPPER(bd.name) LIKE UPPER(''' || '%' || l_pvalue || '%' || ''' ) ' ;
	  END IF;

    ELSIF ( l_pname = 'APPLX+APPLX' ) THEN

	  IF (l_pvalue <> 'All') THEN
	    l_app_nm_filter := ' AND bd.application_id = f.application_id AND f.application_name = ''' || l_pvalue || ''' ' ;
	    l_dyn_table := ' , fnd_application_vl f ' ;
	  END IF;

    ELSIF ( l_pname = 'DIMENSION_DESCRIPTION' ) THEN

	  IF (l_pvalue <> 'All') THEN
	      l_dim_desc_filter := ' AND UPPER(bd.description) LIKE UPPER(''' || '%' || l_pvalue || '%' || ''' ) ' ;
	  END IF;

	ELSIF (l_pname LIKE '%ORDERBY%') THEN

	    -- Select * from tmp2 order by seq desc;

		-- l_order_by := ' WHERE ';

  	    IF ( l_pvalue LIKE '%NAME%DESKRIPTION%SHORT_NAME%' ) THEN
		  l_order_by := ' NAME ';
		ELSIF (l_pvalue LIKE '%SHORT_NAME%') THEN
		  l_order_by := ' SHORT_NAME ';
	    ELSIF (l_pvalue LIKE '%DESKRIPTION%') THEN
		  l_order_by := ' DESKRIPTION ';
	    ELSIF (l_pvalue LIKE '%NAME%') THEN
		  l_order_by := ' NAME ';
		END IF;

	    IF (l_pvalue LIKE '%DESC%') THEN
		  l_order_by := l_order_by || ' DESC ' ;
	    ELSE
		  IF (l_pvalue IS NOT NULL ) THEN
		    l_order_by := l_order_by || ' ' ;
		  END IF;
		END IF;

        -- insert into tmp2 (seq, value) values (temp_seq.nextval, ' l_order_by: ' || l_order_by ); commit;

	  END IF;
   END LOOP;

  l_where_clause := l_dim_nm_filter || l_app_nm_filter || l_dim_desc_filter ;


  -- decode (product_id, 163, ''BIS'', 205, ''BSC'')
  l_ret_string := '
SELECT
     SUBSTR(bd.name,1,180) Dimension_name1
	 , SUBSTR(NVL(bd.description, '' ''),1,180) Dimension_description1
	 , bd.short_name Dimension_short_name1
FROM bis_dimensions_vl bd
'
  || l_dyn_table ||
'
WHERE NVL(bd.hide_in_design, ''F'') <> ''T''
'
|| l_where_clause
|| '
ORDER BY bd.name, bd.description, bd.short_name
';


    -- insert into tmp2 (seq, value) values (temp_seq.nextval, l_ret_string); commit;

    -- insert into tmp2 (seq, value) values (temp_seq.nextval, ' <*************** end ***************> '); commit;

	return l_ret_string;

END bis_dimensions_report;


FUNCTION get_level_names ( kpi_id IN NUMBER )
RETURN VARCHAR2 IS

  l_lvl_names VARCHAR2(32000) := NULL;
  l_lvl_name  bis_levels_vl.name%TYPE;

  CURSOR cur_get_level_name IS
  SELECT name
  FROM bis_levels_vl bl
     , BIS_IND_TL_LVL_V bitlv
  WHERE bitlv.level_id = bl.level_id
    AND bitlv.indicator_id = kpi_id;

BEGIN

  IF cur_get_level_name%ISOPEN THEN
    CLOSE cur_get_level_name;
  END IF;

  FOR c_rec in cur_get_level_name LOOP
	l_lvl_name := c_rec.name;
    IF (l_lvl_names IS NULL) THEN
      l_lvl_names := l_lvl_name;
	ELSE
      l_lvl_names := l_lvl_names || ', ' || l_lvl_name;
	END IF;
  END LOOP;

  IF cur_get_level_name%ISOPEN THEN
    CLOSE cur_get_level_name;
  END IF;

  RETURN l_lvl_names;

EXCEPTION
  WHEN OTHERS THEN
	IF cur_get_level_name%ISOPEN THEN
      CLOSE cur_get_level_name;
    END IF;
	RETURN ' ';

END get_level_names;


FUNCTION get_kpi_names ( lvl_id IN NUMBER )
RETURN VARCHAR2 IS

  l_kpi_names VARCHAR2(32000) := NULL;
  l_kpi_name  bis_indicators_vl.name%TYPE;

  CURSOR cur_get_kpi_name IS
  SELECT DISTINCT name
  FROM bis_indicators_vl bi
     , BIS_IND_TL_LVL_V bitlv
  WHERE bitlv.indicator_id = bi.indicator_id
    AND bitlv.level_id = lvl_id;

BEGIN

  IF cur_get_kpi_name%ISOPEN THEN
    CLOSE cur_get_kpi_name;
  END IF;

  FOR c_rec in cur_get_kpi_name LOOP
	l_kpi_name := c_rec.name;
    IF (l_kpi_names IS NULL) THEN
      l_kpi_names := l_kpi_name;
	ELSE
      l_kpi_names := l_kpi_names || ', ' || l_kpi_name;
	END IF;
  END LOOP;

  IF cur_get_kpi_name%ISOPEN THEN
    CLOSE cur_get_kpi_name;
  END IF;

  RETURN l_kpi_names;

EXCEPTION
  WHEN OTHERS THEN
	IF cur_get_kpi_name%ISOPEN THEN
      CLOSE cur_get_kpi_name;
    END IF;
	RETURN ' ';

END get_kpi_names;


END BIS_DIMS_AND_LEVELS_PKG;

/
