--------------------------------------------------------
--  DDL for Package Body FA_ASSET_TRACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ASSET_TRACE_PVT" AS
/* $Header: faxtrcvb.pls 120.0.12010000.5 2010/04/26 16:57:54 hhafid noship $ */

g_options_tbl       FA_ASSET_TRACE_PUB.t_options_tbl;
g_col_exclusions    FA_ASSET_TRACE_PUB.t_excl_tbl;
g_tmp_opt_tbl       FA_ASSET_TRACE_PUB.t_options_tbl;
g_tmpc_tbl          FA_ASSET_TRACE_PKG.t_col_tbl;
g_tbl_hldr          FA_ASSET_TRACE_PKG.t_col_tbl;
g_anchor_tbl        FA_ASSET_TRACE_PKG.t_col_tbl;
g_no_rec_tbl        t_asset_tbl;
g_tmp_tbl           t_asset_tbl;
g_output_tbl        t_asset_tbl;
g_req_tbl           t_num_tbl;
g_fcol_tbl          VARCHAR2(100);

g_chk_cnt           BOOLEAN;
g_trc_tbl           VARCHAR2(100);
g_anchor            VARCHAR2(32767);

g_schema            VARCHAR2(50);
g_print_debug       boolean;

--Load global table.

PROCEDURE initialize_globals (p_opt_tbl        IN         FA_ASSET_TRACE_PUB.t_options_tbl,
                              p_exc_tbl        IN         FA_ASSET_TRACE_PUB.t_excl_tbl,
                              p_schema         OUT NOCOPY VARCHAR2,
                              p_debug_flag     IN         BOOLEAN,
                              p_log_level_rec  IN         FA_API_TYPES.log_level_rec_type default null) IS

 l_app_short_name  VARCHAR2(50);
 l_status          varchar2(100);
 l_industry        varchar2(100);
 schema_err        exception;
 null_param_tbl    EXCEPTION;

 l_calling_fn      varchar2(40)  := 'fa_asset_trace_pvt.load_globals';

BEGIN
  --Validate param tbl.
  IF g_param_tbl.count = 0 THEN
    raise null_param_tbl;
  END IF;

  -- Get schema
  l_app_short_name := FND_GLOBAL.APPLICATION_SHORT_NAME;
  if ((nvl(g_use_utl_file, 'N')='Y') and (l_app_short_name is null)) then
    l_app_short_name :='OFA';
  end if;
  if not (fnd_installation.get_app_info (
                 application_short_name => l_app_short_name,
                 status                 => l_status,
                 industry               => l_industry,
                 oracle_schema          => g_schema)) then
     raise schema_err;
  end if;

  -- 8918668
  if (g_schema is null) then
    -- Assume custom app and default fixed assets
    g_schema := 'FA';
  end if;

  p_schema := g_schema;
  g_print_debug := TRUE; --p_debug_flag;

  g_anchor_tbl.delete;
  g_options_tbl.delete;
  g_col_exclusions.delete;

  IF p_opt_tbl.count > 0 THEN
    g_options_tbl := p_opt_tbl;
  ELSE
    log(l_calling_fn, 'p_opt_tbl has no data');
  END IF;

  IF p_exc_tbl.count > 0 THEN
    g_col_exclusions := p_exc_tbl;
  ELSE
    log(l_calling_fn, 'p_exc_tbl has no data');
  END IF;

  for i in g_options_tbl.first .. g_options_tbl.last loop
    log (l_calling_fn, g_options_tbl(i).l_tbl);
  end loop;

EXCEPTION
   WHEN null_param_tbl THEN
      log(l_calling_fn, 'Error');
      log(l_calling_fn,'null_param_tbl exception, param tbl is null');
      raise;
   WHEN schema_err THEN
      log(l_calling_fn, 'Error');
      raise;
   WHEN OTHERS THEN
      log(l_calling_fn, 'Error');
      raise;

END initialize_globals;
--
-- Validates non-setup related tables and calls build_stmt and exec_sql.
--
PROCEDURE do_primary IS

   l_cursor            c_stmt;
   l_primary_tbls      FA_ASSET_TRACE_PUB.t_options_tbl;
   l_col_tbl           FA_ASSET_TRACE_PKG.t_col_tbl;
   l_t_tbl             FA_ASSET_TRACE_PKG.t_col_tbl;
   l_cur_tab_name      varchar2(100);
   l_tmp_tbl           VARCHAR2(100):='NOTHING';
   l_tblcount          number;
   l_sel               VARCHAR2(2000);
   l_cnt_stmt          VARCHAR2(32767);
   l_stmt              VARCHAR2(32767);
   l_schema            VARCHAR2(5);

   l_calling_fn        varchar2(40)  := 'fa_asset_trace_pvt.do_primary';

BEGIN

   l_primary_tbls := g_options_tbl;

   FOR i IN l_primary_tbls.first .. l_primary_tbls.last LOOP
      --check if table is from a different schema
      if l_primary_tbls(i).l_schema is not null then
        l_schema := l_primary_tbls(i).l_schema;
      else
        l_schema := g_schema;
      end if;

      if (nvl(l_primary_tbls(i).l_fullcol_list, 'N') = 'N') then
          do_col_exclusions (p_tbl    => l_primary_tbls(i).l_tbl,
                             p_schema => l_schema,
                             x_stmt   => l_stmt);

        if (g_print_debug) then
          log(l_calling_fn, l_stmt);
        end if;

        OPEN l_cursor FOR l_stmt;
        FETCH l_cursor BULK COLLECT INTO l_t_tbl, l_col_tbl;
        CLOSE l_cursor;
      elsif (nvl(l_primary_tbls(i).l_fullcol_list, 'N') = 'Y') then
        g_fcol_tbl := l_primary_tbls(i).l_tbl;
      end if; -- if (nvl(l_primary_tbls(i).l_fullcol_list...

      IF ((l_t_tbl.count > 0) or
                  (nvl(l_primary_tbls(i).l_fullcol_list, 'N') = 'Y')) THEN

         build_stmt(p_t_tbl => l_t_tbl, p_col_tbl => l_col_tbl);

         FOR j IN g_sel_tbl.first .. g_sel_tbl.last LOOP

           l_cur_tab_name := g_tbl_hldr(j);
           l_sel          := g_sel_tbl(j);
           g_dyn_head     := g_hdr_tbl(j);

           if (g_print_debug) then
              log(l_calling_fn,'Inner loop, l_cur_tab_name: '||l_cur_tab_name);
              log(l_calling_fn,'Inner loop, l_sel: '||l_sel);
              log(l_calling_fn,'Inner loop, g_dyn_head: '||g_dyn_head);
           end if;

			     IF l_tmp_tbl <> l_cur_tab_name THEN
             l_cnt_stmt := l_primary_tbls(i).l_cnt_stmt;
			       IF l_cnt_stmt IS NOT NULL THEN
			         g_chk_cnt :=get_tbl_cnt (NULL,l_cnt_stmt,l_schema);
			       ELSE
			         IF (nvl(l_primary_tbls(i).l_gen_select, 'N') = 'Y') THEN
			           g_chk_cnt :=get_tbl_cnt (l_cur_tab_name,NULL,l_schema);
			         ELSIF nvl(l_primary_tbls(i).l_gen_select, 'N') = 'N' THEN
			           g_chk_cnt := TRUE;
				         l_schema :='NONE';
			         END IF;
			       END IF;
			     END IF;

			     l_tmp_tbl := l_cur_tab_name;

			     --check if row header is needed
	         if (nvl(l_primary_tbls(i).l_no_header, 'N') = 'Y') then
	           g_no_header := 'Y';
           end if;

           IF g_chk_cnt THEN
             exec_sql(l_cur_tab_name,l_sel,NULL,l_schema);
           ELSE
             l_tblcount := g_no_rec_tbl.count +1;
             g_no_rec_tbl (l_tblcount) :=l_cur_tab_name;
           END IF;
   --
         END LOOP;  --g_sel_tbl
         l_col_tbl  := g_tmpc_tbl;
         l_t_tbl    := g_tmpc_tbl;
      END IF; --l_t_tbl.count > 0
   END LOOP; --end l_primary_tbls loop
   l_primary_tbls := g_tmp_opt_tbl;
   log(l_calling_fn, 'Done with primary');

EXCEPTION
   WHEN OTHERS THEN
      log(l_calling_fn, 'Error');
      raise;

END do_primary;
--
PROCEDURE do_col_exclusions (p_tbl            IN         VARCHAR2,
                             p_schema         IN         VARCHAR2,
                             x_stmt           OUT NOCOPY VARCHAR2,
                             p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

   l_col_exclusions    FA_ASSET_TRACE_PUB.t_excl_tbl;
   l_tmp_tbl           FA_ASSET_TRACE_PUB.t_excl_tbl;
   l_stmt              VARCHAR2(32767);
   l_part_stmt         VARCHAR2(4000);
   l_col_list          VARCHAR2(1000);
   l_col_order         varchar2(2000);
   l_ord_list          VARCHAR2(4000);
   l_parsed_str        varchar2(100);

   l_calling_fn        varchar2(40)  := 'fa_asset_trace_pvt.do_col_exclusions';

BEGIN

   --Reinitialize the table.
   l_col_exclusions := l_tmp_tbl;
   l_col_exclusions := g_col_exclusions;


   l_stmt :='SELECT table_name, column_name
             FROM all_tab_columns
             WHERE owner = ''' || p_schema || ''' ' ||
            'AND table_name = '||''''||p_tbl||''''||fnd_global.local_chr(10);

   l_part_stmt := ' AND column_name not in (';

   FOR i IN g_options_tbl.FIRST .. g_options_tbl.LAST LOOP
     IF g_options_tbl(i).l_tbl = p_tbl THEN
       --exclude cases where the col_order represents the full list.
       if (nvl(g_options_tbl(i).l_fullcol_list, 'N') = 'N') then
         l_col_order := g_options_tbl(i).l_col_order;
       end if;
       l_ord_list := g_options_tbl(i).l_lcs||','||l_col_order;
       IF l_ord_list IS NOT NULL THEN
         WHILE (TRUE) LOOP
           l_parsed_str := substr(l_ord_list,1,instr(l_ord_list,',')-1);
           IF (instr(l_ord_list,',')=0 or l_parsed_str IS NULL) THEN
             IF l_ord_list IS NOT NULL THEN
               l_part_stmt :=l_part_stmt||''''||l_ord_list||''''||',';
             END IF;
             EXIT;
           ELSE
             l_part_stmt :=l_part_stmt||''''||l_parsed_str||''''||',';
             l_ord_list := substr(l_ord_list,instr(l_ord_list,',')+1,length(l_ord_list));
           END IF;
         END LOOP;
       END IF;
       EXIT;
     END IF;
   END LOOP;

   IF (l_col_exclusions.count > 0) THEN
     FOR i in l_col_exclusions.first .. l_col_exclusions.last LOOP
        IF l_col_exclusions(i).cType = 'P' THEN
           l_col_list := ' AND COLUMN_NAME NOT LIKE '||''''||l_col_exclusions(i).cValue||''''||fnd_global.local_chr(10);
           l_stmt := l_stmt||l_col_list;
        ELSE
           l_part_stmt := l_part_stmt||''''||l_col_exclusions(i).cValue||''''||',';
        END IF;
     END LOOP;
   ELSE
     log(l_calling_fn, 'No exclusions to process.');
   END IF; -- l_col_exclusions.count > 0

   l_part_stmt := substr(l_part_stmt, 1, length(l_part_stmt) -1)||')';
   l_stmt := l_stmt||l_part_stmt||fnd_global.local_chr(10);

   IF nvl(g_jx_enabled, 'N') = 'N' THEN
      l_stmt := l_stmt||' AND column_name not like '||''''||'GLOBAL_AT%'||'''';
   END IF;

   l_stmt := l_stmt||fnd_global.local_chr(10)||' Order by column_name';
   x_stmt := l_stmt;

EXCEPTION
   WHEN OTHERS THEN
      log(l_calling_fn, 'Error');
      raise;

END do_col_exclusions;
--
-- builds the header and select clauses.
-- note: it's not efficient to build the full header or select clause here
-- as there are tables that we want to have certain leading columns to identify
-- the row.
--
PROCEDURE build_stmt(p_t_tbl          IN  FA_ASSET_TRACE_PKG.t_col_tbl,
                     p_col_tbl        IN  FA_ASSET_TRACE_PKG.t_col_tbl,
                     p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null)IS

   l_t_tbl           FA_ASSET_TRACE_PKG.t_col_tbl;
   l_col_tbl         FA_ASSET_TRACE_PKG.t_col_tbl;
   l_dummy_tbl       FA_ASSET_TRACE_PUB.t_options_tbl;
   l_tmp             varchar2(100);
   l_tmpt            varchar2(100);
   l_tmp_col         varchar2(100);
   l_tmp_ctr         number;
   l_counter         number :=0;
   l_count           number :=0;
   l_idx             number:=0;
   l_select_clause   varchar2(32767);
   l_dyn_head        VARCHAR2(32767);

   l_calling_fn      varchar2(40)  := 'fa_asset_trace_pvt.build_stmt';

BEGIN
  g_tbl_hldr:= g_tmpc_tbl;
  g_sel_tbl :=g_tmp_tbl;
  g_hdr_tbl :=g_tmp_tbl;

  IF (p_t_tbl.count > 0) THEN
    l_tmp_ctr:=p_t_tbl.first;
    l_tmp := p_t_tbl(l_tmp_ctr);
  ELSIF (g_fcol_tbl is not null) THEN
    l_tmp := g_fcol_tbl;
    g_fcol_tbl := null;
  END IF;

  --Get desired column order + load the local table with the
  --ordered columns + the remaining cols (what came into the proc.)
  l_tmpt  := l_tmp;
  col_order(l_tmpt, l_col_tbl, l_t_tbl);

  l_count := l_col_tbl.count;
  IF (p_t_tbl.count > 0) THEN
   IF (p_t_tbl.count = p_col_tbl.count) THEN
     FOR tc IN p_t_tbl.first .. p_t_tbl.last LOOP
       l_count := l_count+1;
       IF p_t_tbl(tc) <> l_tmpt THEN
         l_tmpt := p_t_tbl(tc);
         col_order(l_tmpt, l_col_tbl, l_t_tbl);
         l_count := l_col_tbl.count+1;
         l_col_tbl(l_count):= p_col_tbl(tc);
         l_t_tbl(l_count):= p_t_tbl(tc);
       ELSE
         l_col_tbl(l_count):=p_col_tbl(tc);
         l_t_tbl(l_count):=p_t_tbl(tc);
       END IF;
     END LOOP;
   ELSE
     if g_print_debug then
        log(l_calling_fn, 'The table count is not equal');
        log(l_calling_fn, 'p_t_tbl.count: '||to_char(p_t_tbl.count));
        log(l_calling_fn, 'p_col_tbl.count: '||to_char(p_col_tbl.count));
     end if;
   END IF; -- (p_t_tbl.count = p_col_tbl.count)
  END IF; -- (p_t_tbl.count > 0)

  get_options (p_table     => l_tmp,
               p_opt_tbl   => l_dummy_tbl,
               p_sv_col    => l_counter);
  -- in case it comes back null from above
  l_counter := nvl(l_counter, 0);

  IF ((l_t_tbl.count > 0) and (l_t_tbl.count = l_col_tbl.count)) THEN
    FOR i IN l_col_tbl.first .. l_col_tbl.last LOOP
      l_counter :=l_counter+1;

      IF instr(l_col_tbl(i),'.') >0 THEN  --Column has table alias
        l_tmp_col :=substr(l_col_tbl(i),instr(l_col_tbl(i),'.')+1,length(l_col_tbl(i)));
      ELSE
        l_tmp_col :=l_col_tbl(i);
      END IF;

      IF (l_tmp <> l_t_tbl(i) OR l_counter >= 10) OR (i = l_t_tbl.last) THEN
        l_idx             := g_sel_tbl.count + 1;
        g_tbl_hldr(l_idx) := l_tmp;

        IF i=l_t_tbl.last THEN
          l_dyn_head:=l_dyn_head||fparse_header(l_tmp_col);
          l_select_clause := l_select_clause||fafsc(l_col_tbl(i));
        END IF;
        -- NB: -6 to take out the cariage return before the 'From' clause.
        -- If you change the cariage return representation, then change this accordingly.
        l_select_clause   := substr(l_select_clause, 1, length(l_select_clause) -6);
        l_select_clause   := l_select_clause ||'||'||''''||'</TR>'||'''';
        g_sel_tbl(l_idx)  := l_select_clause;
        l_dyn_head        := l_dyn_head ||'</TR>';
        g_hdr_tbl(l_idx)  := l_dyn_head;

        IF l_tmp = l_t_tbl(i) THEN
          l_dyn_head:='NH';
        ELSE
          l_dyn_head:=NULL;
        END IF;

        l_tmp := l_t_tbl(i);
        l_select_clause := fafsc(l_col_tbl(i));
        l_dyn_head:=l_dyn_head||fparse_header(l_tmp_col);
        l_counter :=0;
        get_options (p_table     => l_tmp,
                     p_opt_tbl   => l_dummy_tbl,
                     p_sv_col    => l_counter);
        -- in case it comes back null from above
        l_counter := nvl(l_counter, 0);
      ELSE
        l_dyn_head:=l_dyn_head||fparse_header(l_tmp_col);
        l_select_clause := l_select_clause||fafsc(l_col_tbl(i));
      END IF; -- (l_tmp <> l_t_tbl(i) OR ...
    END LOOP;
  END IF; -- ((l_t_tbl.count > 0) and ...

  IF (g_tbl_hldr.count <> g_sel_tbl.count) or (g_tbl_hldr.count <> g_hdr_tbl.count) THEN
    log(l_calling_fn, 'The table count is not equal');
    log(l_calling_fn, 'g_tbl_hldr.count: '||to_char(g_tbl_hldr.count));
    log(l_calling_fn, 'g_sel_tbl.count: '||to_char(g_sel_tbl.count));
    log(l_calling_fn, 'g_hdr_tbl.count: '||to_char(g_hdr_tbl.count));
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      log(l_calling_fn, 'Error');
      raise;

END build_stmt;
--
-- Builds final header and sql and populates the output table.
--
PROCEDURE exec_sql (p_table          IN  VARCHAR2,
                    p_sel_clause     IN  VARCHAR2,
                    p_stmt           IN  VARCHAR2,
                    p_schema         IN  VARCHAR2 DEFAULT 'FA',
                    p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

   l_sql_stmt       VARCHAR2(32767) :=p_stmt;
   l_stmt           VARCHAR2(32767);
   l_insert         VARCHAR2(4000);
   l_hdr_insert     VARCHAR2(4000);
   l_tbl            VARCHAR2(100) := p_table;
   l_orderby        VARCHAR2(1000);
   l_header         VARCHAR2(1000);
   l_anchor_cnt     NUMBER;
   l_counter        NUMBER;
   l_cursor         c_stmt;

   l_calling_fn     varchar2(40)  := 'fa_asset_trace_pvt.exec_sql';

BEGIN

   get_final_sql (p_table        => l_tbl,
                  p_sel_clause   => p_sel_clause,
                  x_header       => l_header,
                  px_sql         => l_sql_stmt,
                  p_schema       => p_schema);

   IF (substr(g_dyn_head, 1,2) = 'NH') THEN
      g_dyn_head := substr(g_dyn_head, 3, length(g_dyn_head));
      g_dyn_head := '</TABLE><TABLE BORDER="0" width="93%" cellpadding="5" BORDERCOLOR="#c9cbd3"><TR>'||l_header||g_dyn_head;
   ELSIF (substr(p_table, 1,2) = 'NH') THEN
      g_dyn_head := '</TABLE><TABLE BORDER="0" width="93%" cellpadding="5" BORDERCOLOR="#c9cbd3"><TR>'||l_header||g_dyn_head;
   ELSE
      g_dyn_head:='</TABLE><TABLE BORDER="0" width="93%" cellpadding="5" BORDERCOLOR="#c9cbd3"><TR><TD BGCOLOR="#3a5a87">
	            <font color="#ffffff"><B><A NAME="'||p_table||'">'||p_table||'</B></TD><TD><A HREF=#ANCHORS>Back To Table Anchors</A></TD>
                </TR></TABLE><TABLE BORDER="0" width="93%" cellpadding="5" BORDERCOLOR="#c9cbd3"><TR>'||l_header||g_dyn_head;

      l_anchor_cnt:=g_anchor_tbl.count+1;
      IF ((p_table <> 'NO_ANCHOR') or (l_tbl <> 'NO_ANCHOR')) THEN
         g_anchor_tbl(l_anchor_cnt):=p_table;
      END IF;
   END IF;

   l_hdr_insert := 'SELECT '||''''||g_dyn_head||''''||' FROM DUAL';
   l_stmt := l_sql_stmt;

   if g_print_debug then
      log(l_calling_fn,'l_hdr_insert is: '||l_hdr_insert);
      log(l_calling_fn,'l_stmt is: '||l_stmt);
   end if;

   DBMS_SESSION.SET_NLS('NLS_DATE_FORMAT','''DD-MON-YYYY HH24:MI:SS''');

   l_counter :=g_output_tbl.count;
   IF NVL(g_no_header,'Y')<>'Y' THEN
     l_counter := l_counter + 1;
     EXECUTE IMMEDIATE l_hdr_insert INTO g_output_tbl(l_counter);
   END IF;

   --reset g_no_header
   g_no_header:= 'N';

   OPEN l_cursor FOR l_stmt;

   l_counter :=g_output_tbl.count;
   LOOP
      l_counter := l_counter + 1;
      FETCH l_cursor INTO g_output_tbl(l_counter);
      EXIT WHEN l_cursor%NOTFOUND;
   END LOOP;

   CLOSE l_cursor;


EXCEPTION
   WHEN OTHERS THEN
      log(l_calling_fn, 'Error');
      log(l_calling_fn,'In exec-sql exception, l_stmt is: '||l_stmt);
      log(l_calling_fn,'In exec-sql exception, l_hdr_insert is: '||l_hdr_insert);
      raise;

END exec_sql;
--
-- Takes care of the correct ordering of certain tables and also provides
-- the leading columns that need to be displayed first to identify the row.
-- called from exec_sql.
--
PROCEDURE get_final_sql (p_table            IN OUT NOCOPY VARCHAR2,
                         p_sel_clause       IN            VARCHAR2,
                         x_header           OUT NOCOPY    VARCHAR2,
                         px_sql             IN OUT NOCOPY VARCHAR2,
                         p_schema           IN            VARCHAR2,
                         p_log_level_rec    IN            FA_API_TYPES.log_level_rec_type default null) IS

   l_sql_stmt        VARCHAR2(32767) := ' SELECT '||''''||'<TR>'||''''||'||';
   l_tbl             VARCHAR2(100)  := p_table;
   l_from            VARCHAR2(2000);
   l_chk_col         number;
   l_add_clause      VARCHAR2(32767);
   l_orderby         VARCHAR2(1000) := ' ORDER BY ';
   l_header          VARCHAR2(1000);
   l_order_cols      VARCHAR2(1000);
   l_leading_cols    VARCHAR2(1000);

   l_found           BOOLEAN :=FALSE;

   l_calling_fn      varchar2(40)  := 'fa_asset_trace_pvt.get_final_sql';

BEGIN

   IF p_schema <> 'NONE' THEN
     l_chk_col := check_column (p_table, p_schema);
   END IF;

   l_from := ' FROM  ' || p_table || get_param(l_chk_col);

   IF px_sql IS NOT NULL THEN
     px_sql:= l_sql_stmt||px_sql;
   ELSE
     FOR i IN g_options_tbl.FIRST .. g_options_tbl.LAST LOOP
       IF g_options_tbl(i).l_tbl = l_tbl THEN
         l_leading_cols := g_options_tbl(i).l_leading_cols;
		     l_add_clause   := g_options_tbl(i).l_add_clause;
         l_header       := g_options_tbl(i).l_lc_header;
         l_order_cols   := g_options_tbl(i).l_order_by;
         if (nvl(g_options_tbl(i).l_no_anchor, 'N') = 'Y') then
           p_table := 'NO_ANCHOR';
         end if;
         l_found        := TRUE;
         EXIT;
       END IF;
     END LOOP;

     IF NOT l_found THEN
       l_sql_stmt := l_sql_stmt;
       l_orderby  := NULL;
       l_header   := NULL;
     END IF;

     x_header   := l_header;

	 if l_order_cols is not null then
	   l_orderby  :=l_orderby||l_order_cols;
	 else
	   l_orderby := null;
	 end if;

     IF l_add_clause IS NOT NULL THEN
       px_sql := l_sql_stmt||l_leading_cols||p_sel_clause||l_add_clause||NVL(l_orderby,'');
     ELSE
       px_sql := l_sql_stmt||l_leading_cols||p_sel_clause||l_from||NVL(l_orderby,'');
     END IF;
   END IF; --px_sql not null

EXCEPTION
   WHEN OTHERS THEN
      log(l_calling_fn, 'Error');
      raise;

END get_final_sql;
--
--gets table options.
--
PROCEDURE get_options (p_table          IN     VARCHAR2,
                       p_opt_tbl        IN OUT NOCOPY FA_ASSET_TRACE_PUB.t_options_tbl,
                       p_sv_col         IN OUT NOCOPY NUMBER,
                       p_mode           IN     VARCHAR2 default null,
                       p_log_level_rec  IN     FA_API_TYPES.log_level_rec_type default null) IS

   l_count         NUMBER:=1;

   l_calling_fn    varchar2(40)  := 'fa_asset_trace_pvt.get_options';

BEGIN

   FOR i IN g_options_tbl.FIRST .. g_options_tbl.LAST LOOP
     IF g_options_tbl(i).l_tbl = p_table THEN
       p_sv_col := g_options_tbl(i).l_num_cols;
       EXIT;
     END IF;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
     log(l_calling_fn, 'Error');
     raise;

END get_options;
--
--Get profile and system options.
--
PROCEDURE get_system_options (p_sys_opt_tbl    IN  VARCHAR2,
                              p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

   l_userid     NUMBER;
   l_respid     fnd_profile_option_values.level_value%type;
   l_appid      fnd_profile_option_values.level_value_application_id%type;
   l_resp_name  VARCHAR2(100);
   l_stmt       VARCHAR2(32767);
   l_counter    NUMBER :=0;
   l_cursor     c_stmt;
   l_col_tbl    FA_ASSET_TRACE_PKG.t_col_tbl;
   l_t_tbl      FA_ASSET_TRACE_PKG.t_col_tbl;

   l_calling_fn varchar2(40)  := 'fa_asset_trace_pvt.get_system_options';

BEGIN
   l_appid     := FND_GLOBAL.resp_appl_id; log(l_calling_fn, 'l_appid: '||l_appid);
   l_userid    := fnd_global.user_id; log(l_calling_fn, 'l_userid: '||l_userid);
   l_respid    := Fnd_Global.Resp_Id; log(l_calling_fn, 'l_respid: '||l_respid);

   if (nvl(g_use_utl_file, 'Y')='N') then
     l_stmt :=fafsc('fpon.profile_option_name')||fafsc('site_pov.profile_option_value');
     l_stmt :=l_stmt||fafsc('appl_pov.profile_option_value')||fafsc('resp_pov.profile_option_value');
     l_stmt :=l_stmt||fafsc('user_pov.profile_option_value');
     l_stmt :=substr(l_stmt, 1, length(l_stmt) -6)||'||'||''''||'</TR>'||'''';
     l_stmt :=l_stmt||' from fnd_profile_options fpon, fnd_profile_option_values user_pov
        , fnd_profile_option_values resp_pov, fnd_profile_option_values appl_pov
        , fnd_profile_option_values site_pov
        where fpon.profile_option_id = user_pov.profile_option_id(+)
        and fpon.application_id = user_pov.application_id(+)
        and fpon.profile_option_id = resp_pov.profile_option_id(+)
        and fpon.application_id = resp_pov.application_id(+)
        and fpon.profile_option_id = appl_pov.profile_option_id(+)
        and fpon.application_id = appl_pov.application_id(+)
        and fpon.profile_option_id = site_pov.profile_option_id(+)
        and fpon.application_id = site_pov.application_id(+)
        and fpon.application_id in (140,'||l_appid||
        ') and resp_pov.LEVEL_VALUE(+) = '||l_respid||
        ' and user_pov.LEVEL_VALUE(+) = '||l_userid||
        ' and site_pov.level_id(+) = 10001
        and appl_pov.level_id(+) = 10002
        and resp_pov.level_id(+) = 10003
        and user_pov.level_id(+) = 10004
        and fpon.start_date_active  <= sysdate
        and nvl(fpon.end_date_active, sysdate) >= sysdate';

     g_dyn_head := fparse_header('Profile_Option')||fparse_header('Site_level')
        ||fparse_header('Application_level')||fparse_header('Responsibility_level')
        ||fparse_header('User_level')||'</TR>';

     exec_sql (p_table       => 'SYSTEM_PROFILE_OPTIONS',
               p_sel_clause  => NULL,
               p_stmt        => l_stmt,
			         p_schema      => 'NONE');
   else
     log(l_calling_fn, 'Not doing profiles cause u seem to be calling from backend');
   end if;

   if (p_sys_opt_tbl is not null) then
     l_stmt :=NULL;
     do_col_exclusions (p_sys_opt_tbl,nvl(g_schema,'FA'), l_stmt);

     OPEN l_cursor FOR l_stmt;
     FETCH l_cursor BULK COLLECT INTO l_t_tbl, l_col_tbl;
     CLOSE l_cursor;

     build_stmt(p_t_tbl => l_t_tbl, p_col_tbl => l_col_tbl);

     FOR j IN g_sel_tbl.first .. g_sel_tbl.last LOOP
        l_stmt := g_sel_tbl(j)||' FROM '||p_sys_opt_tbl;
        g_dyn_head := g_hdr_tbl(j);

        exec_sql (p_table        => p_sys_opt_tbl,
                  p_sel_clause   => NULL,
                  p_stmt         => l_stmt,
                  p_schema       => 'NONE');
     END LOOP;
   end if;
   log(l_calling_fn, 'Done with profiles');

EXCEPTION
   WHEN OTHERS THEN
      log(l_calling_fn, 'Error');
      raise;

END get_system_options;
--
FUNCTION get_param (p_numcol         IN  number,
                    p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) return VARCHAR2 IS

  l_pclause      VARCHAR2(500) := ' WHERE ';
  l_sclause      VARCHAR2(500);
  l_cnt          NUMBER :=0;

  l_calling_fn   VARCHAR2(40)  := 'fa_asset_trace_pvt.get_param';

BEGIN

    for i in g_param_tbl.first .. g_param_tbl.last loop
	   l_cnt := l_cnt + 1;
	   if (l_cnt = 1) then
	     if (g_param_tbl(i).cValue is null) and (g_param_tbl(i).nValue is not null) then
           l_pclause := l_pclause || g_param_tbl(i).param_column || ' = ' ||g_param_tbl(i).nValue;
	     elsif (g_param_tbl(i).nValue is null) and (g_param_tbl(i).cValue is not null) then
           l_pclause := l_pclause || g_param_tbl(i).param_column || ' = ' ||''''||g_param_tbl(i).cValue||'''';
	     end if;
	   else
	     if (g_param_tbl(i).cValue is null) and (g_param_tbl(i).nValue is not null) then
           l_sclause := l_sclause || g_param_tbl(i).param_column || ' = ' ||g_param_tbl(i).nValue;
	     elsif (g_param_tbl(i).nValue is null) and (g_param_tbl(i).cValue is not null) then
           l_sclause := l_sclause || g_param_tbl(i).param_column || ' = ' ||''''||g_param_tbl(i).cValue||'''';
	     end if;
	   end if;
    end loop;

	if p_numcol <> -99 then
      if p_numcol = 0 then --Table only has primary column
	    return l_pclause;
	  elsif p_numcol = 2 then --Table has both primary and secondary columns
	    return l_pclause ||' AND '|| l_sclause;
	  else --Table only has secondary column
	    return ' WHERE '||l_sclause;
	  end if;
	else
	  return '';
	end if;

EXCEPTION
   WHEN OTHERS THEN
      log(l_calling_fn,'Error');
	    log(l_calling_fn,'l_pclause is: '||l_pclause);
      log(l_calling_fn,'l_sclause is: '||l_sclause);
      raise;

END get_param;
--
--parse the desired colum order for tables in options tbl.
--
PROCEDURE col_order (x_table          IN            VARCHAR2,
                     x_col_tbl        IN OUT NOCOPY FA_ASSET_TRACE_PKG.t_col_tbl,
                     x_t_tbl          IN OUT NOCOPY FA_ASSET_TRACE_PKG.t_col_tbl,
                     p_log_level_rec  IN            FA_API_TYPES.log_level_rec_type default null) IS

   l_ord_list   varchar2(2000);
   l_parsed_str varchar2(100);
   l_counter    number:=0;
   l_idx        NUMBER:=0;
   l_col_tbl    FA_ASSET_TRACE_PKG.t_col_tbl;
   l_t_tbl      FA_ASSET_TRACE_PKG.t_col_tbl;
   l_found      BOOLEAN :=FALSE;

   l_calling_fn      varchar2(40)  := 'fa_asset_trace_pvt.col_order';

BEGIN

   l_col_tbl := g_tmpc_tbl;
   l_t_tbl := g_tmpc_tbl;

   FOR i IN g_options_tbl.FIRST .. g_options_tbl.LAST LOOP
      IF g_options_tbl(i).l_tbl = x_table THEN
         IF g_options_tbl(i).l_col_order IS NOT NULL THEN
          --  log(l_calling_fn,'x_table: '||x_table);
            l_ord_list :=g_options_tbl(i).l_col_order;
           -- log(l_calling_fn,'l_ord_list: '||l_ord_list);
            l_found  := TRUE;
         END IF;
         EXIT;
      END IF;
   END LOOP;

   IF l_found THEN
      WHILE (TRUE) LOOP
         l_parsed_str := substr(l_ord_list,1,instr(l_ord_list,',')-1);
         l_counter := l_counter+1;
         IF (instr(l_ord_list,',')=0 or l_parsed_str IS NULL) THEN
            l_col_tbl(l_counter):=l_ord_list;
            l_t_tbl(l_counter):=x_table;
            EXIT;
         ELSE
            l_col_tbl(l_counter):=l_parsed_str;
            l_t_tbl(l_counter):=x_table;
            l_ord_list := substr(l_ord_list,instr(l_ord_list,',')+1,length(l_ord_list));
         END IF;
      END LOOP;

      l_idx :=x_col_tbl.count+1;
      FOR j IN l_col_tbl.first .. l_col_tbl.last LOOP
         x_col_tbl(l_idx) := l_col_tbl(j);
         x_t_tbl(l_idx)   := l_t_tbl(j);
         l_idx            := l_idx+1;
      END LOOP;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     log(l_calling_fn, 'Error');
     raise;

END col_order;
--
-- Used to check if the table contains data.
-- If not, then no need to build and run statements for it.
--
FUNCTION get_tbl_cnt (p_table          IN  VARCHAR2,
                      p_stmt           IN  VARCHAR2,
                      p_schema         IN  VARCHAR2,
                      p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN IS

   l_sql_stmt      VARCHAR2(4000);
   l_stmt          VARCHAR2(32767);
   l_count         number;
   l_chk_col       number;

   l_calling_fn    varchar2(40)  := 'fa_asset_trace_pvt.get_tbl_cnt';

BEGIN

   IF (p_schema <> 'NONE') and (p_table is not null) THEN
     l_chk_col := check_column (p_table, p_schema);
   END IF;

   l_sql_stmt :=  ' SELECT count(*) FROM ' || p_table || get_param(l_chk_col);

   l_stmt := NVL(p_stmt, l_sql_stmt);
   if g_print_debug then
     log(l_calling_fn, l_stmt);
   end if;

   EXECUTE IMMEDIATE l_stmt INTO l_count;

   IF l_count > 0 THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

EXCEPTION WHEN OTHERS THEN
    log(l_calling_fn, 'Error');
    raise;

END get_tbl_cnt;

--Checks whether primary or secondary driving columns exist in the table being processed.

FUNCTION check_column (p_table          IN  VARCHAR2,
                       p_schema         IN  VARCHAR2 DEFAULT 'FA',
                       p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) RETURN NUMBER IS

   l_primary          NUMBER:=0;
   l_secondary        NUMBER;
   l_both             NUMBER;
   l_primary_column   VARCHAR2(40);
   l_secondary_column VARCHAR2(40);
   l_stmt             VARCHAR2(4000);

   l_calling_fn       varchar2(40)  := 'fa_asset_trace_pvt.check_column';

BEGIN

   FOR i IN g_param_tbl.first .. g_param_tbl.last LOOP
     l_primary_column := NVL(l_primary_column, g_param_tbl(i).param_column);
     l_secondary_column := g_param_tbl(i).param_column;
   END LOOP;

   IF p_schema <> 'NONE' THEN
     SELECT count(*)
     INTO l_both
     FROM dba_tab_columns
     WHERE column_name IN (l_primary_column,l_secondary_column)
     AND owner = p_schema
     AND table_name = p_table;
   END IF;

   IF l_both > 0 THEN
     IF l_both = 2 THEN
       RETURN l_both;
     ELSE

       SELECT count(*)
       INTO l_secondary
       FROM dba_tab_columns
       WHERE column_name = l_secondary_column
       AND owner = p_schema
       AND table_name = p_table;

       IF l_secondary = 1 THEN
         RETURN l_secondary;
       ELSIF l_secondary = 0 THEN
         RETURN l_primary;
       END IF;
     END IF;
   ELSE
     Return -99; -- could be some setup table which has neither columns
     log(l_calling_fn,'table '|| p_table ||' is not in schema');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      log(l_calling_fn, 'Error');
      raise;

END check_column;
--
--
FUNCTION fafsc (p_col            IN  VARCHAR2,
                p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) RETURN VARCHAR2 IS

   l_out VARCHAR2(500);

BEGIN
   IF p_col IS NOT NULL THEN
      l_out := ''''||'<TD bgcolor="#f2f2f5">'||''''||'||'||p_col||'||'||''''||'</TD>'||''''||'||''''||';
      RETURN l_out;
   ELSE
      RETURN NULL;
   END IF;

END fafsc;
--
-- Used to parse the column headers for html output.
--
FUNCTION fparse_header(p_in_str         IN  VARCHAR2,
                       p_add_html       IN  VARCHAR2 DEFAULT 'Y',
                       p_break_size     IN  NUMBER DEFAULT 14,
                       p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) RETURN VARCHAR2 IS

   l_start          NUMBER:= 1;
   l_prior_start    NUMBER:= 0;
   l_out_string     VARCHAR2(500);
   l_parsed_str     VARCHAR2(500);
   l_checkStr       VARCHAR2(1);
   l_flag           VARCHAR2(1);
   l_first_run      BOOLEAN := TRUE;
   l_break_size     NUMBER := p_break_size; -- Maximum break size.

   l_calling_fn     varchar2(40)  := 'fa_asset_trace_pvt.fparse_header';


BEGIN

   IF (length(p_in_str) <= l_break_size) THEN
     if p_add_html = 'N' then
	   l_out_string := p_in_str;
	 else
       l_out_string :='<TD bgcolor="#cfe0f1"><p align="center"><font color="#343434"><b>'||p_in_str||'</b></font></p></TD>';
     end if;
	 return (l_out_string);
   ELSIF (p_in_str IS NOT NULL ) THEN

      IF instr(p_in_str,'_')> l_break_size THEN
         l_break_size := instr(p_in_str,'_',l_break_size)-1;
      END IF;

      WHILE (TRUE) LOOP
         -- we have 3 cases:
         --  1. we are passing a truncated string ==> 'T'
         --  2. we are passing a meaningful string like 'HEAD_OUT_ID' ==> 'M'
         --  3. we are passing the last string ==> 'E'

         l_parsed_str := SUBSTR(p_in_str, l_start, l_break_size);
         l_checkStr := SUBSTR(p_in_str, l_start + l_break_size, 1);

         IF (l_checkStr = '_') THEN   -- 'M'
            l_out_string := l_out_string || l_parsed_str ||'<BR>';
            l_start := l_start + length(l_parsed_str) +1;
         ELSIF (l_checkStr IS NOT NULL) THEN   -- 'T'
            l_out_string := l_out_string || substr(l_parsed_str, 1, instr(l_parsed_str,'_', -1) -1) ||'<BR>';
            l_start := l_start + length( substr(l_parsed_str, 1, instr(l_parsed_str,'_', -1) -1) ) +1 ;
         ELSE    -- 'E'
            l_out_string := l_out_string || l_parsed_str;
            EXIT;
         END IF;

      END LOOP;
      if p_add_html = 'N' then
	    l_out_string := l_out_string;
	  else
        l_out_string :='<TD bgcolor="#cfe0f1"><p align="center"><font color="#343434"><b>'||l_out_string||'</b></font></p></TD>';
      end if;
	  RETURN (l_out_string);

   ELSE
      RETURN ('No strings to process');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      log(l_calling_fn, 'Error');
      raise;

END fparse_header;
--
PROCEDURE build_anchors (p_t_tbl          IN  FA_ASSET_TRACE_PKG.t_col_tbl,
                         p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

   l_t_tbl    FA_ASSET_TRACE_PKG.t_col_tbl := p_t_tbl;
   l_anchor   VARCHAR2(32767);
   l_tbl      VARCHAR2(150);
   l_count    number:=0;

   l_calling_fn  varchar2(35)  := 'fa_asset_trace_pvt.build_anchors';

BEGIN

   l_anchor :='<TABLE BORDER=0 width="93%" cellpadding="5" BORDERCOLOR="#c9cbd3"><TR><TD COLSPAN=7 BGCOLOR="#3a5a87"><font color="#ffffff"
              face=arial><A NAME=ANCHORS></A><B>Table Anchors</B></TD></TR><TR>';

   FOR i IN l_t_tbl.first .. l_t_tbl.last LOOP
      l_count:=l_count+1;
	    l_tbl := fparse_header(l_t_tbl(i),'N');
	    --l_tbl := l_t_tbl(i);
      IF (l_count = 7) OR (i = l_t_tbl.last) THEN
         l_anchor:=l_anchor||'<TD bgcolor="#f2f2f5"><A HREF="#'||l_t_tbl(i)||'"><font color="#147590">'||l_tbl||'</font></A></TD></TR><TR>';
         l_count:=0;
      ELSE
         l_anchor:=l_anchor||'<TD bgcolor="#f2f2f5"><A HREF="#'||l_t_tbl(i)||'"><font color="#147590">'||l_tbl||'</font></A></TD>';
      END IF;
   END LOOP;

   g_anchor := l_anchor;

EXCEPTION
   WHEN OTHERS THEN
      log(l_calling_fn, 'Error');
	  log(l_calling_fn, l_tbl);
      raise;

END build_anchors;
--
-- writes output to out file.
--
PROCEDURE save_output(p_calling_prog   IN  VARCHAR2,
                      p_use_utl_file   IN  VARCHAR2,
                      p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

   utl_file_dir   VARCHAR2(2000);
   outfile        UTL_FILE.FILE_TYPE;
   l_filename     VARCHAR2(30);
   l_position     NUMBER(10);
   l_length       NUMBER(10);
   l_cursor       c_stmt;
   l_no_rec       VARCHAR2(10000);
   l_stmt         VARCHAR2(2000);
   l_header       VARCHAR2(2000);
   l_output       VARCHAR2(32767);
   l_title        VARCHAR2(100);
   l_tmp_tbl      VARCHAR2(100):='NOTHING';
   l_app_version  fnd_product_groups.release_name%type;
   l_primary_col  VARCHAR2(40);
   l_sec_col      VARCHAR2(40);

   l_cnt          number;

   l_calling_fn   varchar2(80)  := 'fa_asset_trace_pvt.save_output';

BEGIN
   log(l_calling_fn, 'Entered save_output');

   l_no_rec :='<TABLE BORDER=0 width="93%" cellpadding="5" BORDERCOLOR="#c9cbd3"><TR><TD BGCOLOR="#3a5a87"><font color="#ffffff" face=arial>';

   l_cnt := g_param_tbl.first;
   --check just in case we messed up somehow
   if g_param_tbl.exists(l_cnt) then
    l_primary_col := to_char(NVL(g_param_tbl(l_cnt).cValue, g_param_tbl(g_param_tbl.first).nValue));
   end if;
   l_cnt := l_cnt + 1;
   if g_param_tbl.exists(l_cnt) then
    l_sec_col := to_char(NVL(g_param_tbl(l_cnt).cValue, g_param_tbl(g_param_tbl.first).nValue));
   end if;

   l_title := nvl(FND_GLOBAL.APPLICATION_NAME, 'Assets')||':  '||p_calling_prog;
   --margin-left: 5%; margin-right: 5%; font-style: normal
   l_header := '<html><head><title>'||nvl(FND_GLOBAL.APPLICATION_SHORT_NAME,'FA ')||'- Trace Utility </title>
    <STYLE TYPE="text/css"> TD {font-size: 8pt; font-family: arial; font-style: normal} </STYLE></head>
    <body bgcolor="#ffffff"><H2><b><font color="#3a5a87">'||l_title||'</font></b></H2><BR>
    <table border="0" width="93%" cellpadding="5" bordercolor="#c9cbd3">';

   if (p_use_utl_file = 'Y') then
     if (substr(p_calling_prog,1,7)='FATRACE') then
       --this is being called by the sla subrequest
       --if p_calling_prog is changed, change above condition
       l_filename := 'GTUSLA_'||replace(ltrim(rtrim(l_primary_col)),' ','_') || '_' || replace(l_sec_col,' ','_') ||'.html';
       log(l_calling_fn, 'SLA output file: '||l_filename);
     else
       l_filename := 'GTU_'||replace(ltrim(rtrim(l_primary_col)),' ','_') || '_' || replace(l_sec_col,' ','_') ||'.html';
     end if;

     ocfile (g_outfile, l_filename,'O');
   end if;

   l_header := l_header||g_temp_head; --add banner area content.

   if (p_use_utl_file = 'Y') then
     UTL_FILE.PUT_LINE(g_outfile, l_header);
   else
     fnd_file.put(FND_FILE.OUTPUT, l_header);
   end if;

   build_anchors(g_anchor_tbl);

   l_cnt := g_output_tbl.first + 1; --do this to control the spot for table anchors

   if (p_use_utl_file = 'Y') then
     UTL_FILE.PUT_LINE(g_outfile,g_anchor);
     FOR i IN g_output_tbl.first .. g_output_tbl.last LOOP
       UTL_FILE.PUT_LINE(g_outfile,g_output_tbl(i));
       --UTL_FILE.NEW_LINE(g_outfile,1);
     END LOOP;
   else
     fnd_file.put(FND_FILE.OUTPUT,g_anchor);
	   FOR i IN g_output_tbl.first .. g_output_tbl.last LOOP
       fnd_file.put(FND_FILE.OUTPUT,g_output_tbl(i));
       fnd_file.new_line(FND_FILE.OUTPUT,1);
     END LOOP;
   end if;

   l_no_rec := l_no_rec ||'<B>The following table(s) contain no data for this asset:</B></TD></TR>';
   IF g_no_rec_tbl.count > 0 THEN
      FOR i IN g_no_rec_tbl.first .. g_no_rec_tbl.last LOOP
         IF g_no_rec_tbl(i) <> l_tmp_tbl THEN
            l_no_rec := l_no_rec ||'<TR><TD bgcolor="#f2f2f5"><font color="#ed1c24">'||g_no_rec_tbl(i)||'</font></TD></TR><TR>';
            l_tmp_tbl:=g_no_rec_tbl(i);
         END IF;
      END LOOP;
      l_no_rec := substr(l_no_rec, 1, length(l_no_rec) -4)||'</TABLE>';
	  if p_use_utl_file = 'Y' then
        UTL_FILE.PUT_LINE(g_outfile,l_no_rec);
      else
        fnd_file.put(FND_FILE.OUTPUT,l_no_rec);
      end if;

   END IF;

   if (p_use_utl_file = 'Y') then
     UTL_FILE.PUT_LINE(g_outfile,' </body> </html> ');
     log(l_calling_fn, 'Trying to close out file');
     ocfile (g_outfile, null,'C');
     --g_use_utl_file := 'N'; /* have no clue why resetting this generates an error; so, leaving alone for now. */
   else
     fnd_file.put(FND_FILE.OUTPUT,' </body> </html> ');
   end if;
   g_output_tbl.delete; g_no_rec_tbl.delete;
   log(l_calling_fn, 'Successfully leaving save_output');

EXCEPTION
  WHEN UTL_FILE.WRITE_ERROR then
    -- RAISE_APPLICATION_ERROR(-20104,'Write Error');
     log(l_calling_fn, 'Write Error.');
  WHEN UTL_FILE.READ_ERROR then
     --RAISE_APPLICATION_ERROR(-20105,'Read Error');
     log(l_calling_fn, 'Read Error.');
  WHEN UTL_FILE.INTERNAL_ERROR then
     --RAISE_APPLICATION_ERROR(-20106,'Internal Error');
     log(l_calling_fn, 'Internal Error.');
  WHEN OTHERS THEN
     log(l_calling_fn, 'Unexpected error.');
     raise;

END save_output;
--
--Message logging routine
--
PROCEDURE log(p_calling_fn     IN  VARCHAR2,
              p_msg            IN  VARCHAR2 default null,
              p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

  l_module    varchar2(150);

BEGIN

  if ((g_use_utl_file = 'Y') and (utl_file.is_open(g_logfile) = TRUE)) then
    UTL_FILE.PUT_LINE(g_logfile,p_calling_fn|| ': '||p_msg);
  else
    Fnd_File.Put_Line (Fnd_File.Log, p_calling_fn|| ': '||p_msg);
  end if;
  --
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_module := FND_GLOBAL.APPLICATION_SHORT_NAME||'.PLSQL.'||p_calling_fn;
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, p_msg);
  END IF;

EXCEPTION
   when utl_file.invalid_path then
      ocfile (g_logfile, null,'C');
   when utl_file.write_error then
      ocfile (g_logfile, null,'C');
   when utl_file.invalid_operation then
      ocfile (g_logfile, null,'C');
   when others then
      ocfile (g_logfile, null,'C');

END log;
--
PROCEDURE ocfile (p_handle IN OUT NOCOPY utl_file.file_type,
                  p_file   IN            VARCHAR2,
                  p_mode   IN            VARCHAR2) IS

  l_calling_fn   varchar2(80)  := 'fa_asset_trace_pvt.ocfile';
BEGIN

  if (p_mode = 'C') then
    if (utl_file.is_open(p_handle) = TRUE) then
      log(l_calling_fn, 'About to close file');
      utl_file.fclose(p_handle);
    end if;
  elsif (p_mode = 'O') then
    if (utl_file.is_open(p_handle) = FALSE) then
      p_handle := UTL_FILE.FOPEN(location  => 'GTU_DIR',
                                 filename  => p_file,
                                 open_mode => 'w',
                                 max_linesize =>32767);
    end if;
  end if;
EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
     --RAISE_APPLICATION_ERROR(-20100,'Invalid Path');
     log(l_calling_fn, 'Invalid Path.');
  WHEN UTL_FILE.INVALID_MODE THEN
     --RAISE_APPLICATION_ERROR(-20101,'Invalid Mode');
     log(l_calling_fn, 'Invalid Mode.');
  WHEN UTL_FILE.INVALID_OPERATION then
     --RAISE_APPLICATION_ERROR(-20102,'Invalid Operation');
     log(l_calling_fn, 'Invalid Operation.');
  WHEN UTL_FILE.INVALID_FILEHANDLE then
     --RAISE_APPLICATION_ERROR(-20103,'Invalid Filehandle');
     log(l_calling_fn, 'Invalid Filehandle.');
  WHEN UTL_FILE.INTERNAL_ERROR then
     --RAISE_APPLICATION_ERROR(-20106,'Internal Error');
     log(l_calling_fn, 'Internal Error.');
  WHEN OTHERS THEN
     log(l_calling_fn, 'Unexpected error in file operation.');
     raise;
END ocfile;
--

END FA_ASSET_TRACE_PVT;

/
