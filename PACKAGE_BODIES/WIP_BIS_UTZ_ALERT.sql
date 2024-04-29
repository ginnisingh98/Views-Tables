--------------------------------------------------------
--  DDL for Package Body WIP_BIS_UTZ_ALERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_BIS_UTZ_ALERT" AS
/* $Header: wipbiuab.pls 115.22 2004/04/14 13:49:49 achandak ship $ */

/*
 * PostActual
 *   Called by Alert_Check to post actuals to the BIS table.
 *   The posting is done by calling BIS API (BIS_ACTUAL_PUB).
 */
PROCEDURE PostActual( target_level_id        in number,
                      time_level_value       in varchar2,
                      org_level_value        in varchar2,
                      dimension1_level_value in varchar2,
                      dimension2_level_value in varchar2,
                      actual                 in number,
                      period_set_name        in varchar2) IS
  actual_rec BIS_ACTUAL_PUB.Actual_Rec_Type;
  x_return_status VARCHAR2(30);
  x_msg_count     NUMBER;
  x_msg_data      VARCHAR2(30);
  x_error_Tbl     BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  actual_rec.Target_Level_ID := target_level_id;
  if (period_set_name is not NULL) then
      actual_rec.Time_Level_Value_ID := period_set_name || '+' ||
                                        time_level_value;
  end if;
  actual_rec.Org_Level_value_ID := org_level_value;
  actual_rec.Dim1_Level_Value_ID := dimension1_level_value;
  actual_rec.Dim2_Level_Value_ID := dimension2_level_value;
  actual_rec.Actual := actual;

  BIS_ACTUAL_PUB.Post_Actual( p_api_version => 1.0,
                              p_commit => FND_API.G_TRUE,
                              p_Actual_Rec => actual_rec,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              x_error_Tbl => x_error_Tbl);

END PostActual;


/*
 * PostLevelActuals
 *   Will post all actuals for the given dimension level combination.
 *   The dimension level should be 0 for ALL, and increasing for
 *   finer levels.
 *   e.g.
 *     time_level = 0 : TOTAL_TIME
 *     time_level = 1 : YEAR
 *     time_level = 2 : QUARTER
 *     time_level = 3 : MONTH
 */
PROCEDURE PostLevelActuals( target_level_id  in number,
                            time_level       in number,
                            org_level        in number,
                            dimension1_level in number,
                            dimension2_level in number) IS

  /* the values retrieved */
  v_actual            NUMBER;
  v_time              VARCHAR2(80);
  v_period_setname    VARCHAR2(80);
  v_org               VARCHAR2(80);
  v_geography         VARCHAR2(80);
  v_product           VARCHAR2(80);


  /* SELECT clause */
  p_select_time            VARCHAR2(1000) := 'to_char(NULL) ';
  p_select_period_setname  VARCHAR2(1000) := 'to_char(NULL) ';
  p_select_org             VARCHAR2(1000) := 'to_char(NULL) ';
  p_select_geo             VARCHAR2(1000) := 'to_char(NULL) ';
  p_select_product         VARCHAR2(1000) := 'to_char(NULL) ';

  /* FROM clause */
  p_from              VARCHAR2(1000) := 'WIP_BIS_UTZ_NOCAT_V ';

  /* GROUP BY clause */
  p_groupby_time      VARCHAR2(1000) := 'to_char(NULL) ';
  p_groupby_org       VARCHAR2(1000) := 'to_char(NULL) ';
  p_groupby_geo       VARCHAR2(1000) := 'to_char(NULL) ';
  p_groupby_product   VARCHAR2(1000) := 'to_char(NULL) ';


  /* dynamic SQL stuff */
  cursor_id          INTEGER;
  ignore             INTEGER;
  p_select_statement VARCHAR2(32767);

BEGIN

  /* TIME */

  if time_level = 1 then
    p_select_time  := 'TEMP.period_year ';
    p_select_period_setname := 'TEMP.period_set_name';
  elsif time_level = 2 then
    p_select_time  := 'TEMP.period_quarter ';
    p_select_period_setname := 'TEMP.period_set_name';
  elsif time_level = 3 then
    p_select_time  := 'TEMP.period_month ';
    p_select_period_setname := 'TEMP.period_set_name';
  end if;
  p_groupby_time := p_select_time || ', ' || p_select_period_setname;



  /* ORGANIZATION */

  if org_level = 1 then
    p_select_org      := 'TEMP.set_of_books_id ';
  elsif org_level = 2 then
    p_select_org      := 'TEMP.legal_entity_id ';
  elsif org_level = 3 then
    p_select_org      := 'TEMP.operating_unit_id ';
  elsif org_level = 4 then
    p_select_org      := 'TEMP.organization_id ';
  end if;
  p_groupby_org := p_select_org;


  /* GEOGRAPHY */

  if dimension1_level = 2 then
    p_select_geo := 'TEMP.area_code ';
    p_groupby_geo := p_select_geo;
  elsif dimension1_level = 3 then
    p_select_geo := 'TEMP.area_code || ''+'' ' ||
                    '|| TEMP.country_code ';
    p_groupby_geo := 'TEMP.area_code, TEMP.country_code ';
/* James 7/8/99 */
  elsif dimension1_level = 4 THEN
    p_select_geo := 'TEMP.area_code || ''+'' ' ||
                    '|| TEMP.country_code || ''+'' || TEMP.region_code ';
    p_groupby_geo := 'TEMP.area_code, TEMP.country_code, TEMP.region_code ';
/* end James */
  end if;


  /* PRODUCT */

  if dimension2_level = 2 then
    p_select_product       := 'TEMP.category_id ';
    p_from                 := 'wip_bis_utz_catnoitem_v';
  elsif dimension2_level = 3 then
    p_select_product       := 'TEMP.inventory_item_id ';
    p_from                 := 'wip_bis_utz_cat_v';
  end if;
  p_groupby_product      := p_select_product;


  cursor_id := DBMS_SQL.OPEN_CURSOR;

  -- No literals to change to bind variables as per coding standard.
  p_select_statement :=
    'select ' ||
       p_select_time            || ', ' ||
       p_select_period_setname  || ', ' ||
       p_select_org             || ', ' ||
       p_select_geo             || ', ' ||
       p_select_product         || ', ' ||
    '  (decode(sum(TEMP.available_hours), 0, 0, ' ||
    '         sum(TEMP.actual_hours)/sum(TEMP.available_hours))*100) ' ||
    'from ' ||
       p_from || ' TEMP ' ||
    'group by ' ||
       p_groupby_time      || ', ' ||
       p_groupby_org       || ', ' ||
       p_groupby_geo       || ', ' ||
       p_groupby_product;

  DBMS_SQL.PARSE( cursor_id, p_select_statement, DBMS_SQL.V7 );

  DBMS_SQL.DEFINE_COLUMN( cursor_id, 1, v_time           , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 2, v_period_setname , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 3, v_org            , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 4, v_geography      , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 5, v_product        , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 6, v_actual              );
  ignore := DBMS_SQL.EXECUTE( cursor_id );


  LOOP
    IF DBMS_SQL.FETCH_ROWS( cursor_id ) > 0 THEN
      DBMS_SQL.COLUMN_VALUE( cursor_id, 1, v_time           );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 2, v_period_setname );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 3, v_org            );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 4, v_geography      );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 5, v_product        );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 6, v_actual         );

      WIP_BIS_UTZ_ALERT.PostActual(
        target_level_id,
        v_time,
        v_org,
        v_geography,
        v_product,
        v_actual,
        v_period_setname );

    ELSE
      EXIT;
    END IF;

  END LOOP;

  DBMS_SQL.CLOSE_CURSOR(cursor_id);

END PostLevelActuals;


/*
 * StartFlow
 *  Start the workflow by calling WIP_Strt_Wf_Process.
 *  It will setup the notification messages for the attributes.
 */
PROCEDURE StartFlow( time_level_value       in varchar2,
                     start_date             in date,
                     end_date               in date,
                     org_level_value        in varchar2,
                     dimension1_level_value in varchar2,
                     dimension2_level_value in varchar2,
                     prod_id                in number,
                     sob                    in varchar2,
                     le                     in varchar2,
                     ou                     in varchar2,
                     org                    in varchar2,
                     area                   in varchar2,
                     country                in varchar2,
             country_id             IN VARCHAR2, /* James 7/12/99 */
             region                 IN VARCHAR2, /* James 7/12/99 */
                     prod                   in varchar2,
                     item                   in varchar2,
                     actual                 in number,
                     target                 in number,
                     plan_id                in number,
                     plan_name              in varchar2,
                     wf                     in varchar2,
                     resp_id                in number,
                     resp_name              in varchar2,
                     org_level              in number,
                     dimension1_level       in number,
                     dimension2_level       in number) IS

  l_subject          VARCHAR2(240);
  l_sob              VARCHAR2(240);
  l_le               VARCHAR2(240);
  l_ou               VARCHAR2(240);
  l_org              VARCHAR2(240);
  l_area             VARCHAR2(240);
  l_country          VARCHAR2(240);
  l_region           VARCHAR2(240);  /* James 7/8/99 */
  l_prod_cat         VARCHAR2(240);
  l_prod             VARCHAR2(240);
  l_period           VARCHAR2(240);
  l_actual           VARCHAR2(240);
  l_target           VARCHAR2(240);
  status             Varchar2(30);
  l_param            varchar2(2000);

  l_org_level        VARCHAR2(100);
  l_sob_id           VARCHAR2(100) := NULL;
  l_le_id            VARCHAR2(100) := NULL;
  l_ou_id            VARCHAR2(100) := NULL;
  l_org_id           VARCHAR2(100) := NULL;
  l_geo_level        VARCHAR2(100);
  l_area_id          VARCHAR2(100) := NULL;
  l_country_id       VARCHAR2(100) := NULL;
  l_region_id        VARCHAR2(100) := NULL;
  l_prod_level       VARCHAR2(100);
  l_pg_id            VARCHAR2(100) := NULL;
  l_item_id          VARCHAR2(100) := NULL;

  l_unassigned       VARCHAR2(100) :=
    fnd_message.get_string('BOM', 'CST_UNASSIGNED_LABEL');

BEGIN

    l_subject := fnd_message.get_string('WIP', 'RESOURCE_UTILIZATION') ||
                 ' ' || fnd_message.get_string('WIP', 'WIP_ALERT');
    l_sob := fnd_message.get_string('WIP', 'SET_OF_BOOKS') || ': ' || sob;
    l_le := fnd_message.get_string('WIP', 'WIP_LEGAL_ENTITY') || ': ' || le;
    l_ou := fnd_message.get_string('BOM', 'CST_OPERATING_UNIT_LABEL') ||
           ': ' || ou;
    l_org := fnd_message.get_string('WIP', 'INVENTORY_ORGANIZATION') ||
           ': ' || org;
    l_area := fnd_message.get_string('BOM', 'CST_AREA_LABEL') || ': ' || area;
    l_country := fnd_message.get_string('BOM', 'CST_COUNTRY_LABEL') ||
           ': ' || country;
/* James 7/8/99 */
    l_region := fnd_message.get_string('BOM', 'CST_REGION_LABEL') ||
           ': ' || region;
/* end James */
    l_prod_cat := fnd_message.get_string('WIP', 'WIP_PROD_CATEGORY')
           || ': ' || prod;
    l_prod := fnd_message.get_string('BOM', 'ITEM_CAP') ||
           ': ' || item;
    l_period := fnd_message.get_string('WIP', 'WIP_PERIOD')
           || ': ' || time_level_value;
    l_actual := fnd_message.get_string('WIP', 'WIP_ACTUAL')
                             || ': ' || round(actual, 2);
    l_target := fnd_message.get_string('WIP', 'WIP_TARGET')
                             || ': ' || round(target, 2);

    IF(org_level = 1) /* SOB */ THEN
       l_org_level := 'SET OF BOOKS';
    END IF;
    IF(org_level >= 1) THEN
       SELECT MAX(set_of_books_id) INTO l_sob_id
     FROM gl_sets_of_books
     WHERE name = sob;
    END IF;
    IF(org_level = 2) /* LE */ THEN
       l_org_level := 'LEGAL ENTITY';
    END IF;
    IF(org_level >= 2) THEN
       SELECT MAX(organization_id) INTO l_le_id
     FROM hr_legal_entities
     WHERE name = le;
    END IF;
    IF(org_level = 3) /* OU */ THEN
       l_org_level := 'OPERATING UNIT';
    END IF;
    IF(org_level >= 3) THEN
       SELECT MAX(organization_id) INTO l_ou_id
     FROM hr_operating_units
     WHERE name = ou;
    END IF;
    IF(org_level = 4) THEN
       l_org_level := 'ORGANIZATION';
       SELECT MAX(organization_id) INTO l_org_id
     FROM org_organization_definitions
     WHERE organization_name = org;
    END IF;

    IF(dimension1_level = 1) /* TOTAL GEOGRAPHY */ THEN
       l_geo_level := 'TOTAL GEOGRAPHY';
    END IF;
    IF(dimension1_level = 2) /* AREA */ THEN
       l_geo_level := 'AREA';
    END IF;
    IF(dimension1_level >= 2) THEN
       SELECT MAX(id) INTO l_area_id
     FROM bis_areas_v
     WHERE name = area;
    END IF;
    IF(dimension1_level = 3) /* COUNTRY */ THEN
       l_geo_level := 'COUNTRY';
    END IF;
    IF(dimension1_level >= 3) THEN
       l_country_id := country_id;
    END IF;
    IF(dimension1_level = 4) /* REGION */ THEN
       l_geo_level := 'REGION';
    END IF;
    IF(dimension1_level >= 4) THEN
       SELECT MAX(region_code) INTO l_region_id
     FROM bis_regions_v
     WHERE area_code = l_area_id AND country_code = l_country_id
     AND name = region;
    END IF;

    IF(dimension2_level = 1) /* TOTAL PRODUCTS */ THEN
       l_prod_level := 'TOTAL PRODUCTS';
    END IF;
    IF(dimension2_level = 2) /* PRODUCT GROUP */ THEN
       l_prod_level := 'PRODUCT GROUP';
    END IF;
    IF(dimension2_level >= 2) THEN
       l_pg_id := To_char(prod_id);
    END IF;
    IF(dimension2_level = 3) /* ITEM */ THEN
       l_prod_level := 'ITEM';
    END IF;
    IF(dimension2_level >= 3) THEN
       SELECT MAX(inventory_item_id) INTO l_item_id
     FROM wip_bis_utz_cat_v
     WHERE category_name = prod AND inventory_item_name = item;
    END IF;

    l_param := 'P_PARAM_FROM_DATE=' ||
      to_char(start_date, 'DD-MON-YYYY') ||
      '*P_PARAM_TO_DATE=' ||
      to_char(end_date, 'DD-MON-YYYY') ||
      '*P_PARAM_ORG_LEVEL='  ||
      REPLACE(l_org_level, ' ', '%20')    ||
      '*P_PARAM_SOB_ID='     || l_sob_id     ||
      '*P_PARAM_LE_ID='      || l_le_id      ||
      '*P_PARAM_OU_ID='      || l_ou_id      ||
      '*P_PARAM_ORG_ID='     || l_org_id     ||
      '*P_PARAM_GEO_LEVEL='  ||
      REPLACE(l_geo_level, ' ', '%20')    ||
      '*P_PARAM_AREA_ID='    || l_area_id    ||
      '*P_PARAM_COUNTRY_ID=' || l_country_id ||
      '*P_PARAM_REGION_ID='  || l_region_id  ||
      '*P_PARAM_PROD_LEVEL=' ||
      REPLACE(l_prod_level, ' ', '%20')   ||
      '*P_PARAM_PG_ID='      || l_pg_id      ||
      '*P_PARAM_ITEM_ID='    || l_item_id    ||
      '*P_PARAM_PLAN_ID='    || plan_id      ||
      '*P_PARAM_VIEW_BY=TIME' ||
      '*paramform=NO*';

    WIP_Strt_Wf_Process(
        p_subject => l_subject,
        p_sob => l_sob,
        p_le => l_le,
        p_ou => l_ou,
        p_org => l_org,
        p_area => l_area,
    p_country => l_country,
    p_region => l_region,
        p_prod_cat => l_prod_cat,
        p_prod => l_prod,
        p_period => l_period,
        p_target => l_target,
        p_actual => l_actual,
--        p_wf_process => 'WIP_UTZ_SEND_NOTIFICATION',
        p_wf_process => wf,
--        p_role => 'DEVELOPER',
        p_role => resp_name,
--        p_resp_id => 52344,
        p_resp_id => resp_id,
        p_report_name => 'WIPBIUTZ',
        p_report_param => l_param,
        x_return_status => status);

END StartFlow;


/*
 * CompareLevelTarget
 *   Called by Alert_Check which
 *   compares all actuals against all targets defined for the
 *   given dimension level combination.
 *   This routine will be called with every combination of
 *   the 4 dimensions.
 *
 *   Based on the range values (high/low) defined in the PMF,
 *   StartFlow will be called to start the workflow.
 */
PROCEDURE CompareLevelTarget( target_level_id in number,
                              time_level in number,
                              org_level in number,
                              dimension1_level in number,
                              dimension2_level in number) IS
  /* the values retrieved */
  v_wf                VARCHAR2(80);
  v_plan_id           NUMBER;
  v_plan_name         VARCHAR2(80);
  v_range1_low        NUMBER;
  v_range1_high       NUMBER;
  v_range2_low        NUMBER;
  v_range2_high       NUMBER;
  v_range3_low        NUMBER;
  v_range3_high       NUMBER;
  v_resp1_id          NUMBER;
  v_resp2_id          NUMBER;
  v_resp3_id          NUMBER;
  v_resp1_name        VARCHAR2(100);
  v_resp2_name        VARCHAR2(100);
  v_resp3_name        VARCHAR2(100);
  v_target            NUMBER;
  v_actual            NUMBER;
  v_time              VARCHAR2(80);
  v_org               VARCHAR2(80);
  v_geography         VARCHAR2(80);
  v_product           VARCHAR2(80);
  v_prod_id           NUMBER;
  v_sob_name          VARCHAR2(80);
  v_le_name           VARCHAR2(80);
  v_ou_name           VARCHAR2(80);
  v_org_name          HR_ALL_ORGANIZATION_UNITS.NAME%TYPE;
  v_area_name         VARCHAR2(80);
  v_country_name      VARCHAR2(80);
  v_prod_name         VARCHAR2(80);
  v_item_name         VARCHAR2(80);
  v_start_date        DATE;
  v_end_date          DATE;
  v_region_name       VARCHAR2(80);  /* James 7/9/99 */
  v_country_id        VARCHAR2(80);  /* James 7/12/99 */
  all_text            VARCHAR2(240);


  /* SELECT clause */
  p_select_time            VARCHAR2(1000) := '-1 ';
  p_select_start_date      VARCHAR2(1000) := 'to_date(NULL) ';
  p_select_end_date        VARCHAR2(1000) := 'to_date(NULL) ';
  p_select_org             VARCHAR2(1000) := '-1 ';
  p_select_geo             VARCHAR2(1000) := '-1 ';
  p_select_product         VARCHAR2(1000) := '-1 ';
  p_select_prod_id         VARCHAR2(1000) := 'to_number(NULL) ';
  p_select_sob_name        VARCHAR2(1000) ;
  p_select_le_name         VARCHAR2(1000) ;
  p_select_ou_name         VARCHAR2(1000) ;
  p_select_org_name        VARCHAR2(1000) ;
  p_select_area_name       VARCHAR2(1000) ;
  p_select_country_name    VARCHAR2(1000) ;
  p_select_country_id      VARCHAR2(1000) := 'to_char(NULL) ';
  p_select_prod_name       VARCHAR2(1000) ;
  p_select_item_name       VARCHAR2(1000) ;
/* James 7/9/99 */
  p_select_region_name     VARCHAR2(1000) ;
/* end James */

  /* FROM clause */
  p_from              VARCHAR2(1000) := 'WIP_BIS_UTZ_NOCAT_V ';
  p_from_time         VARCHAR2(1000) := 'sys.dual ';

  /* WHERE for target clause */
  p_where_trgt_time   VARCHAR2(1000) := 'and 1=1 ';
  p_where_trgt_org    VARCHAR2(1000) := 'and 1=1 ';
  p_where_trgt_geo    VARCHAR2(1000) := 'and 1=1 ';
  p_where_trgt_prod   VARCHAR2(1000) := 'and 1=1 ';

  /* GROUP BY clause */
  p_groupby_time      VARCHAR2(1000) := '-1 ';
  p_groupby_org       VARCHAR2(1000) := '-1 ';
  p_groupby_geo       VARCHAR2(1000) := '-1 ';
  p_groupby_product   VARCHAR2(1000) := '-1 ';

  /* CONTEXT for target level */
  p_context_time      VARCHAR2(100) := 'TOTAL_TIME';
  p_context_org       VARCHAR2(100) := 'SET OF BOOKS';
  p_context_prod      VARCHAR2(100) := 'TOTAL_PRODUCT';
  p_context_geo       VARCHAR2(100) := 'TOTAL_GEOGRAPHY';

  /* dynamic SQL stuff */
  cursor_id          INTEGER;
  ignore             INTEGER;
  p_select_statement VARCHAR2(32767);

  l_resp_id          NUMBER;
  l_resp_name        VARCHAR2(100);
BEGIN

  /* initialize all text */
  all_text := '''' || FND_MESSAGE.get_string('WIP', 'WIP_ALL') || '''';

  p_select_sob_name := all_text;
  p_select_le_name := all_text;
  p_select_ou_name  := all_text;
  p_select_org_name  := all_text;
  p_select_area_name := all_text;
  p_select_country_name := all_text;
  p_select_prod_name := all_text;
  p_select_item_name := all_text;
  p_select_region_name := all_text;

  /* TIME */

  if time_level = 0 then        /* we do not checking total time for target */
    return;
  end if;

  if time_level = 1 then
    p_from_time := 'gl_periods ';
    p_select_start_date := 'gl_p.start_date '; -- Bug 3554853
    p_select_end_date := 'gl_p.end_date '; -- Bug 3554853
    p_select_time  := 'TEMP.period_year ';
    p_context_time := 'YEAR';
    p_where_trgt_time := 'and gl_p.period_set_name = TEMP.period_set_name ' || -- Bug 3554853
          'and gl_p.period_name = TEMP.period_year ' || -- Bug 3554853
          'and gl_p.start_date = (select max(gl_p.start_date) from gl_periods ' || -- Bug 3554853
                            'where period_set_name = TEMP.period_set_name ' ||
                            '  and period_type = ''Year'') ';
  elsif time_level = 2 then
    p_from_time := 'gl_periods ';
    p_select_start_date := 'gl_p.start_date '; -- Bug 3554853
    p_select_end_date := 'gl_p.end_date '; -- Bug 3554853
    p_select_time  := 'TEMP.period_quarter ';
    p_context_time := 'QUARTER';
    p_where_trgt_time := 'and gl_p.period_set_name = TEMP.period_set_name ' || -- Bug 3554853
        'and gl_p.period_name = TEMP.period_quarter ' || -- Bug 3554853
        'and gl_p.start_date = (select max(gl_p.start_date) from gl_periods ' || -- Bug 3554853
                              'where period_set_name = TEMP.period_set_name ' ||
                              '  and period_type = ''Quarter'') ';
  elsif time_level = 3 then
    p_from_time := 'gl_periods ';
    p_select_start_date := 'gl_p.start_date '; -- Bug 3554853
    p_select_end_date := 'gl_p.end_date '; -- Bug 3554853
    p_select_time  := 'TEMP.period_month ';
    p_context_time := 'MONTH';
    p_where_trgt_time := 'and gl_p.period_set_name = TEMP.period_set_name ' || -- Bug 3554853
       'and gl_p.period_name = TEMP.period_month ' || -- Bug 3554853
       'and gl_p.start_date = ' ||  -- Bug 3554853
       ' (select max(gl_p.start_date) ' ||  -- Bug 3554853
       '  from gl_periods p, gl_sets_of_books sob ' ||
       ' where p.period_set_name = TEMP.period_set_name ' ||
       '   and sob.SET_OF_BOOKS_ID = TEMP.set_of_books_id ' ||
       '   and p.period_type = sob.ACCOUNTED_PERIOD_TYPE) ';
  end if;
  p_groupby_time := p_select_time || ', ' || p_select_start_date ||
                    ', ' ||  p_select_end_date;



  /* ORGANIZATION */

  if org_level = 1 then
    p_select_org  := 'TEMP.set_of_books_id ';
    p_select_sob_name := 'TEMP.set_of_books_name';
    p_context_org := 'SET OF BOOKS';
    p_where_trgt_org := 'and trgt.org_level_value_id = to_char(TEMP.set_of_books_id) ';
  elsif org_level = 2 then
    p_select_org  := 'TEMP.legal_entity_id ';
    p_select_sob_name := 'TEMP.set_of_books_name';
    p_select_le_name := 'TEMP.legal_entity_name';
    p_context_org := 'LEGAL ENTITY';
    p_where_trgt_org := 'and trgt.org_level_value_id = to_char(TEMP.legal_entity_id) ';
  elsif org_level = 3 then
    p_select_org  := 'TEMP.operating_unit_id ';
    p_select_sob_name := 'TEMP.set_of_books_name';
    p_select_le_name := 'TEMP.legal_entity_name';
    p_select_ou_name := 'TEMP.operating_unit_name';
    p_context_org := 'OPERATING UNIT';
    p_where_trgt_org := 'and trgt.org_level_value_id = to_char(TEMP.operating_unit_id) ';
  elsif org_level = 4 then
    p_select_org  := 'TEMP.organization_id ';
    p_select_sob_name := 'TEMP.set_of_books_name';
    p_select_le_name := 'TEMP.legal_entity_name';
    p_select_ou_name := 'TEMP.operating_unit_name';
    p_select_org_name := 'TEMP.organization_name';
    p_context_org := 'ORGANIZATION';
    p_where_trgt_org := 'and trgt.org_level_value_id = to_char(TEMP.organization_id) ';
  end if;

  /* GEOGRAPHY */

  if dimension1_level = 2 then    /* area */
      p_select_geo := 'TEMP.area_code ';
      p_select_area_name := 'TEMP.area_name ';
      p_context_geo := 'AREA';
      p_where_trgt_geo := 'and trgt.dim1_level_value_id = ' ||
                          'TEMP.area_code ';
      p_groupby_geo := p_select_geo || ', ' || p_select_area_name;
  elsif dimension1_level = 3 then     /* country */
      p_select_geo := 'TEMP.country_code ' ;
      p_select_area_name := 'TEMP.area_name ';
      p_select_country_name := 'TEMP.country_name ';
      p_context_geo := 'COUNTRY';
      p_where_trgt_geo := 'and WIP_BIS_COMMON.get_segment(trgt.dim1_level_value_id, ''+'',' ||
                          ' 1) = TEMP.country_code ';
      p_groupby_geo := p_select_area_name || ', ' ||
                       p_select_geo || ', ' ||
                   p_select_country_name;
/* James 7/9/99 */
   ELSIF dimension1_level = 4 THEN  /* region */
     p_select_geo := 'TEMP.region_code ';
      p_select_area_name := 'TEMP.area_name ';
      p_select_country_name := 'TEMP.country_name ';
      p_select_country_id := 'TEMP.country_code ';
      p_select_region_name := 'TEMP.region_name ';
      p_context_geo := 'REGION';
      p_where_trgt_geo := 'and WIP_BIS_COMMON.get_segment(
    trgt.dim1_level_value_id, ''+'',' || ' 1) = TEMP.country_code ' ||
    'and WIP_BIS_COMMON.get_segment(
    trgt.dim1_level_value_id, ''+'',' || ' 2) = TEMP.region_code ';
      p_groupby_geo := p_select_area_name || ', ' ||
                       p_select_geo || ', ' ||
                   p_select_country_name || ', ' ||
                   p_select_country_id || ', ' || -- Added for bug 3570060
                   p_select_region_name;
/* end James */

  end if;


  /* PRODUCT */

  if dimension2_level = 2 then  /* prod cat */
    p_select_product := 'TEMP.category_id ';
    p_select_prod_name := 'TEMP.category_name ';
    p_groupby_product := 'TEMP.category_id, TEMP.category_name';
    p_from := 'wip_bis_utz_catnoitem_v';
    p_context_prod := 'PRODUCT GROUP';
    p_where_trgt_prod := 'and trgt.dim2_level_value_id = to_char(TEMP.category_id) ';
  elsif dimension2_level = 3 then  /* item */
    p_select_product  := 'TEMP.inventory_item_id ';
    p_select_prod_id := 'TEMP.category_id ';
    p_select_prod_name := 'TEMP.category_name ';
    p_select_item_name := 'TEMP.inventory_item_name ';
    p_groupby_product := 'TEMP.category_id, TEMP.inventory_item_id, ' ||
                         'TEMP.category_name, TEMP.inventory_item_name';
    p_from := 'wip_bis_utz_cat_v';
    p_context_prod := 'ITEM';
    p_where_trgt_prod := 'and trgt.dim2_level_value_id = to_char(TEMP.inventory_item_id) ';
  end if;


  cursor_id := DBMS_SQL.OPEN_CURSOR;

  -- Changing literals to bind variables as per coding standard.
  p_select_statement :=
    'select ' ||
       p_select_time            || ', ' ||
       p_select_org             || ', ' ||
       p_select_geo             || ', ' ||
       p_select_product         || ', ' ||
       p_select_prod_id         || ', ' ||
       p_select_sob_name        || ', ' ||
       p_select_le_name         || ', ' ||
       p_select_ou_name         || ', ' ||
       p_select_org_name        || ', ' ||
       p_select_area_name       || ', ' ||
       p_select_country_name    || ', ' ||
       p_select_prod_name       || ', ' ||
       p_select_item_name       || ', ' ||
    '  (decode(sum(TEMP.available_hours), 0, 0, ' ||
    '        sum(TEMP.actual_hours)/sum(TEMP.available_hours))*100), ' ||
    '  trgt.target, ' ||
    '  bbp.plan_id, ' ||
    '  bbp.name, ' ||
    '  btl.workflow_process_short_name, ' ||
    '  min(trgt.range1_low), ' ||
    '  min(trgt.range1_high), ' ||
    '  min(trgt.range2_low), ' ||
    '  min(trgt.range2_high), ' ||
    '  min(trgt.range3_low), ' ||
    '  min(trgt.range3_high), ' ||
    '  min(trgt.notify_resp1_id), ' ||
    '  min(trgt.notify_resp2_id), ' ||
    '  min(trgt.notify_resp3_id), ' ||
    '  min(trgt.notify_resp1_short_name), ' ||
    '  min(trgt.notify_resp2_short_name), ' ||
    '  min(trgt.notify_resp3_short_name), ' ||
       p_select_start_date       || ', ' ||
       p_select_end_date         || ', ' ||
       p_select_region_name      || ', ' || /* James */
       p_select_country_id       ||  /* James */

    'from ' ||
    '    bisbv_business_plans bbp, ' ||
    '    bisbv_targets trgt, ' ||
    '    bisbv_target_levels btl, ' ||
         p_from_time || ' gl_p, ' || -- Bug 3554853
         p_from || ' TEMP ' ||
    'where btl.target_level_id = ' || ':target_level_id' ||
    '  and trgt.target_level_id = btl.target_level_id ' ||
    '  and bbp.plan_id = trgt.plan_id ' ||
       p_where_trgt_time || ' ' ||
       p_where_trgt_org  || ' ' ||
       p_where_trgt_geo  || ' ' ||
       p_where_trgt_prod || ' ' ||
    'group by ' ||
       p_groupby_time      || ', ' ||
       p_select_org        || ', ' ||
       p_select_sob_name   || ', ' ||
       p_select_le_name    || ', ' ||
       p_select_ou_name    || ', ' ||
       p_select_org_name   || ', ' ||
       p_groupby_org       || ', ' ||
       p_groupby_geo       || ', ' ||
       p_groupby_product   || ', ' ||
       'trgt.target, bbp.plan_id, bbp.name, ' ||
       'btl.workflow_process_short_name ';

  DBMS_SQL.PARSE( cursor_id, p_select_statement, DBMS_SQL.V7 );

  DBMS_SQL.BIND_VARIABLE (cursor_id, ':target_level_id', target_level_id);

  DBMS_SQL.DEFINE_COLUMN( cursor_id,  1, v_time         , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id,  2, v_org          , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id,  3, v_geography    , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id,  4, v_product      , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id,  5, v_prod_id           );
  DBMS_SQL.DEFINE_COLUMN( cursor_id,  6, v_sob_name     , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id,  7, v_le_name      , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id,  8, v_ou_name      , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id,  9, v_org_name     , 240 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 10, v_area_name    , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 11, v_country_name , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 12, v_prod_name    , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 13, v_item_name    , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 14, v_actual            );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 15, v_target            );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 16, v_plan_id           );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 17, v_plan_name    , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 18, v_wf           , 80 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 19, v_range1_low        );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 20, v_range1_high       );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 21, v_range2_low        );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 22, v_range2_high       );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 23, v_range3_low        );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 24, v_range3_high       );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 25, v_resp1_id          );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 26, v_resp2_id          );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 27, v_resp3_id          );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 28, v_resp1_name  , 100 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 29, v_resp2_name  , 100 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 30, v_resp3_name  , 100 );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 31, v_start_date        );
  DBMS_SQL.DEFINE_COLUMN( cursor_id, 32, v_end_date          );
  dbms_sql.define_column( cursor_id, 33, v_region_name  , 80 ); /* James */
  dbms_sql.define_column( cursor_id, 34, v_country_id   , 80 ); /* James */
  ignore := DBMS_SQL.EXECUTE( cursor_id );


  LOOP
    IF DBMS_SQL.FETCH_ROWS( cursor_id ) > 0 THEN
      DBMS_SQL.COLUMN_VALUE( cursor_id,  1, v_time          );
      DBMS_SQL.COLUMN_VALUE( cursor_id,  2, v_org           );
      DBMS_SQL.COLUMN_VALUE( cursor_id,  3, v_geography     );
      DBMS_SQL.COLUMN_VALUE( cursor_id,  4, v_product       );
      DBMS_SQL.COLUMN_VALUE( cursor_id,  5, v_prod_id       );
      DBMS_SQL.COLUMN_VALUE( cursor_id,  6, v_sob_name      );
      DBMS_SQL.COLUMN_VALUE( cursor_id,  7, v_le_name       );
      DBMS_SQL.COLUMN_VALUE( cursor_id,  8, v_ou_name       );
      DBMS_SQL.COLUMN_VALUE( cursor_id,  9, v_org_name      );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 10, v_area_name     );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 11, v_country_name  );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 12, v_prod_name     );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 13, v_item_name     );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 14, v_actual        );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 15, v_target        );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 16, v_plan_id       );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 17, v_plan_name     );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 18, v_wf            );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 19, v_range1_low    );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 20, v_range1_high   );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 21, v_range2_low    );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 22, v_range2_high   );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 23, v_range3_low    );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 24, v_range3_high   );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 25, v_resp1_id      );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 26, v_resp2_id      );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 27, v_resp3_id      );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 28, v_resp1_name    );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 29, v_resp2_name    );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 30, v_resp3_name    );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 31, v_start_date    );
      DBMS_SQL.COLUMN_VALUE( cursor_id, 32, v_end_date      );
      dbms_sql.column_value( cursor_id, 33, v_region_name   ); /* James */
      dbms_sql.column_value( cursor_id, 34, v_country_id    ); /* James */

/* James 7/12/99 debugging */
      /*INSERT INTO my_alert_test
    VALUES(v_actual, v_target, v_range1_low, v_range1_high, v_range2_low,
           v_range2_high, v_range3_low, v_range3_high, v_time, v_org,
           v_geography, v_product);*/
/* end James debugging */


      /* do the range checking */
      if ( v_actual < v_target*(1-(v_range1_low/100)) OR
           v_actual > v_target*(1+(v_range1_high/100)) ) then
          WIP_BIS_UTZ_ALERT.StartFlow(
            v_time, v_start_date, v_end_date,
            v_org, v_geography, v_product, v_prod_id,
            v_sob_name, v_le_name, v_ou_name, v_org_name,
            v_area_name, v_country_name, v_country_id, v_region_name,
            v_prod_name, v_item_name,
            v_actual, v_target,
            v_plan_id, v_plan_name, v_wf,
            v_resp1_id, v_resp1_name,
            org_level, dimension1_level, dimension2_level);
      end if;

      if ( v_actual < v_target*(1-(v_range2_low/100)) OR
           v_actual > v_target*(1+(v_range2_high/100)) ) then
          WIP_BIS_UTZ_ALERT.StartFlow(
            v_time, v_start_date, v_end_date,
            v_org, v_geography, v_product, v_prod_id,
            v_sob_name, v_le_name, v_ou_name, v_org_name,
            v_area_name, v_country_name, v_country_id, v_region_name,
            v_prod_name, v_item_name,
            v_actual, v_target,
            v_plan_id, v_plan_name, v_wf,
            v_resp2_id, v_resp2_name,
            org_level, dimension1_level, dimension2_level);
      end if;

      if ( v_actual < v_target*(1-(v_range3_low/100)) OR
           v_actual > v_target*(1+(v_range3_high/100)) ) then
          WIP_BIS_UTZ_ALERT.StartFlow(
            v_time, v_start_date, v_end_date,
            v_org, v_geography, v_product, v_prod_id,
            v_sob_name, v_le_name, v_ou_name, v_org_name,
            v_area_name, v_country_name, v_country_id, v_region_name,
            v_prod_name, v_item_name,
            v_actual, v_target,
            v_plan_id, v_plan_name, v_wf,
            v_resp3_id, v_resp3_name,
            org_level, dimension1_level, dimension2_level);
      end if;
    ELSE
      EXIT;
    END IF;

  END LOOP;

  DBMS_SQL.CLOSE_CURSOR(cursor_id);

END CompareLevelTarget;

/*
 * WIP_Strt_Wf_Process
 *   This procedure starts the workflow process based on the passed
 *   in parameters
 */
PROCEDURE WIP_Strt_Wf_Process(
       p_subject          IN varchar2,
       p_sob              IN varchar2,
       p_le               IN varchar2,
       p_ou               IN varchar2,
       p_org              IN varchar2,
       p_area             IN varchar2,
       p_country          IN varchar2,
       p_region           IN VARCHAR2,  /* James 7/12/99 */
       p_prod_cat         IN varchar2,
       p_prod             IN varchar2,
       p_period           IN varchar2,
       p_target           IN varchar2,
       p_actual           IN varchar2,
       p_wf_process       IN varchar2,
       p_role             IN varchar2,
       p_resp_id          IN number,
       p_report_name      IN varchar2,
       p_report_param     IN varchar2,
       x_return_status    OUT NOCOPY varchar2
) IS
l_wf_item_key       Number;
l_item_type         Varchar2(30) := 'WIPBISWF';
l_report_link       Varchar2(500);
l_role_name         Varchar2(80);
l_url1              Varchar2(2000);

cursor c_role_name is
   select name from wf_roles
   where name = p_role;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   if p_wf_process is null
      or p_role is null then
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
   end if;

   open c_role_name;
   fetch c_role_name into l_role_name;
   if c_role_name%NOTFOUND then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      close c_role_name;
      return;
   end if;
   close c_role_name;

   select bis_excpt_wf_s.nextval
   into l_wf_item_key
   from dual;

   l_report_link  := FND_PROFILE.value('ICX_REPORT_LINK');

   if p_report_name is not null then
      l_url1 := l_report_link ||  'OracleOASIS.RunReport?report='
                       || p_report_name|| '&Parameters=' || p_report_param
                       || '&responsibility_id=' || p_resp_id;
   end if;

   -- create a new workflow process
   wf_engine.CreateProcess(itemtype=>l_item_type
                           ,itemkey =>l_wf_item_key
                           ,process =>p_wf_process);

   -- set the workflow attributes
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_ROLE_NAME'
                             ,avalue=>L_ROLE_NAME);

   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_SUBJECT'
                             ,avalue=>p_subject);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_SOB'
                             ,avalue=>p_sob);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_LEGAL_ENTITY'
                             ,avalue=>p_le);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_OU'
                             ,avalue=>p_ou);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_ORG'
                             ,avalue=>p_org);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_AREA'
                             ,avalue=>p_area);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_COUNTRY'
                             ,avalue=>p_country);
/* James 7/12/99 */
   wf_engine.setitemattrtext(itemtype=>l_item_type
                 ,itemkey =>l_wf_item_key
                 ,aname=>'L_REGION'
                 ,avalue=>p_region);
/* end James */
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_PROD_CAT'
                             ,avalue=>p_prod_cat);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_PROD'
                             ,avalue=>p_prod);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_PERIOD'
                             ,avalue=>p_period);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_TARGET'
                             ,avalue=>p_target);
   wf_engine.SetItemAttrText(itemtype=>l_item_type
                             ,itemkey =>l_wf_item_key
                             ,aname=>'L_ACTUAL'
                             ,avalue=>p_actual);
   if l_url1 is not null then
       wf_engine.SetItemAttrText(itemtype=>l_item_type
                                 ,itemkey =>l_wf_item_key
                                 ,aname=>'L_URL1'
                                 ,avalue=>l_url1);
   end if;

   -- start the process
   wf_engine.StartProcess(itemtype=>l_item_type
                          ,itemkey => l_wf_item_key);

END WIP_Strt_Wf_Process;

/*
 * Alert_Check
 *   This procedure loops through all the target levels defined for
 *   Resource Utilization performance measure and call
 *      1) PostLevelActuals to post actuals to the BIS table
 *      2) CompareLevelTarget to compare actual against target
 */
PROCEDURE Alert_Check IS
  target_level_id  number := 0;
  time_level       number := 0;
  org_level        number := 0;
  geography_level  number := 0;
  product_level    number := 0;

  CURSOR get_target_level IS
   select btl.target_level_id target_level_id,
          decode(tltime.dimension_level_short_name,
                 'TOTAL_TIME', 0,
                 'YEAR', 1,
                 'QUARTER', 2,
                 'MONTH', 3) time_value,
          decode(tlorg.dimension_level_short_name,
                 'SET OF BOOKS', 1,
                 'LEGAL ENTITY', 2,
                 'OPERATING UNIT', 3,
                 'ORGANIZATION', 4) org_value,
          decode(tlgeo.dimension_level_short_name,
                 'TOTAL GEOGRAPHY', 1,
                 'AREA', 2,
                 'COUNTRY', 3,
         'REGION', 4) geo_value,  /* James 7/8/99 */
          decode(tlcat.dimension_level_short_name,
                 'TOTAL PRODUCTS', 1,
                 'PRODUCT GROUP', 2,
                 'ITEM', 3) prod_value
     from bisbv_performance_measures bpm,
          bisbv_target_levels btl,
          bisbv_dimension_levels tltime,
          bisbv_dimension_levels tlorg,
          bisbv_dimension_levels tlgeo,
          bisbv_dimension_levels tlcat
    where bpm.measure_short_name = 'WIPBIUZIND'
      and btl.measure_id = bpm.measure_id
      and btl.time_level_id = tltime.dimension_level_id
      and btl.org_level_id = tlorg.dimension_level_id
      and btl.dimension1_level_id = tlgeo.dimension_level_id
      and btl.dimension2_level_id = tlcat.dimension_level_id;

BEGIN

  FOR tl_rec in get_target_level LOOP

    WIP_BIS_UTZ_ALERT.PostLevelActuals(tl_rec.target_level_id,
                                       tl_rec.time_value,
                                       tl_rec.org_value, tl_rec.geo_value,
                                       tl_rec.prod_value);
    WIP_BIS_UTZ_ALERT.CompareLevelTarget(tl_rec.target_level_id,
                                         tl_rec.time_value, tl_rec.org_value,
                                         tl_rec.geo_value, tl_rec.prod_value);
  END LOOP;

END Alert_Check;

END WIP_BIS_UTZ_ALERT;

/
