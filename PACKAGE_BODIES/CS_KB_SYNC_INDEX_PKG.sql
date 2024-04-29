--------------------------------------------------------
--  DDL for Package Body CS_KB_SYNC_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SYNC_INDEX_PKG" AS
/* $Header: csksyncb.pls 120.0.12010000.2 2009/07/20 13:38:07 gasankar ship $ */

  -- ***********************************
  -- Declarations for private procedures
  -- ***********************************
   -- bug 3359609
   Sync_Set_Index_Error EXCEPTION;
   Sync_Element_Index_Error EXCEPTION;

  /*
   * Immediate_Mark_Soln_And_Stmts
   *  Mark text index column dirty for reindexing for a solution
   *  version and all of its statements.
   */
  PROCEDURE Immediate_Mark_Soln_And_Stmts( p_solution_id number );

  /*
   * Immediate_Mark_Stmt_And_Solns
   *  Mark text index column dirty for reindexing for a statement
   *  and all of the solutions it is used in.
   */
  PROCEDURE Immediate_Mark_Stmt_And_Solns( p_statement_id number );

  -- ********************************
  -- Public Procedure Implementations
  -- ********************************

  /*
   * Populate_Soln_Content_Cache
   *  Populate a solution's content cache, for a given
   *  language, with the cacheable synthesized text content
   */
  procedure Populate_Soln_Content_Cache
  ( p_solution_id in number, p_lang in varchar2 )
  is
    l_cache   clob;
    l_content clob;
    l_content_len number;
    l_dest_pos number := 1;
    l_src_pos number := 1;
  begin
    -- First fetch the existing content cache LOB locator
    select content_cache into l_cache
    from cs_kb_sets_tl
    where set_id = p_solution_id and language = p_lang
    for update;

    -- If the LOB locator is null, we need to initialize one
    if( l_cache is null ) then
      -- populate cache LOB locator with an empty CLOB
      update cs_kb_sets_tl
      set content_cache = empty_clob()
      where set_id = p_solution_id and language = p_lang;

      -- re-fetch the cache lob locator
      select content_cache into l_cache
      from cs_kb_sets_tl
      where set_id = p_solution_id and language = p_lang
      for update;
    end if;

    -- Create a temporary CLOB and populate it with the synthesized
    -- solution content, to be indexed
    dbms_lob.createtemporary(l_content, TRUE);
    cs_kb_ctx_pkg.synthesize_solution_content
      ( p_solution_id, p_lang, l_content );

    -- Copy the synthesized solution content into the content cache
    -- through the LOB locator
    l_content_len := dbms_lob.getlength(l_content);
    dbms_lob.open(l_cache, DBMS_LOB.LOB_READWRITE);
    dbms_lob.copy(l_cache, l_content, l_content_len, l_dest_pos, l_src_pos );
    dbms_lob.close(l_cache);

    -- Free up the temporary CLOB created earlier
    dbms_lob.freetemporary(l_content);
  end Populate_Soln_Content_Cache;


  /*
   * Populate_Soln_Content_Cache
   *  Populate a solution's content cache, for all installed
   *  languages, with the cacheable synthesized text content
   */
  procedure Populate_Soln_Content_Cache( p_solution_id in number )
  is
    l_language_code varchar2(4);

    -- 01-Dec-2003 Removed into from cursor for 8.1.7 compliance
    cursor installed_langs is
      select language_code --into l_language_code
      from fnd_languages where installed_flag in ('I','B');
  begin
    -- For each installed language, populate the solution content
    -- cache CLOB
    for language in installed_langs
    loop
      Populate_Soln_Content_Cache( p_solution_id, language.language_code );
    end loop;
  end Populate_Soln_Content_Cache;


  --Start of 12.1.3
   /*
   * Populate_Soln_Content_Cache
   *  Populate a solution's content cache, for a given
   *  language, with the cacheable synthesized text content
   */
  procedure Pop_Soln_Attach_Content_Cache
  ( p_solution_id in number, p_lang in varchar2 )
  is
    l_attach_cache   clob;
    l_attach_content clob;
    l_attach_content_len number;
    l_attach_dest_pos number := 1;
    l_attach_src_pos number := 1;
  begin
    -- First fetch the existing content cache LOB locator
    select attachment_content_cache into l_attach_cache
    from cs_kb_sets_tl
    where set_id = p_solution_id and language = p_lang
    for update;

    -- If the LOB locator is null, we need to initialize one
    if( l_attach_cache is null ) then
      -- populate cache LOB locator with an empty CLOB
      update cs_kb_sets_tl
      set attachment_content_cache = empty_clob()
      where set_id = p_solution_id and language = p_lang;

      -- re-fetch the cache lob locator
      select attachment_content_cache into l_attach_cache
      from cs_kb_sets_tl
      where set_id = p_solution_id and language = p_lang
      for update;
    end if;

    -- Create a temporary CLOB and populate it with the synthesized
    -- solution content, to be indexed
    dbms_lob.createtemporary(l_attach_content, TRUE);
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.csksyncb.pls',
                         'Before cs_kb_ctx_pkg.synthesize_sol_attach_content - ');
        END IF;
    cs_kb_ctx_pkg.synthesize_sol_attach_content
      ( p_solution_id, p_lang, l_attach_content );

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.csksyncb.pls',
                         'After cs_kb_ctx_pkg.synthesize_sol_attach_content - ');
        END IF;

    -- Copy the synthesized solution content into the content cache
    -- through the LOB locator
    l_attach_content_len := dbms_lob.getlength(l_attach_content);
    dbms_lob.open(l_attach_cache, DBMS_LOB.LOB_READWRITE);
    dbms_lob.copy(l_attach_cache, l_attach_content, l_attach_content_len, l_attach_dest_pos, l_attach_src_pos );
    dbms_lob.close(l_attach_cache);

    -- Free up the temporary CLOB created earlier
    dbms_lob.freetemporary(l_attach_content);
  end Pop_Soln_Attach_Content_Cache;


  /*
   * Populate_Soln_Content_Cache
   *  Populate a solution's content cache, for all installed
   *  languages, with the cacheable synthesized text content
   */
  procedure Pop_Soln_Attach_Content_Cache( p_solution_id in number )
  is
    l_language_code varchar2(4);

    -- 01-Dec-2003 Removed into from cursor for 8.1.7 compliance
    cursor installed_langs is
      select language_code --into l_language_code
      from fnd_languages where installed_flag in ('I','B');
  begin
    -- For each installed language, populate the solution content
    -- cache CLOB
    for language in installed_langs
    loop
      Pop_Soln_Attach_Content_Cache( p_solution_id, language.language_code );
    end loop;
  end Pop_Soln_Attach_Content_Cache;
--End of 12.1.3

  /*
   * Request_Sync_Index
   *  This procedure submits a concurrent request
   *  to sync KM indexes.
   *
   * Notes:
   * As ad-hoc KM Sync-Index requests are submitted, we expect
   * one to be running, and further requests to be pending.
   * We only need ONE pending request, not a whole backlog. So
   * here, were will check if there is already a pending request,
   * simply don't submit another one.
   * Note that when we check for pending requests, we should
   * filter out SCHEDULED pending requests, which may not run
   * for some time, depending on the schedule. We are detecting
   * for pending requests that will get run as soon as possible.
   */
  PROCEDURE Request_Sync_KM_Indexes
  ( x_request_id    OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2 )
  is
    l_request_id           NUMBER;
    l_return_status        VARCHAR2(1) := fnd_api.G_RET_STS_ERROR;
  begin
   -- bug 3359609
    Request_Sync_Set_index(l_request_id,
                           l_return_status);
    IF l_return_status <> fnd_api.G_RET_STS_SUCCESS
    THEN
       RAISE Sync_Set_Index_Error;
    END IF;

    Request_Sync_Element_Index(l_request_id,
                               l_return_status);
    IF l_return_status <> fnd_api.G_RET_STS_SUCCESS
    THEN
       RAISE Sync_Element_Index_Error;
    END IF;
    x_request_id := l_request_id;
    x_return_status := l_return_status;

  exception
    when others then
      x_request_id := 0;
      x_return_status := fnd_api.G_RET_STS_ERROR;
  end Request_Sync_KM_Indexes;


  /*
   * Request_Mark_Idx_on_Sec_Change
   *  This procedure submits a concurrent request
   *  to mark the solution and statement text indexes when
   *  KM security setup changes.
   */
  PROCEDURE Request_Mark_Idx_on_Sec_Change
  ( p_security_change_action_type IN VARCHAR2,
    p_parameter1                  IN NUMBER default null,
    p_parameter2                  IN NUMBER default null,
    x_request_id                  OUT NOCOPY NUMBER,
    x_return_status               OUT NOCOPY VARCHAR2 )
  is
    l_request_id           NUMBER;
    l_CS_appsname          VARCHAR2(2) := 'CS';
    l_mark_idx_progname    VARCHAR2(30) := 'CS_KB_MARK_IDX_ON_SEC_CHG';
--    l_num_pending_requests NUMBER := 0;
    l_return_status        VARCHAR2(1) := fnd_api.G_RET_STS_ERROR;
  begin

    l_request_id :=
      fnd_request.submit_request
      ( application => l_CS_appsname,
        program     => l_mark_idx_progname,
        description => null,
        start_time  => null,
        sub_request => FALSE,
        argument1   => p_security_change_action_type,
        argument2   => p_parameter1,
        argument3   => p_parameter2 );

    if( l_request_id > 0 )
    then
      l_return_status := fnd_api.G_RET_STS_SUCCESS;
    else
      l_return_status := fnd_api.G_RET_STS_ERROR;
    end if;

    x_request_id := l_request_id;
    x_return_status := l_return_status;
  exception
    when others then
      x_request_id := 0;
      x_return_status := fnd_api.G_RET_STS_ERROR;
  end Request_Mark_Idx_on_Sec_Change;


  /*
   * Mark_Idxs_on_Pub_Soln
   *  Mark all appropriate text indexes after a solution is
   *  published.
   */
  PROCEDURE Mark_Idxs_on_Pub_Soln( p_solution_number varchar2 )
  is
    l_new_soln_id number;
    l_prev_pub_soln_id number;

    CURSOR Get_Out IS
     select set_id --into l_prev_pub_soln_id
     from cs_kb_sets_b
     where set_number = p_solution_number
     and status = 'OUT'
     order by creation_date desc;

  begin
    -- First fetch the solution id for the newly
    -- published version of this solution
    select set_id into l_new_soln_id
    from cs_kb_sets_b
    where set_number = p_solution_number
      and status = 'PUB';

    -- IMMEDIATE mark newly published solution and its
    -- statements for indexing
    if( l_new_soln_id is not null )
    then
      Immediate_Mark_Soln_And_Stmts( l_new_soln_id );
    end if;

    -- Fetch the solution id for the previous published
    -- version of this solution, if there is one
    --select max(set_id) into l_prev_pub_soln_id
    --from cs_kb_sets_b
    --where set_number = p_solution_number
    --and status = 'OUT';
    -- BugFix 3993200 - Sequence Id Fix
    OPEN  Get_Out;
    FETCH Get_Out INTO l_prev_pub_soln_id;
    CLOSE Get_Out;

    -- IMMEDIATE mark previous published solution and its
    -- statements for indexing, if there is one
    if( l_prev_pub_soln_id is not null )
    then
      Immediate_Mark_Soln_And_Stmts( l_prev_pub_soln_id );
    end if;
  end Mark_Idxs_on_Pub_Soln;

  /*
   * Mark_Idxs_on_Obs_Soln
   *  Mark all appropriate text indexes after a solution is
   *  obsoleted.
   */
  PROCEDURE Mark_Idxs_on_Obs_Soln( p_solution_number varchar2 )
  is
    l_new_soln_id number;
    l_prev_pub_soln_id number;

    CURSOR Get_Out IS
     select set_id --into l_prev_pub_soln_id
     from cs_kb_sets_b
     where set_number = p_solution_number
     and status = 'OUT'
     order by creation_date desc;

  begin
    -- First fetch the solution id for the newly
    -- obsoleted version of this solution
    select set_id into l_new_soln_id
    from cs_kb_sets_b
    where set_number = p_solution_number
      and status = 'OBS';

    -- IMMEDIATE mark newly obsoleted solution and its
    -- statements for indexing
    if( l_new_soln_id is not null )
    then
      Immediate_Mark_Soln_And_Stmts( l_new_soln_id );
    end if;

    -- Fetch the solution id for the previous published
    -- version of this solution, if there is one
    --select max(set_id) into l_prev_pub_soln_id
    --from cs_kb_sets_b
    --where set_number = p_solution_number
    --and status = 'OUT';
    -- BugFix 3993200 - Sequence Id Fix
    OPEN  Get_Out;
    FETCH Get_Out INTO l_prev_pub_soln_id;
    CLOSE Get_Out;

    -- IMMEDIATE mark previous published solution and its
    -- statements for indexing, if there is one
    if( l_prev_pub_soln_id is not null )
    then
      Immediate_Mark_Soln_And_Stmts( l_prev_pub_soln_id );
    end if;
  end Mark_Idxs_on_Obs_Soln;

  /*
   * Mark_Idxs_on_Global_Stmt_Upd
   *  Mark all appropriate text indexes after a global statement
   *  update is performed.
   */
  PROCEDURE Mark_Idxs_on_Global_Stmt_Upd( p_statement_id number )
  is
  begin
    -- IMMEDIATE mark the statement and all of the solutions linked
    -- to it.
    Immediate_Mark_Stmt_And_Solns( p_statement_id );
  end Mark_Idxs_on_Global_Stmt_Upd;


  /*
   * Mark_Idx_on_Add_Vis
   *  Mark Solution and Statement text indexes when a new visibility
   *  level is added.
   */
  PROCEDURE Mark_Idx_on_Add_Vis( p_added_vis_pos number )
  is
  begin
    -- DELAYED Mark all solutions of higher visibility position
    -- than the added visibility level
    update cs_kb_sets_b
    set reindex_flag = 'U'
    where set_id in
      ( select a.set_id
        from cs_kb_sets_b a, cs_kb_visibilities_b b
        where a.visibility_id = b.visibility_id
          and b.position >= p_added_vis_pos );

    -- DELAYED Mark all statements linked to solutions having a higher
    -- visibility position than the added visibility level.
    update cs_kb_elements_b
    set reindex_flag = 'U'
    where element_id in
      ( select unique c.element_id
        from cs_kb_sets_b a, cs_kb_visibilities_b b, cs_kb_set_eles c
        where a.visibility_id = b.visibility_id
          and a.set_id = c.set_id
          and b.position >= p_added_vis_pos );

    -- DELAYED Mark all solutions contained in categories having a higher
    -- category visibility positions than the added visibility level
    update cs_kb_sets_b
    set reindex_flag = 'U'
    where set_id in
      ( select unique a.set_id
        from cs_kb_set_categories a, cs_kb_soln_categories_b b,
        cs_kb_visibilities_b c
        where a.category_id = b.category_id
          and b.visibility_id = c.visibility_id
          and c.position >= p_added_vis_pos );

    -- DELAYED Mark all statements linked to solutions contained
    -- in categories having a higher category visibility positions than
    -- the added visibility level
    update cs_kb_elements_b
    set reindex_flag = 'U'
    where element_id in
      ( select unique d.element_id
        from cs_kb_set_categories a, cs_kb_soln_categories_b b,
          cs_kb_visibilities_b c, cs_kb_set_eles d
        where a.category_id = b.category_id
          and a.set_id = d.set_id
          and b.visibility_id = c.visibility_id
          and c.position >= p_added_vis_pos );
  end Mark_Idx_on_Add_Vis;

  /*
   * Mark_Idx_on_Rem_Vis
   *  Mark Solution and Statement text indexes when a visibility is
   *  removed.
   */
  PROCEDURE Mark_Idx_on_Rem_Vis( p_removed_vis_pos number )
  is
  begin
    -- IMMEDIATELY Mark all solutions of higher visibility position
    -- than the removed visibility level
    update cs_kb_sets_b
    set reindex_flag = 'U'
    where set_id in
      ( select a.set_id
        from cs_kb_sets_b a, cs_kb_visibilities_b b
        where a.visibility_id = b.visibility_id
          and b.position >= p_removed_vis_pos );

    -- IMMEDIATELY Mark all statements linked to solutions having a higher
    -- visibility position than the removed visibility level.
    update cs_kb_elements_b
    set reindex_flag = 'U'
    where element_id in
      ( select unique c.element_id
        from cs_kb_sets_b a, cs_kb_visibilities_b b, cs_kb_set_eles c
        where a.visibility_id = b.visibility_id
          and a.set_id = c.set_id
          and b.position >= p_removed_vis_pos );

    -- IMMEDIATELY Mark all solutions contained in categories having a higher
    -- category visibility positions than the removed visibility level
    update cs_kb_sets_b
    set reindex_flag = 'U'
    where set_id in
      ( select unique a.set_id
        from cs_kb_set_categories a, cs_kb_soln_categories_b b,
        cs_kb_visibilities_b c
        where a.category_id = b.category_id
          and b.visibility_id = c.visibility_id
          and c.position >= p_removed_vis_pos );

    -- IMMEDIATELY Mark all statements linked to solutions contained
    -- in categories having a higher category visibility positions than
    -- the removed visibility level
    update cs_kb_elements_b
    set reindex_flag = 'U'
    where element_id in
      ( select unique d.element_id
        from cs_kb_set_categories a, cs_kb_soln_categories_b b,
          cs_kb_visibilities_b c, cs_kb_set_eles d
        where a.category_id = b.category_id
          and a.set_id = d.set_id
          and b.visibility_id = c.visibility_id
          and c.position >= p_removed_vis_pos );
  end Mark_Idx_on_Rem_Vis;

  /*
   * Mark_Idx_on_Change_Cat_Vis
   *  Mark Solution and Statement text indexes when a Solution Category's
   *  visibility level changes.
   */
  PROCEDURE Mark_Idx_on_Change_Cat_Vis( p_cat_id number, p_orig_vis_id number )
  is
    l_orig_cat_vis_pos number;
    l_new_cat_vis_pos number;
  begin
    -- Fetch the visibility position for the categories original visibility
    -- and the categories new visibility
    select position into l_orig_cat_vis_pos
    from cs_kb_visibilities_b
    where visibility_id = p_orig_vis_id;

    select v.position into l_new_cat_vis_pos
    from cs_kb_soln_categories_b c, cs_kb_visibilities_b v
    where c.category_id = p_cat_id
      and c.visibility_id = v.visibility_id;

    -- Mark solutions and statements in DELAYED mode if the
    -- category's visibility changed to a less secure level
    if ( l_new_cat_vis_pos > l_orig_cat_vis_pos )
    then
      -- DELAYED Mark all solutions within the changed category
      update cs_kb_sets_b
      set reindex_flag = 'U'
      where set_id in
        ( select set_id
          from cs_kb_set_categories
          where category_id = p_cat_id );

      -- DELAYED Mark all statements linked to the solutions
      -- within the changed category
      update cs_kb_elements_b
      set reindex_flag = 'U'
      where element_id in
        ( select b.element_id
          from cs_kb_set_categories a, cs_kb_set_eles b
          where a.set_id = b.set_id
          and a.category_id = p_cat_id );
    elsif ( l_new_cat_vis_pos < l_orig_cat_vis_pos )
    then
    -- Else if the category's visibility changed to a more secure level,
    -- IMMEDIATELY mark the solutions and statements

      -- IMMEDIATELY Mark all solutions within the changed category
      update cs_kb_sets_tl
      set composite_assoc_index = 'U', composite_assoc_attach_index = 'U' --12.1.3
      where set_id in
        ( select set_id
          from cs_kb_set_categories
          where category_id = p_cat_id );

      -- IMMEDIATELY Mark all statements linked to the solutions within the
      -- changed category
      update cs_kb_elements_tl
      set composite_text_index = 'U'
      where element_id in
        ( select b.element_id
          from cs_kb_set_categories a, cs_kb_set_eles b
          where a.set_id = b.set_id
          and a.category_id = p_cat_id );
    else
    -- Otherwise, the category visibilities have not change so do nothing.
      null;
    end if;
  end Mark_Idx_on_Change_Cat_Vis;

  /*
   * Mark_Idx_on_Change_Parent_Cat
   *  Mark Solution and Statement text indexes when a Solution Category's
   *  parent category changes.
   */
  PROCEDURE Mark_Idx_on_Change_Parent_Cat( p_cat_id number, p_orig_parent_cat_id number )
  is
    cursor get_descendent_sets(cp_cat_id number) is
    select b.set_id
    from cs_kb_set_categories c, cs_kb_sets_b b
    where c.category_id in
    (
        select category_id
        from cs_kb_soln_categories_b
        start with category_id = cp_cat_id
        connect by prior category_id = Parent_category_id
    )
    and c.set_id = b.set_id
    and b.status = 'PUB';
    l_set_id number;

  begin

      -- IMMEDIATELY Mark all solutions under the changed category
      open get_descendent_sets(p_cat_id);
      loop
          fetch get_descendent_sets into l_set_id;
          exit when get_descendent_sets%notfound;
          update cs_kb_sets_tl
          set composite_assoc_index = 'U', composite_assoc_attach_index = 'U' --12.1.3
          where set_id = l_set_id;
          -- Update the content cache, cause the full path is now changed.
          Populate_Soln_Content_Cache( l_set_id );
          Pop_Soln_Attach_Content_Cache (l_set_id);
          -- IMMEDIATELY Mark all statements linked to this solution.
          update cs_kb_elements_tl
          set composite_text_index = 'U'
          where element_id in
            ( select element_id
              from cs_kb_set_eles
              where set_id = l_set_id);
      end loop;
      close get_descendent_sets;

  end Mark_Idx_on_Change_Parent_Cat;

  /*
   * Mark_Idxs_For_Multi_Soln
   *  Mark Solution and Statement text indexes when a Solution Category's
   *  parent category changes.
   */
  PROCEDURE Mark_Idxs_For_Multi_Soln( p_set_ids JTF_NUMBER_TABLE )
  is
    cursor is_published_soln (cp_set_id number) is
    select set_id
    from cs_kb_sets_b
    where set_id = cp_set_id
    and status = 'PUB';
    l_set_id number;
  begin
    for i in 1..p_set_ids.count loop
      -- Check if the solution referenced is not published yet.
      l_set_id := null;
      open is_published_soln(p_set_ids(i));
      fetch is_published_soln into l_set_id;
      close is_published_soln;

      if(l_set_id is not null) then
          -- IMMEDIATELY Mark this solution.
          update cs_kb_sets_tl
          set composite_assoc_index = 'U', composite_assoc_attach_index = 'U' --12.1.3
          where set_id = l_set_id;

          -- Update the content cache, cause the full path is now changed.
	  Populate_Soln_Content_Cache( l_set_id );
	  Pop_Soln_Attach_Content_Cache (l_set_id);

          -- IMMEDIATELY Mark all statements linked to this solution.
          update cs_kb_elements_tl
          set composite_text_index = 'U'
          where element_id in
            ( select element_id
              from cs_kb_set_eles
              where set_id = l_set_id);
      end if;
    end loop;
  end Mark_Idxs_For_Multi_Soln;
  /*
   * Mark_Idx_on_Add_Cat_To_Cat_Grp
   *  Mark Solution and Statement text indexes when a Category is
   *  added to a Category Group.
   */
  PROCEDURE Mark_Idx_on_Add_Cat_To_Cat_Grp( p_cat_grp_id number, p_cat_id number )
  is
  begin
    -- DELAYED Mark all solutions in the removed category and
    -- all of its subcategories, recursively
    update cs_kb_sets_b
    set reindex_flag = 'U'
    where set_id in
      ( select unique set_id
        from cs_kb_set_categories
        where category_id in
          ( select category_id
            from cs_kb_soln_categories_b
              start with category_id = p_cat_id
              connect by prior category_id = parent_category_id ));

    -- DELAYED Mark all statements linked to all solutions in the
    -- removed category and all of its subcategories, recursively
    update cs_kb_elements_b
    set reindex_flag = 'U'
    where element_id in
      ( select unique b.element_id
        from cs_kb_set_categories a, cs_kb_set_eles b
        where a.set_id = b.set_id
          and a.category_id in
            ( select category_id
              from cs_kb_soln_categories_b
                start with category_id = p_cat_id
                connect by prior category_id = parent_category_id ));
  end Mark_Idx_on_Add_Cat_To_Cat_Grp;

  /*
   * Mark_Idx_on_Rem_Cat_fr_Cat_Grp
   *  Mark Solution and Statement text indexes when a Category is
   *  removed from a Category Group.
   */
  PROCEDURE Mark_Idx_on_Rem_Cat_fr_Cat_Grp( p_cat_grp_id number, p_cat_id number )
  is
  begin
    -- IMMEDIATELY Mark all solutions in the removed category
    -- and all of its subcategories, recursively
    update cs_kb_sets_tl
    set composite_assoc_index = 'U', composite_assoc_attach_index = 'U' --12.1.3
    where set_id in
      ( select unique set_id
        from cs_kb_set_categories
        where category_id in
          ( select category_id
            from cs_kb_soln_categories_b
              start with category_id = p_cat_id
              connect by prior category_id = parent_category_id ));

    -- IMMEDIATELY Mark all statements linked to all solutions in
    -- the removed category and all of its subcategories, recursively
    update cs_kb_elements_tl
    set composite_text_index = 'U'
    where element_id in
      ( select unique b.element_id
        from cs_kb_set_categories a, cs_kb_set_eles b
        where a.set_id = b.set_id
          and a.category_id in
            ( select category_id
              from cs_kb_soln_categories_b
                start with category_id = p_cat_id
                connect by prior category_id = parent_category_id ));
  end Mark_Idx_on_Rem_Cat_fr_Cat_Grp;

  -- *********************************
  -- Private Procedure Implementations
  -- *********************************

  /*
   * Immediate_Mark_Soln_And_Stmts
   *  Mark text index column dirty for reindexing for a solution
   *  version and all of its statements.
   */
  PROCEDURE Immediate_Mark_Soln_And_Stmts( p_solution_id number )
  is
  begin
    -- IMMEDIATE Mark the solution version for indexing
    update cs_kb_sets_tl
    set composite_assoc_index = 'U', composite_assoc_attach_index = 'U' --12.1.3
    where set_id = p_solution_id;

    -- (3377135)
    -- Update content cache
    populate_soln_content_cache(p_solution_id);
    Pop_Soln_Attach_Content_Cache (p_solution_id);
    -- end (3377135)

    -- IMMEDIATE Mark all of the statements linked to the
    -- solution version
    update cs_kb_elements_tl
    set composite_text_index = 'U'
    where element_id in
      ( select element_id from cs_kb_set_eles
        where set_id = p_solution_id );
  end;

  /*
   * Immediate_Mark_Stmt_And_Solns
   *  Mark text index column dirty for reindexing for a statement
   *  and all of the solutions it is used in.
   */
  PROCEDURE Immediate_Mark_Stmt_And_Solns( p_statement_id number )
  is
   --(3377135)
   CURSOR get_related_sets (p_statement_id NUMBER)
   IS
     select se.set_id from cs_kb_set_eles se, cs_kb_sets_b sb
        where se.element_id = p_statement_id
          and se.set_id = sb.set_id
          and sb.status = 'PUB';
   TYPE list_set_ids IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_set_ids list_set_ids;
   i NUMBER;
  begin
    -- IMMEDIATE Mark the statement for indexing
    update cs_kb_elements_tl
    set composite_text_index = 'U'
    where element_id = p_statement_id;

     --start (3377135)
    -- update content cache
    OPEN get_related_sets(p_statement_id);
    FETCH get_related_sets BULK COLLECT INTO l_set_ids;
    CLOSE get_related_sets;

    i := l_set_ids.FIRST;    -- (3580163)
    while i is not null loop
      populate_soln_content_cache(l_set_ids(i));
      Pop_Soln_Attach_Content_Cache (l_set_ids(i));

      --Mark the solution for update
      UPDATE cs_kb_sets_tl
      set composite_assoc_index = 'U',composite_assoc_attach_index = 'U' --12.1.3
      where set_id  = l_set_ids(i);

      i := l_set_ids.NEXT(i);
    END LOOP;

   /*
     -- IMMEDIATE Mark all of the published solutions linked to the
     -- statement
        update cs_kb_sets_tl
        set composite_assoc_index = 'U'
        where set_id in
        ( select se.set_id from cs_kb_set_eles se,
          cs_kb_sets_b sb
          where se.element_id = p_statement_id
          and se.set_id = sb.set_id
          and sb.status = 'PUB');
    */
     -- end (3377135)

  end;

  /*
   * Request_Sync_Set_Index
   *  This procedure submits a concurrent request
   *  to sync KM set index.
   */
  PROCEDURE Request_Sync_Set_Index
  ( x_request_id    OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2 )
  IS
    l_request_id           NUMBER;
    l_CS_appsname          VARCHAR2(2) := 'CS';
    l_sync_idx_progname    VARCHAR2(100) := 'CS_KB_SYNC_SOLUTIONS_INDEX';
    l_sync_mode            VARCHAR2(1) := 'S';
    l_pending_phase_code   VARCHAR2(1) := 'P';
    l_num_pending_requests NUMBER := 0;
    l_return_status        VARCHAR2(1) := fnd_api.G_RET_STS_ERROR;
  begin

    -- Detect how many Pending, but not scheduled, KM Sync-Index
    -- concurrent program requests there are.
    select count(*)
    into l_num_pending_requests
    from fnd_concurrent_programs cp,
      fnd_application ap,
      fnd_concurrent_requests cr
    where ap.application_short_name = l_CS_appsname
      and cp.concurrent_program_name = l_sync_idx_progname
      and cp.application_id = ap.application_id
      and cr.concurrent_program_id = cp.concurrent_program_id
      and cr.phase_code = l_pending_phase_code
      and cr.requested_start_date <= sysdate;

    -- If there are no unscheduled pending KM Sync-Index concurrent
    -- requests, then submit one. Otherwise, since there is already
    -- an unscheduled pending request, which will be run as soon as
    -- possible, there is no need to submit another request.
    if( l_num_pending_requests = 0 )
    then
      l_request_id :=
        fnd_request.submit_request
        ( application => l_CS_appsname,
          program     => l_sync_idx_progname,
          description => null,
          start_time  => null,
          sub_request => FALSE,
          argument1   => l_sync_mode );

      if( l_request_id > 0 )
      then
        l_return_status := fnd_api.G_RET_STS_SUCCESS;
      end if;
    else
      -- There is already a pending request, so just return success
      l_request_id := 0;
      l_return_status := fnd_api.G_RET_STS_SUCCESS;
    end if;

    x_request_id := l_request_id;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      x_request_id := 0;
      x_return_status := fnd_api.G_RET_STS_ERROR;
  END Request_Sync_Set_Index;


  /*
   * Request_Sync_Element_Index
   *  This procedure submits a concurrent request
   *  to sync KM element index.
   */
  PROCEDURE Request_Sync_Element_Index
  ( x_request_id    OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2 )
   IS
    l_request_id           NUMBER;
    l_CS_appsname          VARCHAR2(2) := 'CS';
    --l_sync_idx_progname    VARCHAR2(16) := 'CS_KB_SYNC_INDEX';
    -- Call new solution synchronization request
    l_sync_idx_progname    VARCHAR2(100) := 'CS_KB_SYNC_STATEMENTS_INDEX';
    l_sync_mode            VARCHAR2(1) := 'S';
    l_pending_phase_code   VARCHAR2(1) := 'P';
    l_num_pending_requests NUMBER := 0;
    l_return_status        VARCHAR2(1) := fnd_api.G_RET_STS_ERROR;
  BEGIN

    -- Detect how many Pending, but not scheduled, KM Sync-Index
    -- concurrent program requests there are.
    select count(*)
    into l_num_pending_requests
    from fnd_concurrent_programs cp,
      fnd_application ap,
      fnd_concurrent_requests cr
    where ap.application_short_name = l_CS_appsname
      and cp.concurrent_program_name = l_sync_idx_progname
      and cp.application_id = ap.application_id
      and cr.concurrent_program_id = cp.concurrent_program_id
      and cr.phase_code = l_pending_phase_code
      and cr.requested_start_date <= sysdate;

    -- If there are no unscheduled pending KM Sync-Index concurrent
    -- requests, then submit one. Otherwise, since there is already
    -- an unscheduled pending request, which will be run as soon as
    -- possible, there is no need to submit another request.
    if( l_num_pending_requests = 0 )
    then
      l_request_id :=
        fnd_request.submit_request
        ( application => l_CS_appsname,
          program     => l_sync_idx_progname,
          description => null,
          start_time  => null,
          sub_request => FALSE,
          argument1   => l_sync_mode );

      if( l_request_id > 0 )
      then
        l_return_status := fnd_api.G_RET_STS_SUCCESS;
      end if;
    else
      -- There is already a pending request, so just return success
      l_request_id := 0;
      l_return_status := fnd_api.G_RET_STS_SUCCESS;
    end if;

    x_request_id := l_request_id;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      x_request_id := 0;
      x_return_status := fnd_api.G_RET_STS_ERROR;
  END Request_Sync_Element_Index;


end CS_KB_SYNC_INDEX_PKG;

/
