--------------------------------------------------------
--  DDL for Package Body OKL_RULE_EXTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RULE_EXTRACT_PVT" AS
/* $Header: OKLRREXB.pls 120.3 2007/07/09 07:38:55 udhenuko ship $ */
--Start of Comments
--Procedure  : Break_SQL
--Purpose    : Takes SQL Statement as input and breaks is into
--             SELECT, FROM, WHERE and ORDER BY Clauses
--End of Comments
PROCEDURE Break_SQL ( p_sql_statement   IN  VARCHAR2,
                      x_select_clause   OUT NOCOPY VARCHAR2,
                      x_from_clause     OUT NOCOPY VARCHAR2,
                      x_where_clause    OUT NOCOPY VARCHAR2,
                      x_order_by_clause OUT NOCOPY VARCHAR2 ) is
  l_sql_statement   varchar2(2000) default null;
  l_select_clause   varchar2(2000) default null;
  l_from_clause     varchar2(2000) default null;
  l_where_clause    varchar2(2000) default null;
  l_order_by_clause varchar2(2000) default null;
begin
  l_sql_statement := upper(p_sql_statement);
  l_select_clause := substr(l_sql_statement,instr(l_sql_statement,'SELECT'),
                            instr(l_sql_statement,'FROM')-instr(l_sql_statement,'SELECT'));
  select substr(l_sql_statement,instr(l_sql_statement,'FROM'),
                                decode(instr(l_sql_statement,'WHERE'),
                                0,decode(instr(l_sql_statement,'ORDER BY'),0,
                                         length(l_sql_statement),
                                         instr(l_sql_statement,'ORDER BY') - instr(l_sql_statement,'FROM')),
                                   instr(l_sql_statement,'WHERE') - instr(l_sql_statement,'FROM')))
  into l_from_clause from dual;
  select  decode(instr(l_sql_statement,'WHERE'),
                            0,Null,
                            substr(l_sql_statement,instr(l_sql_statement,'WHERE'),
                                   decode(instr(l_sql_statement,'ORDER BY'),
                                   0,length(l_sql_statement),
                                   instr(l_sql_statement,'ORDER BY') - instr(l_sql_statement,'WHERE'))))
  into l_where_clause from dual;
  select  decode(instr(l_sql_statement,'ORDER BY'),
                              0,Null,
                              substr(l_sql_statement,instr(l_sql_statement,'ORDER BY'),
                                     length(l_sql_statement)))
 into l_order_by_clause from dual;
 ------------------------------------------------------------
  --dbms_output.put_line('SELECT :'||l_select_clause);
  --dbms_output.put_line('FROM :'||l_from_clause);
  --dbms_output.put_line('WHERE :'||l_where_clause);
  --dbms_output.put_line('ORDER BY :'||l_order_by_clause);
 -------------------------------------------------------------
  x_select_clause   := l_select_clause;
  x_from_clause     := l_from_clause;
  x_where_clause    := l_where_clause;
  x_order_by_clause := l_order_by_clause;
end Break_SQL;
--Start of Comments
--Procedure  : Get_Jtot_Query
--Purpose    : Returns Query for jtot based rule segments
--End of Comments
PROCEDURE Get_Jtot_Query(x_return_status   OUT NOCOPY  VARCHAR2,
                         p_rgd_code        IN   VARCHAR2,
                         p_rgs_code        IN   VARCHAR2,
                         p_buy_or_sell     IN   VARCHAR2,
                         p_object_code     IN   VARCHAR2,
                         x_select_clause   OUT NOCOPY  VARCHAR2,
                         x_from_clause     OUT NOCOPY  VARCHAR2,
                         x_where_clause    OUT NOCOPY  VARCHAR2,
                         x_order_by_clause OUT NOCOPY  VARCHAR2,
                         x_object_code     OUT NOCOPY  VARCHAR2,
                         x_id1_col         OUT NOCOPY  VARCHAR2,
                         x_id2_col         OUT NOCOPY  VARCHAR2,
                         x_name_col        OUT NOCOPY  VARCHAR2) is
--Cursor to get JTOT_OBJECT_CODE from OKC_RULE_DEF_SOURCES_V
  Cursor rule_source_curs is
       SELECT  rds.jtot_object_code object_code
       FROM    OKC_RULE_DEF_SOURCES_V rds
       WHERE   rds.rgr_rgd_code = p_rgd_code
       AND     rds.rgr_rdf_code = p_rgs_code
       AND     rds.buy_or_sell  = p_buy_or_sell
       AND     rds.object_id_number = decode(p_object_code,
                                             'JTOT_OBJECT1_CODE',1,
                                             'JTOT_OBJECT2_CODE',2,
                                             'JTOT_OBJECT3_CODE',3)
       AND     rds.start_date <= sysdate
       AND     nvl(rds.end_date,sysdate+1) > sysdate
       ORDER BY rds.jtot_object_code;
  rule_source_rec rule_source_curs%ROWTYPE;
  l_where_clause  varchar2(2000) default null;
  l_query_string  varchar2(2000) default null;
  l_jtf_query     varchar2(2000) default null;

Begin
--initialize return status
   x_return_status := OKL_API.G_RET_STS_SUCCESS;
--Step 1 : Get the JTOT_OBJECT_CODE Name from OKC_RULE_DEF_SOURCES_V
    Open rule_source_curs;
        Fetch rule_source_curs into rule_source_rec;
        If rule_source_curs%NotFound Then
             --dbms_output.put_line('Get_Jtot_Query : falied in getting rule_source');
             /*OKL_API.SET_MESSAGE(p_app_name     =>   g_app_name,
                                 p_msg_name     =>   G_WARNING,
                                 p_token1       =>   p_rgd_code||':'||p_rgs_code||':'||p_buy_or_sell||':'||p_object_code,
                                 p_token1_value =>   'FAILED TO GET RULE SOURCE FROM OKC_RULE_SOURCES'
                               );
             */
             x_object_code := NULL;
             --this is not an error so no need to raise exception
             --column definition in fnd may be for another rule group and intent
             --so just skip this record
         Else
               x_object_code := rule_source_rec.object_code;
               l_query_string :=    ' SELECT '|| rule_source_rec.object_code||'.ID1, '||
                                                 rule_source_rec.object_code||'.ID2, '||
                                                 rule_source_rec.object_code||'.NAME, '||
                                                 rule_source_rec.object_code||'.DESCRIPTION';
               l_jtf_query    := OKC_UTIL.GET_SQL_FROM_JTFV(p_object_code => rule_source_rec.object_code);
               If l_jtf_query is Null Then
                     --dbms_output.put_line('Get_Jtot_Query : falied in getting jtf query');
                     OKL_API.SET_MESSAGE(p_app_name     =>   g_app_name,
                                         p_msg_name     =>   G_ERROR,
                                         p_token1       =>   p_rgd_code||':'||p_rgs_code||':'||p_buy_or_sell,
                                         p_token1_value =>   'FAILED IN GETTING JTF QUERY FROM OKC_UTIL'
                                        );
                     RAISE OKL_API.G_EXCEPTION_ERROR;
               Else
                    l_query_string := l_query_string || ' FROM ' ||l_jtf_query;
               End If;

               Break_Sql(p_sql_statement   => l_query_string,
                         x_select_clause   => x_select_clause,
                         x_from_clause     => x_from_clause,
                         x_where_clause    => x_where_clause,
                         x_order_by_clause => x_order_by_clause);

--        Changes for constraining BTO - Begin
/*
            if (p_rgs_code = 'BTO' and rule_source_rec.object_code = 'OKX_BILLTO') Then
                x_from_clause := 'FROM OKL_LA_BILL_TO_UV OKX_BILLTO ';
            End if;
            */
--        Changes for constraining BTO - End
         End If;
  Close rule_source_curs;
  x_id1_col  := x_object_code||'.'||'ID1';
  x_id2_col  := x_object_code||'.'||'ID2';
  x_name_col := x_object_code||'.'||'NAME';
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.G_RET_STS_ERROR;
    when OTHERS then
      OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                          p_msg_name       => G_UNEXPECTED_ERROR,
                          p_token1         => G_SQLCODE_TOKEN,
                          p_token1_value   => SQLCODE,
                          p_token2         => G_SQLERRM_TOKEN,
                          p_token2_value   => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
End Get_Jtot_Query;
--Start of Comments
--Procedure  : Get_Dff_Query
--Purpose    : Returns Query for Pure Dff Rule segments
--End of Comments
PROCEDURE Get_Dff_Query( x_return_status        OUT NOCOPY  VARCHAR2,
                         p_flex_value_set_id    IN   NUMBER,
                         x_select_clause        OUT NOCOPY  VARCHAR2,
                         x_from_clause          OUT NOCOPY  VARCHAR2,
                         x_where_clause         OUT NOCOPY  VARCHAR2,
                         x_order_by_clause      OUT NOCOPY  VARCHAR2,
                         x_object_code          OUT NOCOPY  VARCHAR2,
                         x_longlist_flag        OUT NOCOPY  VARCHAR2,
                         x_format_type          OUT NOCOPY  VARCHAR2,
                         x_rule_information_col OUT NOCOPY  VARCHAR2,
                         x_meaning_col          OUT NOCOPY  VARCHAR2,
                         x_value_set_name       OUT NOCOPY  VARCHAR2,
                         x_additional_columns   OUT NOCOPY  VARCHAR2) is
--Cursor for getting the Validation Type
Cursor flex_value_set_cur(p_flex_value_set_id NUMBER) is
    select fvs.longlist_flag
    ,      fvs.format_type
    ,      fvs.maximum_size
    ,      fvs.validation_type
    ,      fvs.flex_value_set_id
    ,      fvs.flex_value_set_name
    from   FND_FLEX_VALUE_SETS fvs
    Where  fvs.FLEX_VALUE_SET_ID=p_flex_value_set_id;
flex_value_set_rec  flex_value_set_cur%rowtype;
--Cursor for getting the query for table validated value sets
Cursor flex_query_t_cur(p_flex_value_set_id NUMBER) is
     SELECT fvt.id_column_name,
            fvt.value_column_name,
            fvt.meaning_column_name,
            fvt.application_table_name,
            fvt.additional_where_clause,
            fvt.enabled_column_name,
            fvt.start_date_column_name,
            fvt.end_date_column_name,
            fvt.additional_quickpick_columns
     FROM   fnd_flex_validation_tables fvt
     WHERE  fvt.flex_value_set_id = p_flex_value_set_id;
flex_query_t_rec flex_query_t_cur%rowtype;
l_query_string           varchar2(2000) default Null;
l_object_code            varchar2(240)  default Null;
l_select_clause          varchar2(200)  default Null;
l_from_clause            varchar2(200)  default Null;
l_where_clause           varchar2(2000) default Null;
l_add_where_clause       varchar2(2000) default Null;
l_order_by_clause        varchar2(2000) default Null;
l_success                number;
l_mapping_code           Varchar2(10)   default null;

Begin
--initialize return status
   x_return_status := OKL_API.G_RET_STS_SUCCESS;
   Open flex_value_set_cur(p_flex_value_set_id);
       Fetch flex_value_set_cur into flex_value_set_rec;
       If flex_value_set_cur%NotFound Then
          OKL_API.SET_MESSAGE(p_app_name     =>   g_app_name,
                              p_msg_name     =>   G_ERROR,
                              p_token1       =>   to_char(p_flex_value_set_id),
                              p_token1_value =>   'FAILED TO FETCH VALUE SET RECORD'
                               );
             RAISE OKL_API.G_EXCEPTION_ERROR;
          Null; --raise appropriate exception
       Elsif flex_value_set_rec.validation_type = 'N' Then --No Validation
          x_longlist_flag := flex_value_set_rec.longlist_flag;
          x_format_type   := flex_value_set_rec.format_type;
          x_value_set_name := flex_value_set_rec.flex_value_set_name;
          l_query_string  := Null;
          l_object_code   := Null;
          x_select_clause := 'None';
          x_object_code   := 'None';
       Elsif flex_value_set_rec.validation_type in ('I') Then --Independent
            x_longlist_flag := flex_value_set_rec.longlist_flag;
            x_format_type   := flex_value_set_rec.format_type;
            x_value_set_name := flex_value_set_rec.flex_value_set_name;
            fnd_flex_val_api.get_independent_vset_select(p_value_set_id          => p_flex_value_set_id,
                                                         p_inc_id_col            => 'N',
                                                         x_select                => l_query_string,
                                                         x_mapping_code          => l_mapping_code,
                                                         x_success               => l_success);

               Break_Sql(p_sql_statement   => l_query_string,
                         x_select_clause   => x_select_clause,
                         x_from_clause     => x_from_clause,
                         x_where_clause    => x_where_clause,
                         x_order_by_clause => x_order_by_clause);

             x_object_code           := 'FND_FLEX_VALUES_VL';
             x_rule_information_col  := 'FLEX_VALUE';
             x_meaning_col           := 'FLEX_VALUE_MEANING';

        Elsif flex_value_set_rec.validation_type = 'D' Then
           x_longlist_flag  := flex_value_set_rec.longlist_flag;
           x_format_type    := flex_value_set_rec.format_type;
           x_value_set_name := flex_value_set_rec.flex_value_set_name;
           fnd_flex_val_api.get_dependent_vset_select(p_value_set_id          => p_flex_value_set_id,
                                                      p_inc_id_col            => 'N',
                                                      x_select                => l_query_string,
                                                      x_mapping_code          => l_mapping_code,
                                                      x_success               => l_success);
          Break_Sql(p_sql_statement   => l_query_string,
                    x_select_clause   => x_select_clause,
                    x_from_clause     => x_from_clause,
                    x_where_clause    => x_where_clause,
                    x_order_by_clause => x_order_by_clause);

          x_object_code                 := 'FND_FLEX_VALUES_VL';
          x_rule_information_col        := 'FLEX_VALUE';
          x_meaning_col                 := 'FLEX_VALUE_MEANING';

       Elsif flex_value_set_rec.validation_type = 'F' Then -- Table Type
            x_longlist_flag := flex_value_set_rec.longlist_flag;
            x_format_type   := flex_value_set_rec.format_type;
            x_value_set_name := flex_value_set_rec.flex_value_set_name;
            Open flex_query_t_cur(p_flex_value_set_id);
                Fetch flex_query_t_cur into flex_query_t_rec;
                If flex_query_t_cur%NotFound Then
                   OKL_API.SET_MESSAGE(p_app_name     =>   g_app_name,
                                       p_msg_name     =>   G_ERROR,
                                       p_token1       =>   to_char(p_flex_value_set_id),
                                       p_token1_value =>   'FAILED TO FETCH TABLE VALIDATED QUERY'
                                      );
                   RAISE OKL_API.G_EXCEPTION_ERROR;
                Else
                --For Rules always use id col
                   If flex_query_t_rec.id_column_name is null Then
                      l_select_clause := ' SELECT '||l_select_clause||' '||flex_query_t_rec.value_column_name||' , ';
                   Else
                      l_select_clause := ' SELECT '||l_select_clause||' '||flex_query_t_rec.id_column_name||' , ';
                   End If;
                --For Rules always use  id col and value column
                   l_select_clause := l_select_clause||' '||flex_query_t_rec.value_column_name;
/*
                   If flex_query_t_rec.meaning_column_name is not null Then
                       l_select_clause := l_select_clause||' '||','||flex_query_t_rec.meaning_column_name||' ';
                   Else
                       l_select_clause := l_select_clause||' '||flex_query_t_rec.value_column_name;
                   End If;
*/
                   l_from_clause  := ' FROM '||l_from_clause||flex_query_t_rec.application_table_name||' ';
                   l_where_clause := ' WHERE '||l_where_clause||' '||flex_query_t_rec.enabled_column_name||' = ';
                   l_where_clause := l_where_clause||' '||''''||'Y'||'''';
                   l_where_clause := l_where_clause||' AND ';
                   l_where_clause := l_where_clause||' nvl('||flex_query_t_rec.start_date_column_name||',sysdate) <= sysdate';
                   l_where_clause := l_where_clause||' AND ';
                   l_where_clause := l_where_clause||' nvl('||flex_query_t_rec.end_date_column_name||',sysdate+1) > sysdate';

                   If flex_query_t_rec.additional_where_clause is null Then
                      Null;
                   Else
                      flex_query_t_rec.additional_where_clause:= REPLACE(upper(flex_query_t_rec.additional_where_clause),'WHERE',' ');
                      l_add_where_clause := null;
                      select l_where_clause||' '||decode(l_where_clause,null,' ',decode(instr(ltrim(flex_query_t_rec.additional_where_clause,' '),'ORDER BY'),1,' ',' AND '))||flex_query_t_rec.additional_where_clause
                      into   l_add_where_clause from dual;
                      l_where_clause := l_add_where_clause;
                   End If;
                   l_query_string          := rtrim(ltrim(l_select_clause,' '),' ')||' '||
                                              rtrim(ltrim(l_from_clause,' '),' ')||' '||
                                              rtrim(ltrim(l_where_clause,' '),' ')||' '||
                                              rtrim(ltrim(l_order_by_clause,' '),' ');
                   Break_Sql(p_sql_statement   => l_query_string,
                             x_select_clause   => x_select_clause,
                             x_from_clause     => x_from_clause,
                             x_where_clause    => x_where_clause,
                             x_order_by_clause => x_order_by_clause);
                   x_object_code           := flex_query_t_rec.application_table_name;
                   x_rule_information_col  := flex_query_t_rec.id_column_name;
                   x_meaning_col           := flex_query_t_rec.value_column_name;
                   x_additional_columns    := flex_query_t_rec.additional_quickpick_columns;
                End If;
         Close flex_query_t_cur;
      End If;
   Close flex_value_set_cur;
   x_object_code := l_object_code;

   EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.G_RET_STS_ERROR;
    when OTHERS then
      OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                          p_msg_name       => G_UNEXPECTED_ERROR,
                          p_token1         => G_SQLCODE_TOKEN,
                          p_token1_value   => SQLCODE,
                          p_token2         => G_SQLERRM_TOKEN,
                          p_token2_value   => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END Get_Dff_Query;

--Start of Comments
--Procedure  : Get_Rule_Def
--Purpose    : Gets Rule metadata from Dff table and calls appropriate procedure
--             based on the type of segment
--End of Comments
PROCEDURE Get_Rule_Def (p_api_version       IN   NUMBER,
                        p_init_msg_list     IN   VARCHAR2,
                        x_return_status     OUT NOCOPY  VARCHAR2,
                        x_msg_count         OUT NOCOPY  NUMBER,
                        x_msg_data          OUT NOCOPY  VARCHAR2,
                        p_rgd_code          IN   VARCHAR2,
                        p_rgs_code          IN   VARCHAR2,
                        p_buy_or_sell       IN   VARCHAR2,
                        x_rule_segment_tbl  OUT NOCOPY  rule_segment_tbl_type) is

  l_select_clause        Varchar2(2000) Default Null;
  l_from_clause          Varchar2(2000) Default Null;
  l_where_clause         Varchar2(2000) Default Null;
  l_order_by_clause      Varchar2(2000) Default Null;
  l_longlist_flag        Varchar2(1) Default 'Y';
  l_format_type          Varchar2(1) Default Null;
  l_id1_col              DBA_TAB_COLUMNS.COLUMN_NAME%TYPE Default Null;
  l_id2_col              DBA_TAB_COLUMNS.COLUMN_NAME%TYPE Default Null;
  l_rule_info_col        DBA_TAB_COLUMNS.COLUMN_NAME%TYPE Default Null;
  l_name_col             DBA_TAB_COLUMNS.COLUMN_NAME%TYPE Default Null;
  l_object_code          VARCHAR2(240) default null;
  l_object_code1         VARCHAR2(240) default null;
  --l_object_code          JTF_OBJECTS_B.OBJECT_CODE%TYPE Default Null;
  l_flex_value_set_id    Number;
  l_dflex_r              fnd_dflex.dflex_r;
  l_context_r            fnd_dflex.context_r;
  l_segments_r           fnd_dflex.segments_dr;
  l_rule_segment_tbl     rule_segment_tbl_type;

  l_value_set_name       FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_NAME%TYPE Default Null;
  l_additional_columns   FND_FLEX_VALIDATION_TABLES.ADDITIONAL_QUICKPICK_COLUMNS%TYPE Default Null;

  l_return_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name                 CONSTANT VARCHAR2(30) := 'GET_RULE_DEF';
  l_api_version              CONSTANT NUMBER    := 1.0;
  -- udhenuko Added the variable to capture the enabled flag for the rule
  l_rule_enabled_flag    FND_DESCR_FLEX_COLUMN_USAGES.SECURITY_ENABLED_FLAG%TYPE Default 'N';
-- rule striping
  Cursor rule_dff_cur (p_rgs_code IN VARCHAR2) is
  Select dfcu.application_id,
         dfcu.descriptive_flexfield_name,
         -- Bug 5876083 - udhenuko Added
         dfcon.enabled_flag
  From   okc_rule_defs_v             rdfv,
         fnd_descr_flex_col_usage_vl dfcu,
         fnd_descr_flex_contexts_vl dfcon
  where  dfcu.application_id                = rdfv.application_id
  and    dfcu.descriptive_flex_context_code = rdfv.rule_code
  and    dfcu.descriptive_flexfield_name    = rdfv.DESCRIPTIVE_FLEXFIELD_NAME
  and    dfcon.application_id               = rdfv.application_id
  and    dfcon.descriptive_flex_context_code= rdfv.rule_code
  and    dfcon.descriptive_flexfield_name   = rdfv.DESCRIPTIVE_FLEXFIELD_NAME
  and    rdfv.rule_code                     = p_rgs_code;
Begin
--set context
--   If okc_context.get_okc_organization_id  is null then
--      okc_context.set_okc_org_context(1,1);
--   End If;
   l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
                                                   G_PKG_NAME,
                                                   p_init_msg_list,
                                                   G_API_VERSION,
                                                   p_api_version,
                                                   G_SCOPE,
                                                   x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   x_return_status := l_return_status;

--rule striping
   Open rule_dff_cur (p_rgs_code => p_rgs_code);
       Fetch rule_dff_cur into l_dflex_r.application_id,
                               l_dflex_r.flexfield_name,
			       l_rule_enabled_flag;
       If rule_dff_cur%NOTFOUND Then
           Null;
       End If;
   Close rule_dff_cur;

   -- udhenuko Including this check to restrict the processing only for Enabled Rules.
   If l_rule_enabled_flag = 'Y' Then

     --l_dflex_r.application_id := 510;
     --l_dflex_r.flexfield_name := 'OKC Rule Developer DF';
     l_context_r.flexfield    := l_dflex_r;
     l_context_r.context_code := p_rgs_code;

     fnd_dflex.get_segments(  context   => l_context_r,
                            segments  => l_segments_r );
     If  l_segments_r.nsegments = 0 Then
        OKL_API.SET_MESSAGE(p_app_name     =>   g_app_name,
                            p_msg_name     =>   G_ERROR,
                            p_token1       =>   p_rgd_code||':'||p_rgs_code||':'||p_buy_or_sell,
                            p_token1_value =>   'FAILED TO GET RULE SEGMENTS FROM FND DFLEX DEFINITIONS'
                            );
        RAISE OKL_API.G_EXCEPTION_ERROR;
     Else
       for i in 1..l_segments_r.nsegments
       Loop
       If l_segments_r.application_column_name(i) like 'JTOT%' Then
          --get query from JTF Objects
          l_object_code1 := l_segments_r.application_column_name(i);
          l_object_code  := l_segments_r.application_column_name(i);
          l_longlist_flag := 'Y';

          Get_jtot_query(x_return_status   => l_return_status,
                         p_rgd_code        => p_rgd_code,
                         p_rgs_code        => p_rgs_code,
                         p_buy_or_sell     => p_buy_or_sell,
                         p_object_code     => l_object_code1,
                         x_select_clause   => l_select_clause,
                         x_from_clause     => l_from_clause,
                         x_where_clause    => l_where_clause,
                         x_order_by_clause => l_order_by_clause,
                         x_object_code     => l_object_code,
                         x_id1_col         => l_id1_col,
                         x_id2_col         => l_id2_col,
                         x_name_col        => l_name_col);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        Elsif l_segments_r.application_column_name(i) like  'RULE%' Then
             --Get Query from Flex Values
             If l_segments_r.value_set(i) is Null Then
                Null; --the column has no validation
                l_select_clause := 'None';
             Else
                l_flex_value_set_id := l_segments_r.value_set(i);
                Get_dff_query( x_return_status        => l_return_status,
                               p_flex_value_set_id    => l_flex_value_set_id,
                               x_select_clause        => l_select_clause,
                               x_from_clause          => l_from_clause,
                               x_where_clause         => l_where_clause,
                               x_order_by_clause      => l_order_by_clause,
                               x_object_code          => l_object_code,
                               x_longlist_flag        => l_longlist_flag,
                               x_format_type          => l_format_type,
                               x_rule_information_col => l_rule_info_col,
                               x_meaning_col          => l_name_col,
                               x_value_set_name       => l_value_set_name,
                               x_additional_columns   => l_additional_columns);

                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;
             End If;
           End If;
             l_rule_segment_tbl(i).rgd_code                := p_rgd_code;
             l_rule_segment_tbl(i).rgs_code                := p_rgs_code;
             l_rule_segment_tbl(i).application_column_name := l_segments_r.application_column_name(i);
             l_rule_segment_tbl(i).end_user_column_name := l_segments_r.segment_name(i);
             l_rule_segment_tbl(i).sequence := l_segments_r.sequence(i);

             If l_segments_r.is_enabled(i) then
                l_rule_segment_tbl(i).enabled_flag := 'Y';
             Else
                l_rule_segment_tbl(i).enabled_flag := 'N';
             End If;
             If l_segments_r.is_displayed(i) then
                l_rule_segment_tbl(i).displayed_flag := 'Y';
             Else
                l_rule_segment_tbl(i).displayed_flag := 'N';
             End If;
             If l_segments_r.is_required(i) then
                l_rule_segment_tbl(i).required_flag := 'Y';
             Else
                l_rule_segment_tbl(i).required_flag := 'N';
             End If;

             l_rule_segment_tbl(i).default_size     := l_segments_r.display_size(i);
             l_rule_segment_tbl(i).left_prompt      := l_segments_r.row_prompt(i);
             If l_segments_r.default_type(i) is not null then
                l_rule_segment_tbl(i).format_type      := l_segments_r.default_type(i);
             Else
                l_rule_segment_tbl(i).format_type      := l_format_type;
             End If;
             l_rule_segment_tbl(i).select_clause      := l_select_clause;
             l_rule_segment_tbl(i).from_clause        := l_from_clause;
             l_rule_segment_tbl(i).where_clause       := l_where_clause;
             l_rule_segment_tbl(i).order_by_clause    := l_order_by_clause;
             l_rule_segment_tbl(i).object_code        := l_object_code;
             l_rule_segment_tbl(i).longlist_flag      := l_longlist_flag;
             l_rule_segment_tbl(i).id1_col            := l_id1_col;
             l_rule_segment_tbl(i).id2_col            := l_id2_col;
             l_rule_segment_tbl(i).rule_info_col      := l_rule_info_col;
             l_rule_segment_tbl(i).name_col           := l_name_col;
             l_rule_segment_tbl(i).value_set_name     := l_value_set_name;
             l_rule_segment_tbl(i).additional_columns := l_additional_columns;
             x_rule_segment_tbl := l_rule_segment_tbl;
           End Loop;
        End If;
      End If;
--Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

End Get_Rule_Def;

---------- -- bug 3029276

--Start of Comments
--Procedure  : Get_Name_Values
--Purpose    : Query Name, Description for a given id and meta data sql.
--End of Comments

PROCEDURE Get_Name_Values ( p_api_version       IN  NUMBER,
                            p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_msg_count         OUT NOCOPY NUMBER,
                            x_msg_data          OUT NOCOPY VARCHAR2,
                            p_chr_id            IN  NUMBER,
                            p_segment           IN  FND_DESCR_FLEX_COL_USAGE_VL.APPLICATION_COLUMN_NAME%TYPE,
                            p_longlist_flag     IN  VARCHAR2,
                            p_ruleinfo_column   IN  DBA_TAB_COLUMNS.COLUMN_NAME%TYPE,
                            p_name_column       IN  DBA_TAB_COLUMNS.COLUMN_NAME%TYPE,
                            p_id1               IN  VARCHAR2,
                            P_id2               IN  VARCHAR2,
                            p_select_clause     IN  VARCHAR2,
                            p_from_clause       IN  VARCHAR2,
                            p_where_clause      IN  VARCHAR2,
                            x_name              OUT NOCOPY VARCHAR2,
                            x_desc              OUT NOCOPY VARCHAR2
                            ) is

  l_select_clause        Varchar2(2000) := p_select_clause;
  l_from_clause          Varchar2(2000) := p_from_clause;
  l_where_clause         Varchar2(6000) := p_where_clause;
  l_sql_string           VARCHAR2(32767) := '';
  l_sql                  VARCHAR2(32767) := '';

  l_org_id NUMBER := -99;
  l_segment_type VARCHAR2(10) := '' ;

  Type jtot_ref_curs_type is REF CURSOR;
  jtot_ref_curs jtot_ref_curs_type;
  Type rule_ref_curs_type is REF CURSOR;
  rule_ref_curs jtot_ref_curs_type;

  l_return_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name                 CONSTANT VARCHAR2(30) := 'GET_NAME_VALUES';
  l_api_version              CONSTANT NUMBER    := 1.0;

  Begin

     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
                                                     G_PKG_NAME,
                                                     p_init_msg_list,
                                                     G_API_VERSION,
                                                     p_api_version,
                                                     G_SCOPE,
                                                     x_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


    OKL_CONTEXT.set_okc_org_context(p_chr_id => p_chr_id);

    if(p_segment like 'JTOT%') then
        l_sql_string :=  'SELECT NAME, DESCRIPTION ';
        l_sql_string :=  l_sql_string||l_from_clause;
        if(l_where_clause is null) then
            l_sql_string :=  l_sql_string||' WHERE ID1 ='||''''||p_id1||''''||' AND ID2 ='||''''||p_id2||'''';
        else
            l_sql_string :=  l_sql_string||l_where_clause||' AND ID1 ='||''''||p_id1||''''||' AND ID2 ='||''''||p_id2||'''';
        end if;
        l_sql := l_sql_string;

        If (p_id1 is not null and p_id2 is not null) Then
            open  jtot_ref_curs for l_sql_string;
            Fetch jtot_ref_curs into x_name,x_desc;
            If jtot_ref_curs%notfound Then
                x_name := '';
                x_desc := '';
            End If;
            Close jtot_ref_curs;
        End If;
     else
        l_sql_string :=  'SELECT '||p_name_column||' ';
        l_sql_string :=  l_sql_string||' '||p_from_clause;
        if(l_where_clause is null) then
--            bug 3377730.
--            l_sql_string :=  l_sql_string||' WHERE '||p_ruleinfo_column||' = '''||to_char(p_id1)||'''';

            l_sql_string :=  l_sql_string||' WHERE '||p_ruleinfo_column||' = '''||p_id1||'''';
        else
--            bug 3377730.
--            l_sql_string :=  l_sql_string||l_where_clause||' AND '||p_ruleinfo_column||' = '''||to_char(p_id1)||'''';
            l_sql_string :=  l_sql_string||l_where_clause||' AND '||p_ruleinfo_column||' = '''||p_id1||'''';
        end if;

        If(p_id1 is not null) Then
            open  rule_ref_curs for l_sql_string;
            Fetch rule_ref_curs into x_name;
            If rule_ref_curs%notfound Then
                x_name := '';
            End If;
            Close rule_ref_curs;
         End If;
     End if;

--Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);

EXCEPTION
    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

  End Get_Name_Values;

--Start of Comments
--Procedure  : Get_Rules_Metadata
--Purpose    : Gets Rule Segment Meta Data using Get_Rule_Def and
--             retrieve id and query names for corr. rule instances
--End of Comments


PROCEDURE Get_Rules_Metadata (p_api_version       IN  NUMBER,
                              p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_msg_count         OUT NOCOPY NUMBER,
                              x_msg_data          OUT NOCOPY VARCHAR2,
                              p_rgd_code          IN  VARCHAR2,
                              p_rgs_code          IN  VARCHAR2,
                              p_buy_or_sell       IN  VARCHAR2,
                              p_contract_id       IN  OKC_K_HEADERS_B.ID%TYPE,
                              p_line_id           IN  OKC_K_LINES_B.ID%TYPE,
                              p_party_id          IN  OKC_K_PARTY_ROLES_B.ID%TYPE,
                              p_template_table    IN  VARCHAR2,
                              p_rule_id_column    IN  VARCHAR2,
                              p_entity_column     IN  VARCHAR2,
                              x_rule_segment_tbl  OUT NOCOPY rule_segment_tbl_type2) is

  l_select_clause        Varchar2(2000) Default Null;
  l_from_clause          Varchar2(2000) Default Null;
  l_where_clause         Varchar2(2000) Default Null;
  l_order_by_clause      Varchar2(2000) Default Null;

  l_id1_col              DBA_TAB_COLUMNS.COLUMN_NAME%TYPE Default Null;
  l_id2_col              DBA_TAB_COLUMNS.COLUMN_NAME%TYPE Default Null;
  l_rule_info_col        DBA_TAB_COLUMNS.COLUMN_NAME%TYPE Default Null;
  l_name_col             DBA_TAB_COLUMNS.COLUMN_NAME%TYPE Default Null;
  l_object_code          VARCHAR2(240) default null;
  l_object_code1         VARCHAR2(240) default null;

  l_chr_id               OKC_K_HEADERS_B.ID%TYPE := p_contract_id;
  l_line_id              OKC_K_LINES_B.ID%TYPE := p_line_id;
  l_cpl_id               OKC_K_PARTY_ROLES_B.ID%TYPE := p_party_id;
  process_type           VARCHAR2(30) := '';
  x_name                 VARCHAR2(3000);
  x_desc                 VARCHAR2(3000);
  l_date                 date;

  l_rule_segment_tbl     rule_segment_tbl_type;
  l_rule_segment_tbl2    rule_segment_tbl_type2;
  --l_rulv_rec             rulv_rec_type;


  CURSOR HEADER_RULE_CSR(P_CONTRACT_ID IN OKC_K_HEADERS_B.ID%TYPE,
                         P_RGD_CODE IN VARCHAR2, P_RULE_CODE IN VARCHAR2) IS
  SELECT RL.*
  FROM OKC_RULE_GROUPS_B RG, OKC_RULES_B RL
  WHERE RG.DNZ_CHR_ID   = P_CONTRACT_ID
        AND RG.CHR_ID   = P_CONTRACT_ID
        AND RG.RGD_CODE = P_RGD_CODE
        AND RG.ID       = RL.RGP_ID
        AND RL.RULE_INFORMATION_CATEGORY = P_RULE_CODE;

  CURSOR LINE_RULE_CSR(P_CONTRACT_ID IN OKC_K_HEADERS_B.ID%TYPE,
                       P_LINE_ID IN OKC_K_LINES_B.ID%TYPE,
                       P_RGD_CODE IN VARCHAR2, P_RULE_CODE IN VARCHAR2) IS
  SELECT RL.*
  FROM OKC_RULE_GROUPS_B RG, OKC_RULES_B RL
  WHERE RG.DNZ_CHR_ID   = P_CONTRACT_ID
        AND RG.CHR_ID   IS NULL
        AND RG.CLE_ID   = P_LINE_ID
        AND RG.RGD_CODE = P_RGD_CODE
        AND RG.ID       = RL.RGP_ID
        AND RL.RULE_INFORMATION_CATEGORY = P_RULE_CODE;

  l_rulv_rec HEADER_RULE_CSR%ROWTYPE;

  i  number := 0;

  l_return_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name                 CONSTANT VARCHAR2(30) := 'GET_RULE_DEF';
  l_api_version              CONSTANT NUMBER    := 1.0;

  Begin

   l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
                                                   G_PKG_NAME,
                                                   p_init_msg_list,
                                                   G_API_VERSION,
                                                   p_api_version,
                                                   G_SCOPE,
                                                   x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;


   if(l_chr_id is null or l_chr_id = OKC_API.G_MISS_NUM) then
    l_chr_id := -1;
   end if;
   if(l_line_id is null or l_line_id = OKC_API.G_MISS_NUM) then
    l_line_id := -1;
   end if;
   if(l_cpl_id is null or l_cpl_id = OKC_API.G_MISS_NUM) then
    l_cpl_id := -1;
   end if;
   if(l_chr_id = -1 and l_cpl_id = -1 and l_line_id = -1) then
    process_type := 'TEMPLATE';
   elsif(l_cpl_id = -1 and l_line_id = -1) then
    process_type := 'HEADER';
   elsif(l_cpl_id = -1 and l_line_id <> -1) then
    process_type := 'LINE';
   elsif(l_cpl_id <> -1) then
    process_type := 'PARTY';
   end if;

   if(process_type = 'HEADER') then
    open HEADER_RULE_CSR(p_contract_id, p_rgd_code, p_rgs_code);
    fetch HEADER_RULE_CSR into l_rulv_rec;
    close HEADER_RULE_CSR;
   elsif(process_type = 'LINE') then
    open LINE_RULE_CSR(p_contract_id, p_line_id, p_rgd_code, p_rgs_code);
    fetch LINE_RULE_CSR into l_rulv_rec;
    close LINE_RULE_CSR;
   end if;



   Get_Rule_Def (p_api_version      => l_api_version,
                 p_init_msg_list    => p_init_msg_list,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_rgd_code         => p_rgd_code,
                 p_rgs_code         => p_rgs_code,
                 p_buy_or_sell      => p_buy_or_sell,
                 x_rule_segment_tbl => l_rule_segment_tbl);


   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;



   for i in 1..l_rule_segment_tbl.COUNT
   Loop
    l_rule_segment_tbl2(i).rgd_code                 := l_rule_segment_tbl(i).rgd_code;
    l_rule_segment_tbl2(i).rgs_code                 := l_rule_segment_tbl(i).rgs_code;
    l_rule_segment_tbl2(i).application_column_name  := l_rule_segment_tbl(i).application_column_name;
    l_rule_segment_tbl2(i).end_user_column_name     := l_rule_segment_tbl(i).end_user_column_name;
    l_rule_segment_tbl2(i).sequence                 := l_rule_segment_tbl(i).sequence;
    l_rule_segment_tbl2(i).enabled_flag             := l_rule_segment_tbl(i).enabled_flag;
    l_rule_segment_tbl2(i).displayed_flag           := l_rule_segment_tbl(i).displayed_flag;
    l_rule_segment_tbl2(i).required_flag            := l_rule_segment_tbl(i).required_flag;
    l_rule_segment_tbl2(i).default_size             := l_rule_segment_tbl(i).default_size;
    l_rule_segment_tbl2(i).left_prompt              := l_rule_segment_tbl(i).left_prompt;
    l_rule_segment_tbl2(i).select_clause            := l_rule_segment_tbl(i).select_clause;
    l_rule_segment_tbl2(i).from_clause              := l_rule_segment_tbl(i).from_clause;
    l_rule_segment_tbl2(i).where_clause             := l_rule_segment_tbl(i).where_clause;
    l_rule_segment_tbl2(i).order_by_clause          := l_rule_segment_tbl(i).order_by_clause;
    l_rule_segment_tbl2(i).object_code              := l_rule_segment_tbl(i).object_code;
    l_rule_segment_tbl2(i).longlist_flag            := l_rule_segment_tbl(i).longlist_flag;
    l_rule_segment_tbl2(i).format_type              := l_rule_segment_tbl(i).format_type;
    l_rule_segment_tbl2(i).id1_col                  := l_rule_segment_tbl(i).id1_col;
    l_rule_segment_tbl2(i).id2_col                  := l_rule_segment_tbl(i).id2_col;
    l_rule_segment_tbl2(i).rule_info_col            := l_rule_segment_tbl(i).rule_info_col;
    l_rule_segment_tbl2(i).name_col                 := l_rule_segment_tbl(i).name_col;
    l_rule_segment_tbl2(i).value_set_name           := l_rule_segment_tbl(i).value_set_name;
    l_rule_segment_tbl2(i).additional_columns       := l_rule_segment_tbl(i).additional_columns;


    if(l_rule_segment_tbl2(i).application_column_name = 'RULE_INFORMATION1') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information1;
    elsif (l_rule_segment_tbl(i).application_column_name = 'RULE_INFORMATION2') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information2;
    elsif (l_rule_segment_tbl(i).application_column_name = 'RULE_INFORMATION3') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information3;
    elsif (l_rule_segment_tbl(i).application_column_name = 'RULE_INFORMATION4') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information4;
    elsif (l_rule_segment_tbl(i).application_column_name = 'RULE_INFORMATION5') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information5;
    elsif (l_rule_segment_tbl(i).application_column_name = 'RULE_INFORMATION6') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information6;
    elsif (l_rule_segment_tbl(i).application_column_name = 'RULE_INFORMATION7') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information7;
    elsif (l_rule_segment_tbl(i).application_column_name = 'RULE_INFORMATION8') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information8;
    elsif (l_rule_segment_tbl(i).application_column_name = 'RULE_INFORMATION9') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information9;
    elsif (l_rule_segment_tbl(i).application_column_name = 'RULE_INFORMATION10') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information10;
    elsif (l_rule_segment_tbl(i).application_column_name = 'RULE_INFORMATION11') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information11;
    elsif (l_rule_segment_tbl(i).application_column_name = 'RULE_INFORMATION12') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information12;
    elsif (l_rule_segment_tbl(i).application_column_name = 'RULE_INFORMATION13') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information13;
    elsif (l_rule_segment_tbl(i).application_column_name = 'RULE_INFORMATION14') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information14;
    elsif (l_rule_segment_tbl(i).application_column_name = 'RULE_INFORMATION15') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.rule_information15;
    elsif (l_rule_segment_tbl(i).application_column_name = 'JTOT_OBJECT1_CODE') then
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.object1_id1;
        l_rule_segment_tbl2(i).x_id2   := l_rulv_rec.object1_id2;
    elsif (l_rule_segment_tbl(i).application_column_name = 'JTOT_OBJECT2_CODE') then
        -- Udhenuko Bug#5876083 Modifying the assignments to get object id for object2 code
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.object2_id1;
        l_rule_segment_tbl2(i).x_id2   := l_rulv_rec.object2_id2;
    elsif (l_rule_segment_tbl(i).application_column_name = 'JTOT_OBJECT3_CODE') then
        -- Udhenuko Bug#5876083 Modifying the assignments to get object id for object3 code
        l_rule_segment_tbl2(i).x_id1   := l_rulv_rec.object3_id1;
        l_rule_segment_tbl2(i).x_id2   := l_rulv_rec.object3_id2;
    end if;

    x_name := '';
    x_desc := '';


    if(l_rule_segment_tbl2(i).longlist_flag = 'Y' or
       l_rule_segment_tbl2(i).value_set_name = 'Yes_No') then
        if(l_rule_segment_tbl2(i).select_clause is null or l_rule_segment_tbl2(i).select_clause = 'None') then
            l_rule_segment_tbl2(i).x_segment_status := 'INVALID';
            x_name := l_rule_segment_tbl2(i).x_id1;
        else
            Get_Name_Values(p_api_version      => l_api_version,
                            p_init_msg_list    => p_init_msg_list,
                            x_return_status    => l_return_status,
                            x_msg_count        => x_msg_count,
                            x_msg_data         => x_msg_data,
                            p_chr_id           => l_chr_id,
                            p_segment          => l_rule_segment_tbl2(i).application_column_name,
                            p_longlist_flag    => l_rule_segment_tbl2(i).longlist_flag,
                            p_ruleinfo_column  => l_rule_segment_tbl2(i).rule_info_col,
                            p_name_column      => l_rule_segment_tbl2(i).name_col,
                            p_id1              => l_rule_segment_tbl2(i).x_id1,
                            p_id2              => l_rule_segment_tbl2(i).x_id2,
                            p_select_clause    => l_rule_segment_tbl2(i).select_clause,
                            p_from_clause      => l_rule_segment_tbl2(i).from_clause,
                            p_where_clause     => l_rule_segment_tbl2(i).where_clause,
                            x_name             => x_name,
                            x_desc             => x_desc);

               IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
               END IF;
        end if;
   else
        if(l_rule_segment_tbl2(i).value_set_name = 'FND_STANDARD_DATE' and
           l_rule_segment_tbl2(i).x_id1 is not null) then
            l_date := FND_DATE.canonical_to_date(l_rule_segment_tbl2(i).x_id1);
            x_name := to_char(l_date,fnd_profile.value('ICX_DATE_FORMAT_MASK'));
        else
            x_name := l_rule_segment_tbl2(i).x_id1;
        end if;
   end if;

   l_rule_segment_tbl2(i).x_name   := x_name;
   l_rule_segment_tbl2(i).x_desc   := x_desc;

  End Loop;

  x_rule_segment_tbl := l_rule_segment_tbl2;

--Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);
End Get_Rules_Metadata;


-- -- end bug 3029276

--Start of Comments
--Procedure  : Get_Subclass_Rgs
--Purpose    : Gets Rule Groups for a subclass (Contract header id)
--End of Comments
Procedure Get_subclass_Rgs (p_api_version     IN  NUMBER,
                            p_init_msg_list   IN  VARCHAR2,
                            x_return_status   OUT NOCOPY VARCHAR2,
                            x_msg_count       OUT NOCOPY NUMBER,
                            x_msg_data        OUT NOCOPY VARCHAR2,
                            p_chr_id          IN Varchar2,
                            x_sc_rg_tbl       OUT NOCOPY sc_rg_tbl_type)  is
Cursor scs_rgd_curs is
select   osrg.SCS_CODE
        ,osrg.RGD_CODE
        ,fl.Meaning
        ,fl.description
from     Fnd_Lookups fl,
         okc_subclass_rg_defs osrg,
         okc_k_headers_v chrv
where    fl.lookup_type = 'OKC_RULE_GROUP_DEF'
and      fl.enabled_flag = 'Y'
and      nvl(fl.start_date_active,sysdate) <= sysdate
and      nvl(fl.end_date_active,sysdate+1) > sysdate
and      fl.lookup_code = osrg.RGD_CODE
and      nvl(osrg.start_date,sysdate) <= sysdate
and      nvl(osrg.end_date,sysdate+1) > sysdate
and      osrg.scs_code = chrv.scs_code
and      chrv.id = p_chr_id;
l_scs_rgd_rec scs_rgd_curs%rowtype;
i NUMBER;

l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_name               CONSTANT VARCHAR2(30) := 'GET_SUBCLASS_RGS';
l_api_version            CONSTANT NUMBER    := 1.0;

begin
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
                                                   G_PKG_NAME,
                                                   p_init_msg_list,
                                                   G_API_VERSION,
                                                   p_api_version,
                                                   G_SCOPE,
                                                   x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
   i := 1;
   open scs_rgd_curs;
   Loop
      Fetch scs_rgd_curs into l_scs_rgd_rec;
      If scs_rgd_curs%NotFound Then
         Exit;
      Else
         x_sc_rg_tbl(i).scs_code    := l_scs_rgd_rec.scs_code;
         x_sc_rg_tbl(i).rgd_code    := l_scs_rgd_rec.rgd_code;
         x_sc_rg_tbl(i).Meaning     := l_scs_rgd_rec.Meaning;
         x_sc_rg_tbl(i).Description := l_scs_rgd_rec.Description;
         i := i + 1;
      End If;
   End Loop;
   Close scs_rgd_curs;
--Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

End Get_subclass_Rgs;
--Start of Comments
--Procedure  : Get_Rule_Segments
--Purpose    : Gets Rule segments
--End of Comments
Procedure Get_Rule_Segments ( x_return_status   OUT NOCOPY Varchar2,
                              p_rgs_code        IN  Varchar2,
                              x_segment_count   OUT NOCOPY Number,
                              x_rule_tbl        OUT NOCOPY rule_tbl_type) is
l_rule_tbl Rule_tbl_type;
cursor rule_seg_curs is
/*select   dfcu.descriptive_flex_context_code
  ,      dfcu.application_column_name
  ,      dfcu.column_seq_num
  from   fnd_lookups                 fl,
         fnd_descr_flex_col_usage_vl dfcu
  where  fl.lookup_type = 'OKC_RULE_DEF'
  and    fl.lookup_code = dfcu.descriptive_flex_context_code
  and    fl.enabled_flag = 'Y'
  and    nvl(fl.start_date_active,sysdate) <= sysdate
  and    nvl(fl.end_date_active,sysdate+1) > sysdate
  and    dfcu.application_id=510
  and    dfcu.descriptive_flexfield_name='OKC Rule Developer DF'
  and    dfcu.descriptive_flex_context_code = p_rgs_code
union
*/
--after rule striping :
select   dfcu.descriptive_flex_context_code
  ,      dfcu.application_column_name
  ,      dfcu.column_seq_num
from     okc_rule_defs_v             rdfv,
         fnd_descr_flex_col_usage_vl dfcu
where    dfcu.application_id                = rdfv.application_id
and      dfcu.descriptive_flex_context_code = rdfv.rule_code
and      dfcu.descriptive_flexfield_name    = rdfv.DESCRIPTIVE_FLEXFIELD_NAME
and      rdfv.rule_code                     = p_rgs_code
order  by 3;
l_rule_seg_rec rule_seg_curs%RowType;
i Number;
Begin
   x_return_status := OKL_API.G_RET_STS_SUCCESS;
    Open rule_seg_curs;
    i := 0;
    Loop
       Fetch rule_seg_curs
       Into  l_rule_seg_rec;
       If  rule_seg_curs%NotFound Then
           Exit;
       Else
           i:= i+1;
           l_rule_tbl(i).rgs_code := p_rgs_code;
           l_rule_tbl(i).application_column_name := l_rule_seg_rec.application_column_name;
           l_rule_tbl(i).column_seq_num :=          l_rule_seg_rec.column_seq_num;
       End If;
    End Loop;
    Close rule_seg_curs;
    x_rule_tbl := l_rule_tbl;
    x_segment_count := i;
  EXCEPTION
     when OTHERS then
      OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                          p_msg_name       => G_UNEXPECTED_ERROR,
                          p_token1         => G_SQLCODE_TOKEN,
                          p_token1_value   => SQLCODE,
                          p_token2         => G_SQLERRM_TOKEN,
                          p_token2_value   => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
End Get_Rule_Segments;
--Start of Comments
--Procedure  : Get_Rg_Rules
--Purpose    : Gets Rules segments
--End of Comments
Procedure Get_Rg_Rules (p_api_version     IN  NUMBER,
                        p_init_msg_list   IN  VARCHAR2,
                        x_return_status   OUT NOCOPY VARCHAR2,
                        x_msg_count       OUT NOCOPY NUMBER,
                        x_msg_data        OUT NOCOPY VARCHAR2,
                        p_rgd_code        IN Varchar2,
                        x_rg_rules_tbl    OUT NOCOPY rg_rules_tbl_type) is

Cursor rg_rule_def_curs is
       select rgd_code,
              rdf_code,
              optional_yn,
              min_cardinality,
              max_cardinality
       from   okc_rg_def_rules
       where  rgd_code = p_rgd_code;
l_rg_rule_def_rec rg_rule_def_curs%RowType;
l_rule_tbl        rule_tbl_type;
l_rg_rules_tbl    rg_rules_tbl_type;
l_segment_count   Number;
i Number;

l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_name               CONSTANT VARCHAR2(30) := 'GET_RG_RULES';
l_api_version            CONSTANT NUMBER    := 1.0;

begin
   l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
                                                   G_PKG_NAME,
                                                   p_init_msg_list,
                                                   G_API_VERSION,
                                                   p_api_version,
                                                   G_SCOPE,
                                                   x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
   Open rg_rule_def_curs;
   Loop
       Fetch rg_rule_def_curs into l_rg_rule_def_rec;
       If rg_rule_def_curs%NotFound Then
          Exit;
       Else
           Get_Rule_Segments(x_return_status => l_return_status,
                             p_rgs_code      => l_rg_rule_def_rec.rdf_code,
                             x_segment_count => l_segment_Count,
                             x_rule_tbl      => l_rule_tbl);

            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

           For i in 1..l_segment_count
           Loop
              l_rg_rules_tbl(i).rgd_code                := l_rg_rule_def_rec.rgd_code;
              l_rg_rules_tbl(i).rdf_code                := l_rg_rule_def_rec.rdf_code;
              l_rg_rules_tbl(i).application_column_name := l_rule_tbl(i).application_column_name;
              l_rg_rules_tbl(i).column_seq_num          := l_rule_tbl(i).column_seq_num;
              l_rg_rules_tbl(i).optional_yn             := l_rg_rule_def_rec.optional_yn;
              l_rg_rules_tbl(i).min_cardinality         := l_rg_rule_def_rec.min_cardinality;
              l_rg_rules_tbl(i).max_cardinality         := l_rg_rule_def_rec.max_cardinality;
           End Loop;
      End If;
  End Loop;
 Close rg_rule_def_curs;
 x_rg_rules_tbl := l_rg_rules_tbl;
 --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);

 EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

End Get_Rg_Rules;
END OKL_RULE_EXTRACT_PVT;

/
