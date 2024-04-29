--------------------------------------------------------
--  DDL for Package Body IGIRX_IAC_PROJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIRX_IAC_PROJ" AS
-- $Header: igiiaxpb.pls 120.9 2007/08/01 10:45:33 npandya ship $


--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiaxpb.igirx_iac_proj.';

--===========================FND_LOG.END=======================================

 -- ====================================================================
 -- PROCEDURE Proj: Main procedure that will be called by the RXi
 -- outer wrapper process for IAC projections
 -- ====================================================================
 PROCEDURE proj(p_projection_id     NUMBER,
                p_request_id        NUMBER,
                retcode  OUT NOCOPY NUMBER,
		errbuf   OUT NOCOPY VARCHAR2)
 IS

 -- cursors
 -- Get the master projection data
 CURSOR c_get_proj(n_projection_id   NUMBER)
 IS
 SELECT book_type_code,
        start_period_counter,
        end_period,
        revaluation_period
 FROM igi_iac_projections
 WHERE projection_id = n_projection_id;

 -- Get the detail level projection data
 CURSOR c_proj_data(n_proj_id igi_iac_projections.projection_id%TYPE)
 IS
 SELECT dp.projection_id,
        dp.period_counter proj_period_counter,
        dp.category_id,
        fc.description cat_desc,
        dp.fiscal_year,
        dp.company,
        dp.cost_center,
        dp.asset_id,
        fad.asset_number,
        fad.description asset_desc,
        dp.latest_reval_cost,
        dp.deprn_period,
        dp.deprn_ytd,
        substr(dp.asset_exception,1,30) exception_code
 FROM   igi_iac_proj_details dp,
        fa_additions fad,
        fa_categories fc
 WHERE  dp.projection_id = n_proj_id
 AND    fad.asset_id = dp.asset_id
 AND    dp.category_id = fc.category_id
 ORDER BY dp.asset_id, dp.period_counter;




 -- variables
    l_login_id               NUMBER := fnd_profile.value('LOGIN_ID');
    l_user_id                NUMBER := fnd_profile.value('USER_ID');

    l_cat_struct             fa_system_controls.category_flex_structure%TYPE;
    l_assetkey_struct        fa_system_controls.asset_key_flex_structure%TYPE;

    l_get_proj               c_get_proj%ROWTYPE;
    l_sob_id                 fa_book_controls.set_of_books_id%TYPE;
    l_currency_code          gl_sets_of_books.currency_code%TYPE;
    l_organization_name      gl_sets_of_books.name%TYPE;

    l_min_cat                VARCHAR2(50);

    l_concat_cat             VARCHAR2(500);
    l_cat_segs               fa_rx_shared_pkg.Seg_Array;

    l_prd_rec                igi_iac_types.prd_rec;
    l_ret_flag               BOOLEAN;
    l_start_period_name      VARCHAR2(15);
    l_end_period_name        VARCHAR2(15);
    l_reval_prd_ctr          NUMBER;
    l_reval_idx_val          NUMBER;
    l_reval_period_name      VARCHAR2(15);
    l_exception_desc         VARCHAR2(255);

    TYPE iac_char15_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
    TYPE iac_char30_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE iac_char80_type IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
    TYPE iac_char255_type IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
    TYPE iac_char500_type IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
    TYPE iac_num_type  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    TYPE rxi_proj_rec IS RECORD (
        reccount          iac_num_type,
        projection_id     iac_num_type,
        book_type_code    iac_char15_type,
        start_period      iac_char15_type,
        end_period        iac_char15_type,
        proj_period       iac_char15_type,
        fiscal_year       iac_num_type,
        periodic_index    iac_num_type,
        reval_index       iac_num_type,
        reval_period_name iac_char15_type,
        company           iac_char30_type,
        cost_center       iac_char30_type,
        category_id       iac_num_type,
        major_category    iac_char30_type,
        minor_category    iac_char30_type,
        category          iac_char500_type,
        category_desc     iac_char80_type,
        asset_number      iac_char30_type,
        asset_desc        iac_char80_type,
        deprn_period      iac_num_type,
        deprn_ytd         iac_num_type,
        latest_reval_cost iac_num_type,
        exception_code    iac_char30_type,
        exception_desc    iac_char255_type,
        period_counter    iac_num_type);


  l_rxi_proj_rec        rxi_proj_rec;
  l_proj_data           c_proj_data%ROWTYPE;
  l_count               NUMBER := 1;

  l_sql                 VARCHAR2(5000);
 -- exceptions
  l_path		VARCHAR2(150) := g_path||'proj';
 BEGIN
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Entered inner procedure');
    -- get the category and asset key flex structures
    SELECT category_flex_structure, asset_key_flex_structure
    INTO   l_cat_struct, l_assetkey_struct
    FROM   fa_system_controls;

    -- get the book type code for the projection
    OPEN c_get_proj(p_projection_id);
    FETCH c_get_proj INTO l_get_proj;
    IF c_get_proj%NOTFOUND THEN
       CLOSE c_get_proj;
    END IF;
    CLOSE c_get_proj;

    -- get the sob id, currency code and organization name
    SELECT sob.set_of_books_id,
           substr(sob.currency_code,1,15),
           substr(sob.name,1 ,80)
    INTO  l_sob_id,
          l_currency_code,
          l_organization_name
    FROM  fa_book_controls bc,
          gl_sets_of_books sob,
          fnd_currencies cur
    WHERE  bc.book_type_code = l_get_proj.book_type_code
    AND    sob.set_of_books_id = bc.set_of_books_id
    AND    sob.currency_code = cur.currency_code;

    -- get period name for start period counter
    l_ret_flag := igi_iac_common_utils.get_period_info_for_counter( l_get_proj.book_type_code,
                                                                    l_get_proj.start_period_counter,
                                                                    l_prd_rec );
    l_start_period_name := l_prd_rec.period_name;

    -- get period name for end period counter
    l_ret_flag := igi_iac_common_utils.get_period_info_for_counter( l_get_proj.book_type_code,
                                                                    l_get_proj.end_period,
                                                                    l_prd_rec );

    l_end_period_name := l_prd_rec.period_name;

    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Start populating IAC Projections RXi interface table');

    -- main loop for getting info for interface table
    FOR l_proj_data IN c_proj_data(p_projection_id)
    LOOP
       l_count := l_count + 1;

       l_rxi_proj_rec.reccount(l_count) := l_count;
       l_rxi_proj_rec.projection_id(l_count) := p_projection_id;
       l_rxi_proj_rec.book_type_code(l_count) := l_get_proj.book_type_code;
       l_rxi_proj_rec.start_period(l_count) := l_start_period_name;
       l_rxi_proj_rec.end_period(l_count) := l_end_period_name;
       l_rxi_proj_rec.fiscal_year(l_count) := l_proj_data.fiscal_year;
       l_rxi_proj_rec.asset_number(l_count) := l_proj_data.asset_number;
       l_rxi_proj_rec.asset_desc(l_count) := l_proj_data.asset_desc;
       l_rxi_proj_rec.latest_reval_cost(l_count) := l_proj_data.latest_reval_cost;
       l_rxi_proj_rec.deprn_period(l_count) := l_proj_data.deprn_period;
       l_rxi_proj_rec.deprn_ytd(l_count) := l_proj_data.deprn_ytd;

       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset Number: '||l_proj_data.asset_number||' Reccount: '||l_count);

       -- get period name for projection period counter
       l_ret_flag := igi_iac_common_utils.get_period_info_for_counter( l_get_proj.book_type_code,
                                                                       l_proj_data.proj_period_counter,
                                                                       l_prd_rec );

       l_rxi_proj_rec.proj_period(l_count) := l_prd_rec.period_name;
       l_rxi_proj_rec.period_counter(l_count) := l_proj_data.proj_period_counter;

       l_ret_flag := igi_iac_proj_pkg.get_price_index_val(p_book_code       => l_get_proj.book_type_code,
                                                          p_category_id     => l_proj_data.category_id,
                                                          p_period_ctr      => l_proj_data.proj_period_counter,
                                                          p_price_index_val => l_rxi_proj_rec.periodic_index(l_count));


       -- Get the reval period info
       IF (l_prd_rec.period_num = l_get_proj.revaluation_period) THEN
          l_reval_prd_ctr := l_proj_data.proj_period_counter;
          l_reval_period_name := l_rxi_proj_rec.proj_period(l_count);
          l_reval_idx_val := l_rxi_proj_rec.periodic_index(l_count);

       ELSE
           -- if this is the first period and is not a reval period
           -- get the revaluation period and index for the start period counter
	   -- Get the previous revaluation period or the DPIS period if it does not exist

           IF (l_proj_data.proj_period_counter = l_get_proj.start_period_counter) THEN

                l_ret_flag := igi_iac_proj_pkg.get_reval_prd_dpis_ctr(l_get_proj.book_type_code,
                                                                      l_proj_data.asset_id,
                                                                      l_reval_prd_ctr);

                l_ret_flag := igi_iac_common_utils.get_period_info_for_counter(l_get_proj.book_type_code,
                                                                               l_reval_prd_ctr,
                                                                               l_prd_rec );

                l_reval_period_name := l_prd_rec.period_name;


                l_ret_flag := igi_iac_proj_pkg.get_price_index_val(l_get_proj.book_type_code,
                                                                   l_proj_data.category_id,
                                                                   l_reval_prd_ctr,
                                                                   l_reval_idx_val);
           END IF;
       END IF;

       l_rxi_proj_rec.reval_index(l_count) := l_reval_idx_val;
       l_rxi_proj_rec.reval_period_name(l_count) := l_reval_period_name;

       -- get the company and cost center
       l_rxi_proj_rec.company(l_count) := l_proj_data.company;
       l_rxi_proj_rec.cost_center(l_count) := l_proj_data.cost_center;

       -- get the category information
       l_rxi_proj_rec.category_id(l_count) := l_proj_data.category_id;
       l_rxi_proj_rec.category_desc(l_count) := l_proj_data.cat_desc;

       -- get the major category and minor category values
       l_rxi_proj_rec.major_category(l_count) := fa_rx_flex_pkg.get_value(
                                                           p_application_id => 140,
                                                           p_id_flex_code   => 'CAT#',
                                                           p_id_flex_num    => l_assetkey_struct,
                                                           p_qualifier      => 'BASED_CATEGORY',
                                                           p_ccid           => l_proj_data.category_id);
        -- change the way the minor category is retrieved
        -- get only the first qualified segment
/*       l_min_cat:= fa_rx_flex_pkg.get_value(
                                             p_application_id => 140,
                                             p_id_flex_code   => 'CAT#',
                                             p_id_flex_num    => l_assetkey_struct,
                                             p_qualifier      => 'MINOR_CATEGORY',
                                             p_ccid           => l_proj_data.category_id);

       l_rxi_proj_rec.minor_category(l_count) := substr(l_min_cat, 0, instr(l_min_cat, 1, 1)-1);
*/
       begin
         l_min_cat := fa_rx_flex_pkg.flex_sql(140,
                                              'CAT#',
                                              l_assetkey_struct,
                                              'CAT',
                                              'SELECT',
                                              'MINOR_CATEGORY');
       exception
           when others then
              l_min_cat := 'null';
       end;

       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Minor category segment: '||l_min_cat);

       IF (l_min_cat IS NOT NULL) THEN
          l_sql := 'SELECT ' ||l_min_cat||
                   ' FROM fa_categories cat
                   WHERE cat.category_id = :1';
          /* Bug 3448431 */
          execute immediate l_sql into l_rxi_proj_rec.minor_category(l_count) USING l_proj_data.category_id;
      ELSE
         l_rxi_proj_rec.minor_category(l_count) := null;
      END IF;


      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Minor category value: '||l_rxi_proj_rec.minor_category(l_count));

       -- get the concatenated category name
       fa_rx_shared_pkg.concat_category (
                                       struct_id       => l_cat_struct,
                                       ccid            => l_proj_data.category_id,
                                       concat_string   => l_concat_cat,
                                       segarray        => l_cat_segs);


      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Category:  '||l_concat_cat);
      l_rxi_proj_rec.category(l_count) := l_concat_cat;

      -- get the exception code description
     l_rxi_proj_rec.exception_code(l_count) := l_proj_data.exception_code;

     IF (l_proj_data.exception_code IS NOT NULL) THEN
        SELECT meaning
        INTO   l_exception_desc
        FROM IGI_LOOKUPS
        WHERE lookup_type = 'IGI_IAC_PROJ_EXCEPTIONS'
        AND lookup_code = l_proj_data.exception_code;
     ELSE
        l_exception_desc := NULL;
     END IF;

     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Exception:  '||l_exception_desc);
     l_rxi_proj_rec.exception_desc(l_count) := l_exception_desc;

    END LOOP;

   -- insert into the RXi interface table
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Inserting.......');

   FORALL i IN l_rxi_proj_rec.reccount.FIRST .. l_rxi_proj_rec.reccount.LAST
      INSERT INTO igi_iac_proj_rep_itf(
            projection_id,
            book_type_code,
            start_period,
            end_period,
            proj_period,
            fiscal_year,
            periodic_index,
            reval_index,
            reval_period_name,
            company,
            cost_center,
            category_id,
            major_category,
            minor_category,
            category,
            category_desc,
            asset_number,
            asset_desc,
            deprn_period,
            deprn_ytd,
            latest_reval_cost,
            exception_code,
            exception_desc,
            request_id,
            set_of_books_id,
            functional_currency_code,
            organization_name,
            created_by,
            creation_date,
            last_update_login,
            last_updated_by ,
            last_update_date,
            period_counter
          ) VALUES (
            p_projection_id,
            l_rxi_proj_rec.book_type_code(i),
            l_rxi_proj_rec.start_period(i),
            l_rxi_proj_rec.end_period(i),
            l_rxi_proj_rec.proj_period(i),
            l_rxi_proj_rec.fiscal_year(i),
            l_rxi_proj_rec.periodic_index(i),
            l_rxi_proj_rec.reval_index(i),
            l_rxi_proj_rec.reval_period_name(i),
            l_rxi_proj_rec.company(i),
            l_rxi_proj_rec.cost_center(i),
            l_rxi_proj_rec.category_id(i),
            l_rxi_proj_rec.major_category(i),
            l_rxi_proj_rec.minor_category(i),
            l_rxi_proj_rec.category(i),
            l_rxi_proj_rec.category_desc(i),
            l_rxi_proj_rec.asset_number(i),
            l_rxi_proj_rec.asset_desc(i),
            l_rxi_proj_rec.deprn_period(i),
            l_rxi_proj_rec.deprn_ytd(i),
            l_rxi_proj_rec.latest_reval_cost(i),
            l_rxi_proj_rec.exception_code(i),
            l_rxi_proj_rec.exception_desc(i),
            p_request_id,
            l_sob_id,
            l_currency_code,
            l_organization_name,
            l_user_id,
            sysdate,
            l_login_id,
            l_user_id ,
            sysdate,
            l_rxi_proj_rec.period_counter(i)
          );

          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'End populating IAC Projections RXi interface table');

          -- 02-Oct-2003, Bug 3140574, delete from main projections tables
          DELETE FROM igi_iac_projections
          WHERE projection_id = p_projection_id;

          DELETE FROM igi_iac_proj_details
          WHERE projection_id = p_projection_id;

          retcode := 0;
          errbuf := 'RXi Projections Inner Wrapper Successful!';
 EXCEPTION
   WHEN OTHERS THEN
     retcode := 2;
     FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
     FND_MESSAGE.SET_TOKEN('PACKAGE','igirx_iac_proj');
     FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','Inner Process unsuccessful!');

     igi_iac_debug_pkg.debug_other_msg(g_unexp_level,l_path,FALSE);
     errbuf := fnd_message.get;
     igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Population of IAC Projections RXi interface table unsuccessful');
 END proj;

END igirx_iac_proj; -- Package body

/
