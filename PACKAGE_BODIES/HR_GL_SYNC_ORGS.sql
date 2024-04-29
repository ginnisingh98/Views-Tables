--------------------------------------------------------
--  DDL for Package Body HR_GL_SYNC_ORGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GL_SYNC_ORGS" AS
   -- $Header: hrglsync.pkb 120.5 2008/04/01 10:51:54 ktithy noship $

   --
   -- Due to  potentially heavy memory usage by this package, restrict
   -- package data life to current call only.
   --
   -- Fix for bug 4445934. Comment out the pragma serially_reusable.
   --
   -- PRAGMA SERIALLY_REUSABLE;

   --
   -- Package globals.
   --
   g_package             VARCHAR2(15) := 'hr_gl_sync_orgs';
   g_org_name_max_length NUMBER := 0;
   g_max_retries         NUMBER := 10; -- Max. tries to make ORG Name unique.
   g_debug_level         pay_action_parameters.parameter_value%TYPE := NULL;
   g_export_dir          VARCHAR2(300) := NULL;
   g_class_profile       VARCHAR2(10)  := NULL;
   g_org_name_format     VARCHAR2(60)  := NULL;
   g_appl_short_name     VARCHAR2(3)   := 'PER';
   g_per_schema          VARCHAR2(10)  := NULL;
   g_temp_table_name     VARCHAR2(50)  := NULL;

   --
   -- Write to the LOG file.
   --
   PROCEDURE writelog( p_text       IN VARCHAR2
                     , p_debug_mode IN VARCHAR2 DEFAULT 'N'
                     ) IS
   BEGIN
      IF p_debug_mode = 'Y' THEN
         IF g_debug_level = 'DEBUG' THEN
            fnd_file.put_line(fnd_file.log, p_text);
         END IF;
      ELSE
         fnd_file.put_line(fnd_file.log, p_text);
      END IF;

      hr_utility.set_location('LOG Message - '||p_text, 999);
   EXCEPTION
      WHEN OTHERS THEN
         IF SQLCODE = -20100 THEN
            hr_utility.set_location(SUBSTR(p_text,1,100), 990);
         ELSE
            hr_utility.set_location('Procedure writelog encountered unknown exception', 995);
            RAISE;
         END IF;
   END writelog;

   --
   -- Drop temporary table.
   --
   PROCEDURE drop_temp_table IS

      -- Local variables
      l_proc VARCHAR2(50) := g_package||'.drop_temp_table';

   BEGIN

      hr_utility.set_location('Entering: '|| g_temp_table_name, 10);

      EXECUTE IMMEDIATE 'DROP TABLE '||g_temp_table_name;

      hr_utility.set_location('Leaving: '|| l_proc, 20);

   EXCEPTION

      WHEN OTHERS THEN
         IF SQLCODE = -942 THEN
            -- Table not present for dropping. Ignore as this could
            -- be the first run.
            hr_utility.set_location('Leaving: '|| l_proc, 30);
         ELSE
            hr_utility.set_location('Leaving: '|| l_proc, 40);
            hr_utility.set_location(SQLERRM, 45);
            writelog(SQLERRM,'N');
            RAISE;
         END IF;

   END drop_temp_table;

   --
   -- Create temporary table.
   --
   PROCEDURE create_temp_table( p_mode IN VARCHAR2
                              ) IS

      -- Local variables
      l_proc    VARCHAR2(50) := g_package||'.create_temp_table';
      l_sql_str VARCHAR2(600);

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Drop the temporary table if it already exists
      drop_temp_table();

      hr_utility.set_location(l_proc, 20);

      l_sql_str := 'CREATE TABLE '||g_temp_table_name||
                   ' ( coa_id   NUMBER(15)'   ||
                   ' , co       VARCHAR2(240)'||
                   ' , co_vs_id NUMBER(15)'   ||
                   ' , cc       VARCHAR2(240)'||
                   ' , cc_vs_id NUMBER(15)';

      IF p_mode = 'SYNCHRONIZE' THEN
         hr_utility.set_location(l_proc, 30);
         l_sql_str := l_sql_str ||
                      ' , ccid   NUMBER(15)'   ||
                      ' , org_id NUMBER(15)';
      END IF;

      IF p_mode = 'EXPORT' THEN
         hr_utility.set_location(l_proc, 40);
         l_sql_str := l_sql_str ||
                      ' , co_desc        VARCHAR2(240)'||
                      ' , cc_desc        VARCHAR2(240)'||
                      ' , co_vs_name     VARCHAR2(60)' ||
                      ' , cc_vs_name     VARCHAR2(60)' ||
                      ' , org_name       VARCHAR2(240)'||
                      ' , org_start_date DATE';
      END IF;

      l_sql_str := l_sql_str || ' )';

      hr_utility.set_location(l_proc, 50);

      -- Create a new instance of the temporary table
      EXECUTE IMMEDIATE l_sql_str;

      hr_utility.set_location('Leaving: '|| l_proc, 60);

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 70);
         hr_utility.set_location(SQLERRM, 75);
         writelog(SQLERRM,'N');
         RAISE;

   END create_temp_table;

   --
   -- Initiate LOG and OUT files.
   --
   FUNCTION open_logs( p_mode              IN VARCHAR2
                     , p_business_group_id IN NUMBER
                     , p_ccid              IN NUMBER
                     ) RETURN NUMBER IS

      -- Local variables
      l_proc    VARCHAR2(50) := g_package||'.open_logs';
      l_retcode NUMBER := 0;
      l_dir     VARCHAR2(300) := NULL;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Open LOG and OUT files.
      IF p_mode = 'SINGLE_ORG' THEN
         hr_utility.set_location(l_proc, 20);
         fnd_file.put_names( p_mode||p_ccid||'.log'
                           , p_mode||p_ccid||'.out'
                           , l_dir
                           );
      ELSE -- mode is not single org
         hr_utility.set_location(l_proc, 30);
         fnd_file.put_names( p_mode||p_business_group_id||'.log'
                           , p_mode||p_business_group_id||'.out'
                           , l_dir
                           );
      END IF;

      hr_utility.set_location('Leaving: '|| l_proc, 40);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '||l_proc, 50);
         hr_utility.set_location(SQLERRM, 55);
         writelog(SQLERRM,'N');
         l_retcode := 2;
         RETURN l_retcode;

   END open_logs;

   --
   -- Initiate export header and data files.
   --
   FUNCTION open_export_files( p_bg_id           IN            NUMBER
                             , p_bg_name         IN            VARCHAR2
                             , p_hdr_file        IN OUT NOCOPY VARCHAR2
                             , p_dat_file        IN OUT NOCOPY VARCHAR2
                             , p_hdr_file_handle IN OUT NOCOPY utl_file.file_type
                             , p_dat_file_handle IN OUT NOCOPY utl_file.file_type
                             ) RETURN NUMBER IS

      -- Local variables
      l_proc    VARCHAR2(50) := g_package||'.open_export_files';
      l_retcode NUMBER := 0;
      l_hdr_file_handle utl_file.file_type;
      l_dat_file_handle utl_file.file_type;

      -- Local exceptions
      e_invalid_dir EXCEPTION;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Build export header abd data file names
      p_hdr_file := 'GLCC_' || REPLACE(SUBSTR(p_bg_name,1,30),' ','_') ||
                    TO_CHAR(p_bg_id) || '.hdr';
      p_dat_file := 'GLCC_' || REPLACE(SUBSTR(p_bg_name,1,30),' ','_') ||
                    TO_CHAR(p_bg_id) || '.txt';
      hr_utility.set_message(800,'PER_50174_HDR_FILE_NAME');
      fnd_message.set_token('HDR_FILE_NAME',p_hdr_file);
      fnd_message.set_token('FILE_DIR',g_export_dir);
      writelog(fnd_message.get(),'N');
      hr_utility.set_message(800,'PER_50175_DAT_FILE_NAME');
      fnd_message.set_token('DAT_FILE_NAME',p_dat_file);
      fnd_message.set_token('FILE_DIR',g_export_dir);
      writelog(fnd_message.get(),'N');

      -- Open export header file
      BEGIN
         hr_utility.set_location(l_proc, 20);
         l_hdr_file_handle := utl_file.fopen( g_export_dir
                                            , p_hdr_file
                                            , 'w'
                                            );
         hr_utility.set_location(l_proc, 30);
         l_dat_file_handle := utl_file.fopen( g_export_dir
                                            , p_dat_file
                                            , 'w'
                                            );
         hr_utility.set_location(l_proc, 40);
         p_hdr_file_handle := l_hdr_file_handle;
         p_dat_file_handle := l_dat_file_handle;
      EXCEPTION
         WHEN OTHERS THEN
            hr_utility.set_location(l_proc, 50);
            RAISE e_invalid_dir;
      END; -- anonymous block

      hr_utility.set_location('Leaving: '|| l_proc, 60);

      RETURN l_retcode;

   EXCEPTION

      WHEN e_invalid_dir THEN
         hr_utility.set_location('Leaving: '||l_proc, 70);
         hr_utility.set_message(801,'HR_289426_INV_EXC_DIR');
         writelog(fnd_message.get(),'N');
         l_retcode := 2;
         RETURN l_retcode;

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '||l_proc, 80);
         hr_utility.set_location(SQLERRM, 85);
         writelog(SQLERRM,'N');
         writelog('Error opening export files','Y');
         l_retcode := 2;
         RETURN l_retcode;

   END open_export_files;

   --
   -- Close export header and data files.
   --
   FUNCTION close_export_files( p_hdr_file_handle IN utl_file.file_type
                              , p_dat_file_handle IN utl_file.file_type
                              ) RETURN NUMBER IS

      -- Local variables
      l_proc            VARCHAR2(50) := g_package||'.close_export_files';
      l_retcode         NUMBER := 0;
      l_hdr_file_handle utl_file.file_type;
      l_dat_file_handle utl_file.file_type;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      l_hdr_file_handle := p_hdr_file_handle;
      l_dat_file_handle := p_dat_file_handle;
      hr_utility.set_location(l_proc, 20);
      utl_file.fclose(l_hdr_file_handle);
      hr_utility.set_location(l_proc, 30);
      utl_file.fclose(l_dat_file_handle);

      hr_utility.set_location('Leaving: '|| l_proc, 40);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '||l_proc, 50);
         hr_utility.set_location(SQLERRM, 55);
         writelog(SQLERRM,'N');
         writelog('Error closing export files','Y');
         l_retcode := 2;
         RETURN l_retcode;

   END close_export_files;

   --
   -- Get Product Schema Name
   --
   FUNCTION get_schema( p_product IN VARCHAR2
                      ) RETURN VARCHAR2 IS

      -- Local Variables
      l_proc    VARCHAR2(50) := g_package||'.get_schema';
      l_dummy1  VARCHAR2(2000);
      l_dummy2  VARCHAR2(2000);
      l_schema  VARCHAR2(400);

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      IF fnd_installation.get_app_info( p_product
                                      , l_dummy1
                                      , l_dummy2
                                      , l_schema) THEN
         hr_utility.set_location('Leaving: '|| l_proc, 20);
         RETURN l_schema;
      ELSE
         hr_utility.set_location('Leaving: '|| l_proc, 30);
         RETURN NULL;
      END IF;

   END get_schema;

   --
   -- Get details for a value set value
   --
   FUNCTION get_vs_value_details( p_vs_id             IN NUMBER
                                , p_code              IN VARCHAR2
                                , p_description       IN OUT NOCOPY VARCHAR2
                                , p_start_date_active IN OUT NOCOPY DATE
                                , p_end_date_active      OUT NOCOPY DATE
                                ) RETURN NUMBER IS

      -- Local Variables
      l_proc    VARCHAR2(50) := g_package||'.get_vs_value_details';
      l_retcode NUMBER := 0;

      -- Local cursor to fetch flex value set value details
      CURSOR c_vs_value_dets( cp_vs_id IN NUMBER
                            , cp_code  IN VARCHAR2
                            ) IS
         SELECT description
              , start_date_active
              , end_date_active
         FROM   fnd_flex_values_vl
         WHERE  flex_value_set_id = cp_vs_id
         AND    flex_value = cp_code;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      OPEN c_vs_value_dets(p_vs_id, p_code);
      FETCH c_vs_value_dets INTO p_description, p_start_date_active, p_end_date_active;
      IF c_vs_value_dets%FOUND THEN
         hr_utility.set_location(l_proc, 20);
      ELSE
         hr_utility.set_location(l_proc, 30);
         p_description := NULL;
         p_start_date_active := NULL;
         p_end_date_active := NULL;
      END IF;
      CLOSE c_vs_value_dets;

      hr_utility.set_location('Leaving: '|| l_proc, 40);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 50);
         hr_utility.set_location(SQLERRM, 55);
         writelog(SQLERRM,'N');
         IF c_vs_value_dets%ISOPEN THEN
            CLOSE c_vs_value_dets;
         END IF;
         l_retcode := 2;
         RETURN l_retcode;

   END get_vs_value_details;

   --
   -- Get value set details
   --
   FUNCTION get_vs_details( p_vs_id   IN NUMBER
                          , p_vs_name IN OUT NOCOPY VARCHAR2
                          ) RETURN NUMBER IS

      -- Local Variables
      l_proc    VARCHAR2(50) := g_package||'.get_vs_details';
      l_retcode NUMBER := 0;

      -- Local cursor to fetch flex value set name
      CURSOR c_vs_dets( cp_vs_id IN NUMBER
                      ) IS
         SELECT flex_value_set_name
         FROM   fnd_flex_value_sets
         WHERE  flex_value_set_id = cp_vs_id;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      OPEN c_vs_dets(p_vs_id);
      FETCH c_vs_dets INTO p_vs_name;
      IF c_vs_dets%FOUND THEN
         hr_utility.set_location(l_proc, 20);
      ELSE
         hr_utility.set_location(l_proc, 30);
         p_vs_name := NULL;
      END IF;
      CLOSE c_vs_dets;

      hr_utility.set_location('Leaving: '|| l_proc, 40);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 50);
         hr_utility.set_location(SQLERRM, 55);
         writelog(SQLERRM,'N');
         IF c_vs_dets%ISOPEN THEN
            CLOSE c_vs_dets;
         END IF;
         l_retcode := 2;
         RETURN l_retcode;

   END get_vs_details;

   --
   -- Get value set for segment.
   --
   FUNCTION get_vs_for_seg( p_coa_id  IN            NUMBER
                          , p_segment IN            VARCHAR2
                          , p_vs_id   IN OUT NOCOPY NUMBER
                          ) RETURN NUMBER IS

      -- Local variables
      l_proc    VARCHAR2(50) := g_package||'.get_vs_for_seg';
      l_retcode NUMBER := 0;
      l_vs_name fnd_flex_value_sets.flex_value_set_name%TYPE;

      TYPE cur_type IS REF CURSOR;
      c_list cur_type;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);
      p_vs_id := -1;

      OPEN c_list FOR ' SELECT VS.flex_value_set_id,'||
                             ' VS.flex_value_set_name'||
                      ' FROM fnd_id_flex_segments_vl SEG,'||
                           ' fnd_flex_value_sets VS'||
                      ' WHERE UPPER(SEG.id_flex_code) = ''GL#'''||
                      ' AND SEG.application_id = 101'||
                      ' AND SEG.flex_value_set_id = VS.flex_value_set_id'||
                      ' AND SEG.enabled_flag = ''Y'''||
                      ' AND id_flex_num = :1'||
                      ' AND application_column_name = :2'
                  USING p_coa_id, p_segment;
      FETCH c_list INTO p_vs_id, l_vs_name;
      CLOSE c_list;

      hr_utility.set_location(p_segment||' valueset is '||
                              l_vs_name||'('||p_vs_id||')', 20);

      hr_utility.set_location('Leaving: '|| l_proc, 30);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 40);
         hr_utility.set_location(SQLERRM, 45);
         writelog(SQLERRM,'N');
         l_retcode := 2;
         RETURN l_retcode;

   END get_vs_for_seg;

   --
   -- Get segment for qualifier.
   --
   FUNCTION get_seg_for_qual( p_coa_id    IN            NUMBER
                            , p_qualifier IN            VARCHAR2
                            , p_segment   IN OUT NOCOPY VARCHAR2
                            ) RETURN NUMBER IS

      -- Local variables
      l_proc    VARCHAR2(50) := g_package||'.get_seg_for_qual';
      l_retcode NUMBER := 0;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      IF fnd_flex_apis.get_segment_column( 101
                                         , 'GL#'
                                         , p_coa_id
                                         , p_qualifier
                                         , p_segment
                                         ) THEN
         hr_utility.set_location(p_qualifier||' segment: '||p_segment, 20);
         hr_utility.set_location('Leaving: '|| l_proc, 30);
         RETURN l_retcode;
      ELSE
         hr_utility.set_location('Leaving: '|| l_proc, 40);
         l_retcode := 2;
         RETURN l_retcode;
      END IF;

   END get_seg_for_qual;

   --
   -- Derive the company and cost center value sets from the chart of
   -- accounts identifier.
   --
   FUNCTION derive_value_sets( p_coa_id            IN            NUMBER
                             , p_co_seg            IN OUT NOCOPY VARCHAR2
                             , p_cc_seg            IN OUT NOCOPY VARCHAR2
                             , p_co_vs_id          IN OUT NOCOPY NUMBER
                             , p_cc_vs_id          IN OUT NOCOPY NUMBER
                             ) RETURN NUMBER IS

      -- Local variables
      l_proc     VARCHAR2(50) := g_package||'.derive_value_sets';
      l_retcode  NUMBER := 0;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      p_co_seg := NULL;
      p_cc_seg := NULL;
      p_co_vs_id := -1;
      p_cc_vs_id := -1;

      -- Get company segment
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 20);
         l_retcode := get_seg_for_qual( p_coa_id
                                      , 'GL_BALANCING'
                                      , p_co_seg
                                      );
      END IF;

      -- Get cost center segment
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 30);
         l_retcode := get_seg_for_qual( p_coa_id
                                      , 'FA_COST_CTR'
                                      , p_cc_seg
                                      );
      END IF;

      -- Get company value set
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 40);
         l_retcode := get_vs_for_seg( p_coa_id
                                    , p_co_seg
                                    , p_co_vs_id
                                    );
      END IF;

      -- Get cost cente value set
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 50);
         l_retcode := get_vs_for_seg( p_coa_id
                                    , p_cc_seg
                                    , p_cc_vs_id
                                    );
      END IF;

      IF p_co_seg IS NULL OR p_cc_seg IS NULL OR p_co_vs_id = -1 OR p_cc_vs_id = -1 THEN
         hr_utility.set_location(l_proc, 60);

         -- Report missing flexfield details
         hr_utility.set_message(800,'PER_289604_WRN_CHRT_ACC_ID');
         fnd_message.set_token('ID',p_coa_id);
         writelog(fnd_message.get(),'N');

         IF p_co_seg IS NULL THEN
            hr_utility.set_location(l_proc, 70);
            writelog(fnd_message.get_string(800,'PER_289605_WRN_COMP_SEG'),'N');
         END IF;

         IF p_cc_seg IS NULL THEN
            hr_utility.set_location(l_proc, 80);
            writelog(fnd_message.get_string(800,'PER_289606_WRN_CC_SEG'),'N');
         END IF;

         IF p_co_vs_id = -1 THEN
            hr_utility.set_location(l_proc, 90);
            writelog(fnd_message.get_string(800,'PER_289607_WRN_COMP_VS'),'N');
         END IF;

         IF p_cc_vs_id = -1 THEN
            hr_utility.set_location(l_proc, 100);
            writelog(fnd_message.get_string(800,'PER_289608_WRN_CC_VS'),'N');
         END IF;

         l_retcode := 1;
      END IF; -- if values not fetched

      hr_utility.set_location('Leaving: '|| l_proc, 110);

      RETURN l_retcode;

   END derive_value_sets;

   --
   -- Get the business group identifier for the given company details.
   --
   FUNCTION get_business_group_id( p_co_vs_id IN            NUMBER
                                 , p_co       IN            VARCHAR2
                                 , p_bg_id    IN OUT NOCOPY NUMBER
                                 ) RETURN NUMBER IS

      -- Local Variables
      l_proc    VARCHAR2(50) := g_package||'.get_business_group_id';
      l_retcode NUMBER := 0;

      TYPE number_table IS TABLE OF NUMBER;
      lt_bg_id_tab number_table;

      -- Local cursor to fetch business group id based on company details.
      CURSOR c_bg_id( cp_co_vs_id IN NUMBER
                    , cp_co       IN VARCHAR2
                    ) IS
         SELECT DISTINCT UNITS.business_group_id
         FROM   hr_all_organization_units UNITS
              , hr_organization_information CLASS
              , hr_organization_information CC
         WHERE  UNITS.organization_id = CLASS.organization_id
         AND    CLASS.org_information_context = 'CLASS'
         AND    CLASS.org_information1 = 'CC'
         AND    CLASS.organization_id = CC.organization_id
         AND    CC.org_information_context = 'Company Cost Center'
         AND    CC.org_information2 = cp_co_vs_id
         AND    CC.org_information3 = cp_co
         AND    CC.org_information4 IS NULL
         AND    CC.org_information5 IS NULL;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      OPEN c_bg_id(p_co_vs_id, p_co);
      FETCH c_bg_id BULK COLLECT INTO lt_bg_id_tab LIMIT 10;
      CLOSE c_bg_id;

      hr_utility.set_location(l_proc, 20);

      IF (lt_bg_id_tab.COUNT > 1) THEN
         -- This company exists in more than one business group
         hr_utility.set_location(l_proc, 30);
         p_bg_id := -1;
         l_retcode := 2;
         writelog(fnd_message.get_string('PER','HR_289491_CO_MULT_BG'),'N');
      ELSIF (lt_bg_id_tab.COUNT = 0) THEN
         -- The company does not exist in any business group.
         hr_utility.set_location(l_proc, 40);
         p_bg_id := -1;
         l_retcode := 2;
         writelog(fnd_message.get_string('PER','HR_289601_CO_NO_BG'),'N');
      ELSIF (lt_bg_id_tab.COUNT = 1) THEN
         hr_utility.set_location(l_proc, 50);
         p_bg_id := lt_bg_id_tab(1);
         hr_utility.set_location('Business Group Id:'||p_bg_id, 50);
      END IF;

      hr_utility.set_location('Leaving: '|| l_proc, 60);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 70);
         hr_utility.set_location(SQLERRM, 75);
         writelog(SQLERRM,'N');
         IF c_bg_id%ISOPEN THEN
            CLOSE c_bg_id;
         END IF;
         l_retcode := 2;
         RETURN l_retcode;

   END get_business_group_id;

   --
   -- Get the chart of accounts id for the code combination id
   --
   FUNCTION get_chart_of_accounts_id( p_ccid   IN            NUMBER
                                    , p_coa_id IN OUT NOCOPY NUMBER
                                    ) RETURN NUMBER IS

      -- Local Variables
      l_proc    VARCHAR2(50) := g_package||'.get_chart_of_accounts_id';
      l_retcode NUMBER := 0;

      -- Local cursor to fetch chart of accounts id based on code combination id.
      CURSOR c_coa_id( cp_ccid IN NUMBER
                     ) IS
         SELECT chart_of_accounts_id
         FROM   gl_code_combinations
         WHERE  code_combination_id = cp_ccid;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      OPEN c_coa_id(p_ccid);
      FETCH c_coa_id INTO p_coa_id;
      IF c_coa_id%FOUND THEN
         hr_utility.set_location(l_proc, 20);
      ELSE
         hr_utility.set_location(l_proc, 30);
         p_coa_id := -1;
         l_retcode := 2;
      END IF;
      CLOSE c_coa_id;

      hr_utility.set_location('Leaving: '|| l_proc, 40);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 70);
         hr_utility.set_location(SQLERRM, 75);
         writelog(SQLERRM,'N');
         IF c_coa_id%ISOPEN THEN
            CLOSE c_coa_id;
         END IF;
         l_retcode := 2;
         RETURN l_retcode;

   END get_chart_of_accounts_id;

   --
   -- Check if company cost center org info type exists
   --
   FUNCTION co_cc_org_info_type_exists( p_org_id   IN            NUMBER
                                      , p_co       IN OUT NOCOPY VARCHAR2
                                      , p_co_vs_id IN OUT NOCOPY NUMBER
                                      , p_cc       IN OUT NOCOPY VARCHAR2
                                      , p_cc_vs_id IN OUT NOCOPY NUMBER
                                      ) RETURN BOOLEAN IS

      -- Local variables
      l_proc   VARCHAR2(50) := g_package||'.co_cc_org_info_type_exists';
      l_exists BOOLEAN;

      -- Cursor to check if co cc org info type exists
      CURSOR c_chk_co_cc_org_info_type IS
         SELECT org_information2
              , org_information3
              , org_information4
              , org_information5
         FROM   hr_organization_information
         WHERE  organization_id = p_org_id
         AND    org_information_context = 'Company Cost Center';

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      OPEN c_chk_co_cc_org_info_type;
      FETCH c_chk_co_cc_org_info_type INTO p_co_vs_id, p_co, p_cc_vs_id, p_cc;
      IF c_chk_co_cc_org_info_type%NOTFOUND THEN
         hr_utility.set_location(l_proc, 20);
         l_exists := FALSE;
      ELSE
         hr_utility.set_location(l_proc, 30);
         l_exists := TRUE;
      END IF;
      CLOSE c_chk_co_cc_org_info_type;

      hr_utility.set_location('Leaving: '|| l_proc, 40);

      RETURN l_exists;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 50);
         IF c_chk_co_cc_org_info_type%ISOPEN THEN
            CLOSE c_chk_co_cc_org_info_type;
         END IF;
         l_exists := FALSE;
         RETURN l_exists;

   END co_cc_org_info_type_exists;

   --
   -- Check if HR Organization classification exists
   --
   FUNCTION hr_org_class_exists( p_org_id IN NUMBER
                               ) RETURN BOOLEAN IS

      -- Local variables
      l_proc   VARCHAR2(50) := g_package||'.hr_org_class_exists';
      l_exists BOOLEAN;
      l_dummy  NUMBER;

      -- Cursor to check if classification exists
      CURSOR c_chk_hr_org_class IS
         SELECT 1
         FROM   hr_organization_information
         WHERE  organization_id = p_org_id
         --AND    org_information_context = 'HR_ORG';
         AND    org_information_context = 'CLASS'
         AND    org_information1 = 'HR_ORG';

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      OPEN c_chk_hr_org_class;
      FETCH c_chk_hr_org_class INTO l_dummy;
      IF c_chk_hr_org_class%NOTFOUND THEN
         hr_utility.set_location(l_proc, 20);
         l_exists := FALSE;
      ELSE
         hr_utility.set_location(l_proc, 30);
         l_exists := TRUE;
      END IF;
      CLOSE c_chk_hr_org_class;

      hr_utility.set_location('Leaving: '|| l_proc, 40);

      RETURN l_exists;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 50);
         IF c_chk_hr_org_class%ISOPEN THEN
            CLOSE c_chk_hr_org_class;
         END IF;
         l_exists := FALSE;
         RETURN l_exists;

   END hr_org_class_exists;

   --
   -- Check if Company Cost Center classification exists
   --
   FUNCTION co_cc_class_exists( p_org_id      IN            NUMBER
                              , p_org_info2   IN OUT NOCOPY VARCHAR2
                              , p_org_info_id IN OUT NOCOPY NUMBER
                              , p_ovn         IN OUT NOCOPY NUMBER
                              ) RETURN BOOLEAN IS

      -- Local variables
      l_proc   VARCHAR2(50) := g_package||'.co_cc_class_exists';
      l_exists BOOLEAN;

      -- Cursor to check if classification exists
      CURSOR c_chk_co_cc_class IS
         SELECT org_information2
               ,org_information_id
               ,object_version_number
         FROM   hr_organization_information
         WHERE  organization_id = p_org_id
         AND    org_information_context = 'CLASS'
         AND    org_information1 = 'CC';

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      OPEN c_chk_co_cc_class;
      FETCH c_chk_co_cc_class INTO p_org_info2, p_org_info_id, p_ovn;
      IF c_chk_co_cc_class%NOTFOUND THEN
         hr_utility.set_location(l_proc, 20);
         l_exists := FALSE;
      ELSE
         hr_utility.set_location(l_proc, 30);
         l_exists := TRUE;
      END IF;
      CLOSE c_chk_co_cc_class;

      hr_utility.set_location('Leaving: '|| l_proc, 40);

      RETURN l_exists;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 50);
         IF c_chk_co_cc_class%ISOPEN THEN
            CLOSE c_chk_co_cc_class;
         END IF;
         l_exists := FALSE;
         RETURN l_exists;

   END co_cc_class_exists;

   --
   -- Create company cost center organization information type.
   --
   FUNCTION create_co_cc_org_info_type( p_class_id     IN NUMBER
                                      , p_class_ovn    IN NUMBER
                                      , p_enabled_flag IN VARCHAR2
                                      , p_org_id       IN NUMBER
                                      , p_co           IN VARCHAR2
                                      , p_co_vs_id     IN NUMBER
                                      , p_cc           IN VARCHAR2
                                      , p_cc_vs_id     IN NUMBER
                                      , p_org_name     IN VARCHAR2
                                      ) RETURN NUMBER IS

      -- Local variables
      l_proc          VARCHAR2(50) := g_package||'.create_co_cc_org_info_type';
      l_retcode       NUMBER := 0;
      l_orig_info_id  NUMBER := -1;
      l_orig_ovn      NUMBER := -1;
      l_org_info_type VARCHAR2(2) := 'CC';
      l_class_ovn     NUMBER := p_class_ovn; -- to avoid expression assignment issue

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- If classification is disabled, temporarily enable it.
      IF p_enabled_flag = 'N' THEN
         hr_utility.set_location(l_proc, 20);

         hr_organization_api.enable_org_classification
               ( p_effective_date        => SYSDATE
               , p_org_information_id    => p_class_id
               , p_org_info_type_code    => l_org_info_type
               , p_object_version_number => l_class_ovn
               );
      END IF; -- classification was disabled

      hr_utility.set_location(l_proc, 30);

      -- Create the organization information type
      hr_organization_api.create_org_information
               ( p_effective_date        => SYSDATE
               , p_organization_id       => p_org_id
               , p_org_info_type_code    => 'Company Cost Center'
               , p_org_information2      => p_co_vs_id
               , p_org_information3      => p_co
               , p_org_information4      => p_cc_vs_id
               , p_org_information5      => p_cc
               , p_org_information_id    => l_orig_info_id
               , p_object_version_number => l_orig_ovn
               );

      hr_utility.set_message(800,'PER_50167_CREATED_CO_CC_INFO');
      fnd_message.set_token('CO_CC_CLASS_INFO_ID',l_orig_info_id);
      writelog(fnd_message.get(),'N');
      hr_utility.set_location(l_proc, 40);

      -- If classification was disabled, re-disable it.
      IF p_enabled_flag = 'N' THEN
         hr_utility.set_location(l_proc, 50);

         hr_organization_api.disable_org_classification
               ( p_effective_date        => SYSDATE
               , p_org_information_id    => p_class_id
               , p_org_info_type_code    => l_org_info_type
               , p_object_version_number => l_class_ovn
               );
      END IF; -- classification was disabled

      hr_utility.set_location('Leaving: '|| l_proc, 60);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         writelog(SQLCODE||' - '||SQLERRM,'N');
         hr_utility.set_location('Leaving: '|| l_proc, 70);
         hr_utility.set_location(SQLERRM, 75);
         hr_utility.set_message(800,'PER_50168_ERR_CRE_CO_CC_INFO');
         fnd_message.set_token('ORG_NAME',p_org_name);
         writelog(fnd_message.get(),'N');
         l_retcode := 2;
         RETURN l_retcode;

   END create_co_cc_org_info_type;

   --
   -- Create HR Organization classification if required.
   --
   FUNCTION create_hr_org_class( p_org_id   IN NUMBER
                               , p_org_name IN VARCHAR2
                               ) RETURN NUMBER IS

      -- Local variables
      l_proc      VARCHAR2(50) := g_package||'.create_hr_org_class';
      l_retcode   NUMBER := 0;
      l_class_id  NUMBER := -1;
      l_class_ovn NUMBER := -1;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Create HR Organization classification if allowed by profile.
      IF g_class_profile = 'CCHR' THEN
         hr_utility.set_location(l_proc, 20);

         hr_organization_api.create_org_classification
               ( p_effective_date        => SYSDATE
               , p_organization_id       => p_org_id
               , p_org_classif_code      => 'HR_ORG'
               , p_org_information_id    => l_class_id
               , p_object_version_number => l_class_ovn
               );

         hr_utility.set_message(800,'PER_50165_CREATED_HR_ORG');
         fnd_message.set_token('HR_ORG_CLASS_ID',l_class_id);
         writelog(fnd_message.get(),'N');
      END IF; -- class profile check

      hr_utility.set_location('Leaving: '|| l_proc, 30);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         writelog(SQLCODE||' - '||SQLERRM,'N');
         hr_utility.set_location('Leaving: '|| l_proc, 40);
         hr_utility.set_location(SQLERRM, 45);
         hr_utility.set_message(800,'PER_50166_ERR_CRE_HR_ORG');
         fnd_message.set_token('ORG_NAME',p_org_name);
         writelog(fnd_message.get(),'N');
         l_retcode := 2;
         RETURN l_retcode;

   END create_hr_org_class;

   --
   -- Create Company Cost Center classification if required.
   --
   FUNCTION create_co_cc_class( p_org_id   IN NUMBER
                              , p_co_vs_id IN NUMBER
                              , p_co       IN VARCHAR2
                              , p_cc_vs_id IN NUMBER
                              , p_cc       IN VARCHAR2
                              , p_org_name IN VARCHAR2
                              ) RETURN NUMBER IS

      -- Local variables
      l_proc          VARCHAR2(50) := g_package||'.create_co_cc_class';
      l_retcode       NUMBER := 0;
      l_orig_info_id  NUMBER := -1;
      l_class_info_id NUMBER := -1;
      l_orig_ovn      NUMBER := -1;
      l_class_ovn     NUMBER := -1;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Create Company Cost Center classification if allowed by profile.
      IF g_class_profile LIKE 'CC%' THEN
         hr_utility.set_location(l_proc, 20);

         hr_organization_api.create_company_cost_center
               ( p_effective_date            => SYSDATE
               , p_organization_id           => p_org_id
               , p_company_valueset_id       => p_co_vs_id
               , p_company                   => p_co
               , p_costcenter_valueset_id    => p_cc_vs_id
               , p_costcenter                => p_cc
               , p_ori_org_information_id    => l_orig_info_id
               , p_ori_object_version_number => l_orig_ovn
               , p_org_information_id        => l_class_info_id
               , p_object_version_number     => l_class_ovn
               );

         hr_utility.set_message(800,'PER_50159_COMP_CODE');
         fnd_message.set_token('COMP_CODE',p_co);
         writelog(fnd_message.get(),'N');
         hr_utility.set_message(800,'PER_50160_COST_CENTER_CODE');
         fnd_message.set_token('COST_CENTER_CODE',p_cc);
         writelog(fnd_message.get(),'N');
         hr_utility.set_message(800,'PER_50163_CREATED_CO_CC');
         fnd_message.set_token('CO_CC_CLASS_ID',l_orig_info_id||' ('||l_class_info_id||')');
         writelog(fnd_message.get(),'N');
      END IF; -- class profile check

      hr_utility.set_location('Leaving: '|| l_proc, 30);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         writelog(SQLCODE||' - '||SQLERRM,'N');
         hr_utility.set_location('Leaving: '|| l_proc, 40);
         hr_utility.set_location(SQLERRM, 45);
         hr_utility.set_message(800,'PER_50164_ERR_CRE_CO_CC');
         fnd_message.set_token('ORG_NAME',p_org_name);
         writelog(fnd_message.get(),'N');
         l_retcode := 2;
         RETURN l_retcode;

   END create_co_cc_class;

   --
   -- Create an organization
   --
   FUNCTION create_org( p_bg_id          IN            VARCHAR2
                      , p_org_start_date IN            DATE
                      , p_org_end_date   IN            DATE
                      , p_org_name       IN            VARCHAR2
                      , p_org_id         IN OUT NOCOPY NUMBER
                      ) RETURN NUMBER IS

      -- Local variables
      l_proc    VARCHAR2(50) := g_package||'.create_org';
      l_retcode NUMBER := 0;
      l_org_ovn NUMBER := -1;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      hr_organization_api.create_organization
            ( p_effective_date         => SYSDATE
            , p_business_group_id      => p_bg_id
            , p_date_from              => p_org_start_date
            , p_date_to                => p_org_end_date
            , p_name                   => p_org_name
            , p_internal_external_flag => 'INT'
            , p_organization_id        => p_org_id
            , p_object_version_number  => l_org_ovn
            );

      hr_utility.set_message(800,'PER_50161_CREATED_ORG');
      fnd_message.set_token('ORG_ID',p_org_id);
      writelog(fnd_message.get(),'N');

      hr_utility.set_location('Leaving: '|| l_proc, 20);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         writelog(SQLCODE||' - '||SQLERRM,'N');
         hr_utility.set_location('Leaving: '|| l_proc, 30);
         hr_utility.set_location(SQLERRM, 35);
         hr_utility.set_message(800,'PER_50162_ERR_CRE_ORG');
         fnd_message.set_token('ORG_NAME',p_org_name);
         writelog(fnd_message.get(),'N');
         l_retcode := 2;
         RETURN l_retcode;

   END create_org;

   --
   -- Check if ORG Name already exists
   --
   FUNCTION org_name_exists( p_bg_id    IN            VARCHAR2
                           , p_org_name IN            VARCHAR2
                           , p_org_id   IN OUT NOCOPY NUMBER
                           ) RETURN BOOLEAN IS

      -- Local variables
      l_proc   VARCHAR2(50) := g_package||'.org_name_exists';
      l_exists BOOLEAN;

      -- Cursor to test if ORG with given name already exists.
      CURSOR c_chk_org_name IS
         SELECT organization_id
         FROM   hr_all_organization_units
         WHERE  name = p_org_name
         AND    business_group_id = p_bg_id;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      OPEN c_chk_org_name;
      FETCH c_chk_org_name INTO p_org_id;
      IF c_chk_org_name%NOTFOUND THEN
         hr_utility.set_location(l_proc, 20);
         l_exists := FALSE;
      ELSE
         hr_utility.set_location(l_proc, 30);
         l_exists := TRUE;
      END IF;
      CLOSE c_chk_org_name;

      hr_utility.set_location('Leaving: '|| l_proc, 40);

      RETURN l_exists;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 50);
         IF c_chk_org_name%ISOPEN THEN
            CLOSE c_chk_org_name;
         END IF;
         l_exists := FALSE;
         RETURN l_exists;

   END org_name_exists;

   --
   -- Amend ORG Name for uniqueness
   --
   -- Make the ORG name unique by appending (n) to the ORG Name where
   -- n is the number of attempts to make the name unique. Quit after
   -- n exceeds max allowed tries.
   --
   FUNCTION make_org_name_unique( p_bg_id          IN            NUMBER
                                , p_org_name       IN            VARCHAR2
                                , p_new_org_name   IN OUT NOCOPY VARCHAR2
                                ) RETURN NUMBER IS

      -- Local variables
      l_proc            VARCHAR2(50) := g_package||'.make_org_name_unique';
      l_retcode         NUMBER := 0;
      l_unique          BOOLEAN := FALSE;
      l_retry_count     NUMBER := 1;
      l_org_name_suffix VARCHAR2(5) := NULL;
      l_org_id          NUMBER;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);
      p_new_org_name := p_org_name;

      -- Loop for the configured maximum number of retries to find an ORG Name
      -- which is not already used. Make the ORG Name unique in a manner similar
      -- to FNDLOAD utility which adds suffix "(n)" to the name.
      WHILE (l_retry_count <= g_max_retries AND NOT l_unique) LOOP
         -- Coin a new name
         l_org_name_suffix := '('||TO_CHAR(l_retry_count)||')';
         p_new_org_name := SUBSTRB(p_new_org_name
                                  ,1
                                  ,g_org_name_max_length - LENGTH(l_org_name_suffix)
                                  )||l_org_name_suffix;

         -- Check if new name already exists
         IF org_name_exists(p_bg_id, p_new_org_name, l_org_id) THEN
            l_retry_count := l_retry_count + 1;
         ELSE
            l_unique := TRUE;
         END IF;
      END LOOP;

      IF NOT l_unique THEN
         -- Failed to get a unique ORG Name
         hr_utility.set_message(800,'PER_50171_NO_UNIQUE_NAME');
         fnd_message.set_token('ORG_NAME',p_org_name);
         writelog(fnd_message.get(),'N');
         p_new_org_name := NULL;
         l_retcode := 1;
      END IF;

      hr_utility.set_location('Leaving: '|| l_proc, 30);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 40);
         hr_utility.set_location(SQLERRM, 45);
         writelog(SQLERRM,'N');
         p_new_org_name := NULL;
         l_retcode := 2;
         RETURN l_retcode;

   END make_org_name_unique;

   --
   -- Derive the ORG Name
   --
   -- Get the company description for the company code.
   -- Get the cost center description for the cost center code.
   -- Calculate the ORG start date.
   -- Phase 2a - calc the ORG end date or null (thus OUT param).
   -- Paste in the values to the ORG Name format.
   --
   FUNCTION derive_org_name( p_mode           IN            VARCHAR2
                           , p_co             IN            VARCHAR2
                           , p_co_vs_id       IN            NUMBER
                           , p_cc             IN            VARCHAR2
                           , p_cc_vs_id       IN            NUMBER
                           , p_co_desc        IN OUT NOCOPY VARCHAR2
                           , p_cc_desc        IN OUT NOCOPY VARCHAR2
                           , p_org_name       IN OUT NOCOPY VARCHAR2
                           , p_org_start_date IN OUT NOCOPY DATE
                           , p_org_end_date   IN OUT NOCOPY DATE
                           ) RETURN NUMBER IS

      -- Local variables
      l_proc           VARCHAR2(50) := g_package||'.derive_org_name';
      l_retcode        NUMBER := 0;
      l_co_start_date  fnd_flex_values_vl.start_date_active%TYPE;
      l_cc_start_date  fnd_flex_values_vl.start_date_active%TYPE;
      l_co_end_date    fnd_flex_values_vl.end_date_active%TYPE;
      l_cc_end_date    fnd_flex_values_vl.end_date_active%TYPE;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Get company details from the company code
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 20);
         l_retcode := get_vs_value_details( p_co_vs_id
                                          , p_co
                                          , p_co_desc
                                          , l_co_start_date
                                          , l_co_end_date
                                          );
         IF p_co_desc IS NULL THEN
            p_co_desc := p_co;
         END IF;
      END IF; -- retcode check

      -- Get cost center details from the cost center code
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 30);
         l_retcode := get_vs_value_details( p_cc_vs_id
                                          , p_cc
                                          , p_cc_desc
                                          , l_cc_start_date
                                          , l_cc_end_date
                                          );
         IF p_cc_desc IS NULL THEN
            p_cc_desc := p_cc;
         END IF;
      END IF; -- retcode check

      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 40);

         -- Set the ORG start date to be the later of company and cost center
         -- start dates. If these are null, set to default date '01/01/1990'.
         p_org_start_date := GREATEST( NVL(l_co_start_date, TO_DATE('01/01/1990','DD/MM/RRRR'))
                                     , NVL(l_cc_start_date, TO_DATE('01/01/1990','DD/MM/RRRR'))
                                     );

         -- phase 2a: set the Org end date to earlier of co and cc VS end dates, or null
         IF l_co_end_date IS NOT NULL AND l_cc_end_date IS NOT NULL THEN
           IF l_co_end_date >= l_cc_end_date THEN
             p_org_end_date := l_cc_end_date; -- Bug 4402730 use minimum end_date.
           ELSE
             p_org_end_date := l_co_end_date;
           END IF;
         ELSIF l_co_end_date IS NULL AND l_cc_end_date IS NOT NULL THEN
           p_org_end_date := l_cc_end_date;
         ELSIF l_co_end_date IS NOT NULL AND l_cc_end_date IS NULL THEN
           p_org_end_date := l_co_end_date;
         END IF;


         hr_utility.set_location(l_proc, 50);

         -- Compile the ORG name by pasting in the details
         SELECT SUBSTRB(REPLACE(REPLACE(REPLACE(REPLACE(g_org_name_format
                                                       ,'$COC'
                                                       ,p_co
                                                       )
                                               ,'$CCC'
                                               ,p_cc
                                               )
                                         ,'$CON'
                                         ,p_co_desc
                                         )
                                ,'$CCN'
                                ,p_cc_desc
                                )
                       ,1
                       ,g_org_name_max_length
                       )
         INTO p_org_name
         FROM dual;

         hr_utility.set_location(l_proc, 60);

         -- Write the generated name to the LOG file
         IF p_mode IN ('CREATE_MAINTAIN','SINGLE_ORG') THEN
            hr_utility.set_message(800,'PER_50158_ORG_NAME');
            fnd_message.set_token('ORG_NAME',p_org_name);
            fnd_message.set_token('ORG_START_DATE',p_org_start_date);
            fnd_message.set_token('ORG_END_DATE',p_org_end_date);
            writelog(fnd_message.get(),'N');
         END IF;
      END IF; -- retcode check

      hr_utility.set_location('Leaving: '|| l_proc, 70);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 80);
         hr_utility.set_location(SQLERRM, 85);
         writelog(SQLERRM,'N');
         l_retcode := 2;
         RETURN l_retcode;

   END derive_org_name;

   --
   -- Generate ORG and CO/CC Classifications as required
   --
   -- Derive an ORG Name in the correct format.
   -- If an ORG with this name does not exists.
   --    Create the ORG.
   --    Create the CoCC classification if allowed by profile.
   --    Create the HR Org classification if allowed by profile.
   -- Else an ORG with this name already exists.
   --    If COCC classification does not exist for the ORG
   --       Create the CoCC classification if allowed by profile.
   --       If HR ORG classification does not exist for the ORG.
   --          Create the HR Org classification if allowed by profile.
   --    Else COCC classification exists for the ORG
   --       If classified ORG does not have CoCC Info Type
   --          Create CoCC Info Type
   --          If HR ORG classification does not exist for the ORG.
   --             Create the HR Org classification if allowed by profile.
   --       Else classified ORG has CoCC Info Type
   --          If CoCC Info Type data exists
   --             The ORG we have does not appear to fully match.
   --             So make the ORG Name unique.
   --             Create an ORG.
   --             Create the CoCC classification if allowed by profile.
   --             Create the HR Org classification if allowed by profile.
   --
   FUNCTION gen_org_co_cc_class( p_mode     IN            VARCHAR2
                               , p_bg_id    IN            NUMBER
                               , p_coa_id   IN            NUMBER
                               , p_co       IN            VARCHAR2
                               , p_co_vs_id IN            NUMBER
                               , p_cc       IN            VARCHAR2
                               , p_cc_vs_id IN            NUMBER
                               , p_org_id   IN OUT NOCOPY NUMBER
                               ) RETURN NUMBER IS

      -- Local variables
      l_proc           VARCHAR2(50) := g_package||'.gen_org_co_cc_class';
      l_retcode        NUMBER := 0;
      l_org_name       hr_all_organization_units.name%TYPE;
      l_new_org_name   hr_all_organization_units.name%TYPE;
      l_org_start_date fnd_flex_values_vl.start_date_active%TYPE;
      l_org_end_date   fnd_flex_values_vl.end_date_active%TYPE;
      l_class_enabled  hr_organization_information.org_information2%TYPE;
      l_class_id       hr_organization_information.org_information_id%TYPE;
      l_class_ovn      hr_organization_information.object_version_number%TYPE;
      l_co             VARCHAR2(240);
      l_cc             VARCHAR2(240);
      l_co_vs_id       NUMBER(15); -- Id of company value set
      l_cc_vs_id       NUMBER(15); -- Id of cost center value set
      l_co_desc        fnd_flex_values_vl.description%TYPE;
      l_cc_desc        fnd_flex_values_vl.description%TYPE;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      writelog('Processing P_BG_ID: '||p_bg_id||
                        ', P_COA_ID: '||p_coa_id||
                        ', P_CO: '||p_co||
                        ', P_CO_VS_ID: '||p_co_vs_id||
                        ', P_CC: '||p_cc||
                        ', P_CC_VS_ID: '||p_cc_vs_id,'Y');

      -- At this point, there either isnt an ORG and one will need to be
      -- created, or there is an ORG without the requisite classification
      -- and this needs to be added to the existing ORG.

      -- Get the ORG Name in the correct format
      IF l_retcode = 0 THEN
         l_retcode := derive_org_name( p_mode
                                     , p_co
                                     , p_co_vs_id
                                     , p_cc
                                     , p_cc_vs_id
                                     , l_co_desc
                                     , l_cc_desc
                                     , l_org_name
                                     , l_org_start_date
                                     , l_org_end_date
                                     );
      END IF; -- l_retocde is 0

      -- Check if ORG with coined named already exists in the business group
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 20);

         IF NOT org_name_exists(p_bg_id, l_org_name, p_org_id) THEN
            hr_utility.set_location(l_proc, 30);

            -- ORG with derived name does not exist. Create new ORG.
            l_retcode := create_org( p_bg_id
                                   , l_org_start_date
                                   , l_org_end_date
                                   , l_org_name
                                   , p_org_id
                                   );

            hr_utility.set_location(l_proc, 40);

            -- Create Company Cost Center classification
            IF l_retcode = 0 THEN
               hr_utility.set_location(l_proc, 50);

               l_retcode := create_co_cc_class( p_org_id
                                              , p_co_vs_id
                                              , p_co
                                              , p_cc_vs_id
                                              , p_cc
                                              , l_org_name
                                              );
            END IF;

            hr_utility.set_location(l_proc, 60);

            -- Create HR Org classification
            IF l_retcode = 0 THEN
               hr_utility.set_location(l_proc, 70);

               l_retcode := create_hr_org_class( p_org_id
                                               , l_org_name
                                               );
            END IF;

            hr_utility.set_location(l_proc, 80);

         ELSE -- ORG with Name found
            hr_utility.set_location(l_proc, 90);

            -- So the organization exists. Check if Company Cost Center
            -- classification exists.
            IF NOT co_cc_class_exists(p_org_id, l_class_enabled, l_class_id, l_class_ovn) THEN
               hr_utility.set_location(l_proc, 100);

               -- Company Cost Center classification not found. Create it.
               l_retcode := create_co_cc_class( p_org_id
                                              , p_co_vs_id
                                              , p_co
                                              , p_cc_vs_id
                                              , p_cc
                                              , l_org_name
                                              );

               -- Check if HR ORG classification exists.
               IF l_retcode = 0 THEN
                  hr_utility.set_location(l_proc, 110);

                  IF NOT hr_org_class_exists(p_org_id) THEN
                     hr_utility.set_location(l_proc, 120);

                     -- HR Org classification does not exist. Create it.
                     l_retcode := create_hr_org_class( p_org_id
                                                     , l_org_name
                                                     );
                  END IF; -- HROrg classification not found

               END IF; -- retcode is 0

            ELSE -- CoCC classification found
               hr_utility.set_location(l_proc, 130);

               -- Check if classified ORG has CC Info Type.
               IF NOT co_cc_org_info_type_exists(p_org_id, l_co, l_co_vs_id, l_cc, l_cc_vs_id) THEN
                  hr_utility.set_location(l_proc, 140);

                  -- CC Info Type not found. Create it.
                  l_retcode := create_co_cc_org_info_type( l_class_id
                                                         , l_class_ovn
                                                         , l_class_enabled
                                                         , p_org_id
                                                         , p_co
                                                         , p_co_vs_id
                                                         , p_cc
                                                         , p_cc_vs_id
                                                         , l_org_name
                                                         );

                  -- Check if HR ORG classification exists.
                  IF l_retcode = 0 THEN
                     hr_utility.set_location(l_proc, 150);

                     IF NOT hr_org_class_exists(p_org_id) THEN
                        hr_utility.set_location(l_proc, 160);

                        -- HR Org classification does not exist. Create it.
                        l_retcode := create_hr_org_class( p_org_id
                                                        , l_org_name
                                                        );
                     END IF; -- HROrg classification not found

                  END IF; -- retcode is 0

               ELSE -- CC Info Type exists
                  hr_utility.set_location(l_proc, 170);

                  -- Check if info type data exists
                  IF l_co IS NULL AND l_co_vs_id IS NULL AND
                     l_cc IS NULL AND l_cc_vs_id IS NULL THEN

                     hr_utility.set_location(l_proc, 180);
                     -- This means that info type data is missing. This should never
                     -- happen as the company value set is mandatory.

                  ELSE -- Info Type data exists

                     hr_utility.set_location(l_proc, 190);
                     -- At this point the info type exists with data but does not match
                     -- information for our prospective organization. We will therefore
                     -- need to create a new organization. However, the name we have
                     -- already exists. So we must first make the name unique.

                     p_org_id := NULL;
                     l_retcode := make_org_name_unique( p_bg_id
                                                      , l_org_name
                                                      , l_new_org_name
                                                      );

                     -- Create the organization.
                     IF l_retcode = 0 THEN
                        hr_utility.set_location(l_proc, 200);

                        l_retcode := create_org( p_bg_id
                                               , l_org_start_date
                                               , l_org_end_date
                                               , l_new_org_name
                                               , p_org_id
                                               );
                     END IF; -- retcode is 0

                     -- Create the Company Cost Center classification.
                     IF l_retcode = 0 THEN
                        hr_utility.set_location(l_proc, 210);

                        l_retcode := create_co_cc_class( p_org_id
                                                       , p_co_vs_id
                                                       , p_co
                                                       , p_cc_vs_id
                                                       , p_cc
                                                       , l_new_org_name
                                                       );
                     END IF; -- retcode is 0

                     -- Create the HR Org classification.
                     IF l_retcode = 0 THEN
                        hr_utility.set_location(l_proc, 220);

                        l_retcode := create_hr_org_class( p_org_id
                                                        , l_new_org_name
                                                        );
                     END IF; -- retcode is 0

                  END IF; -- Info Type data exists

               END IF; -- CC Info Type does not exist

            END IF; -- CoCC classification not found

         END IF; -- ORG with Name not found

      END IF; -- l_retocde is 0

      hr_utility.set_location('Leaving: '|| l_proc, 230);

      RETURN l_retcode;

   END gen_org_co_cc_class;

   --
   -- Get additional record details for reporting/exporting
   --
   FUNCTION get_details_to_report( p_mode IN VARCHAR2
                                 ) RETURN NUMBER IS

      -- Local Variables
      l_proc           VARCHAR2(50) := g_package||'.get_details_to_report';
      l_retcode        NUMBER := 0;
      l_coa_id         NUMBER;
      l_co             VARCHAR2(240); -- Company value
      l_cc             VARCHAR2(240); -- Cost Center value
      l_co_vs_id       NUMBER(15); -- Id of company value set
      l_cc_vs_id       NUMBER(15); -- Id of cost center value set
      l_co_desc        fnd_flex_values_vl.description%TYPE;
      l_cc_desc        fnd_flex_values_vl.description%TYPE;
      l_org_name       hr_all_organization_units.name%TYPE;
      l_org_start_date fnd_flex_values_vl.start_date_active%TYPE;
      l_org_end_date   fnd_flex_values_vl.end_date_active%TYPE;
      l_co_vs_name     fnd_flex_value_sets.flex_value_set_name%TYPE;
      l_cc_vs_name     fnd_flex_value_sets.flex_value_set_name%TYPE;

      TYPE cur_type IS REF CURSOR;
      c_list cur_type;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      OPEN c_list FOR 'SELECT coa_id, co, co_vs_id, cc, cc_vs_id FROM '||g_temp_table_name;
      LOOP
         FETCH c_list INTO l_coa_id, l_co, l_co_vs_id, l_cc, l_cc_vs_id;
         EXIT WHEN c_list%NOTFOUND;

         l_retcode := derive_org_name( p_mode
                                     , l_co
                                     , l_co_vs_id
                                     , l_cc
                                     , l_cc_vs_id
                                     , l_co_desc
                                     , l_cc_desc
                                     , l_org_name
                                     , l_org_start_date
                                     , l_org_end_date  -- avoids overload, but not used in export.
                                     );

         -- Note: Phase 2a has added date_to (end date) population for the orgs created.
         -- Need to check if file format should also be changed to support export
         -- of this extra field's values. Not changed until notified of this requirement.


         -- Get company value set name
         IF l_retcode = 0 THEN
            l_retcode := get_vs_details( l_co_vs_id
                                       , l_co_vs_name
                                       );
         END IF; -- retcode check

         -- Get cost center value set name
         IF l_retcode = 0 THEN
            l_retcode := get_vs_details( l_cc_vs_id
                                       , l_cc_vs_name
                                       );
         END IF; -- retcode check

         IF l_retcode = 0 THEN
            EXECUTE IMMEDIATE 'UPDATE '||g_temp_table_name||
                              ' SET co_desc = :1'       ||
                                 ', cc_desc = :2'       ||
                                 ', co_vs_name = :3'    ||
                                 ', cc_vs_name = :4'    ||
                                 ', org_name = :5'      ||
                                 ', org_start_date = :6'||
                              ' WHERE co = :7'            ||
                              ' AND   co_vs_id = :8'      ||
                              ' AND   cc = :9'            ||
                              ' AND   cc_vs_id = :10'
                              USING l_co_desc
                                  , l_cc_desc
                                  , l_co_vs_name
                                  , l_cc_vs_name
                                  , l_org_name
                                  , l_org_start_date
                                  , l_co
                                  , l_co_vs_id
                                  , l_cc
                                  , l_cc_vs_id;
         ELSE
            l_retcode := 0;
         END IF; -- retcode check

      END LOOP; -- records in temp table
      CLOSE c_list;

      -- Close transaction
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 20);
         COMMIT;
      END IF;

      hr_utility.set_location('Leaving: '|| l_proc, 30);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 40);
         hr_utility.set_location(SQLERRM, 45);
         writelog(SQLERRM,'N');
         IF c_list%ISOPEN THEN
            CLOSE c_list;
         END IF;
         l_retcode := 2;
         RETURN l_retcode;

   END get_details_to_report;
   --
   -- Fix for bug 3837139 starts here.
   --
   -- ----------------------------------------------------------------------------
   -- |-----------------------< update_org_name_date >---------------------------|
   -- ----------------------------------------------------------------------------
   --
   function update_org_name_date(
            p_mode              in varchar2
           ,p_sync_org_name     in varchar2 default 'N'
           ,p_sync_org_dates    in varchar2 default 'N'
           ) return number is
     --
     -- Local variables
     l_rowid          rowid;
     l_sql_num        number(3);
     l_updrowcount    number := 0;
     l_retcode        number := 0;
     l_co_vs_id       number; -- Company value set id
     l_cc_vs_id       number; -- Cost Center value set id
     l_org_id         hr_all_organization_units.organization_id%type;
     l_org_name       hr_all_organization_units.name%type;
     l_name           hr_all_organization_units.name%type;
     l_start          hr_all_organization_units.date_from%type;
     l_end            hr_all_organization_units.date_to%type;
     l_cc_desc        fnd_flex_values_vl.description%type;
     l_co_desc        fnd_flex_values_vl.description%type;
     l_org_start_date fnd_flex_values_vl.start_date_active%type;
     l_org_end_date   fnd_flex_values_vl.end_date_active%type;
     l_co             varchar2(240); -- company value
     l_cc             varchar2(240); -- cost center value
     l_proc           varchar2(72) := g_package||'.update_org_name_date';
     --
     type  cur_type is ref cursor;
     c_ref cur_type;
     --
   begin
     --
     hr_utility.set_location('Entering: '|| l_proc, 10);
     --
     if p_sync_org_name = 'Y' or p_sync_org_dates = 'Y' then
       -- choose the org update SQL based on params
       if p_sync_org_name = 'Y' and p_sync_org_dates = 'Y' then l_sql_num := 1;
       elsif p_sync_org_name = 'Y' and p_sync_org_dates = 'N' then l_sql_num := 2;
       elsif p_sync_org_name = 'N' and p_sync_org_dates = 'Y' then l_sql_num := 3;
       end if;
       --
       hr_utility.set_location(l_proc, 20);
       -- PHASE 2a Conditionally update existing orgs' names, start_dates
       -- and end_dates to ensure they match the profile option name configuration
       -- and the latest values from their value sets descriptions and dates.
       -- Update will only be done if new and existing values differ.
       open c_ref for ' select units.rowid, units.name, units.organization_id, units.date_from, units.date_to, '||
                   ' t.co_vs_id, t.co, t.cc_vs_id, t.cc'||
                   ' from '|| g_temp_table_name ||' t , '||
                          ' hr_organization_information cc,'||
                          ' hr_organization_information class,'||
                          ' hr_all_organization_units units'||
                   ' where to_char(t.co_vs_id) =  cc.org_information2 '||
                   ' and   t.co = cc.org_information3 '||
                   ' and   to_char(t.cc_vs_id) = cc.org_information4 '||
                   ' and   t.cc = cc.org_information5 '||
                   ' and   units.organization_id = class.organization_id'||
                   ' and   class.org_information_context = ''CLASS'''||
                   ' and   class.org_information1 = ''CC'''||
                   ' and   class.organization_id = cc.organization_id'||
                   ' and   cc.org_information_context = ''Company Cost Center'''||
                   ' for   update of units.name nowait ';
       --
       loop
         --
         hr_utility.set_location(l_proc, 30);
         --
         fetch c_ref into l_rowid, l_name, l_org_id, l_start, l_end,
                       l_co_vs_id, l_co, l_cc_vs_id, l_cc;
         exit when c_ref%notfound;
         --
         l_org_name := null;
         l_retcode := derive_org_name(p_mode
                                  ,l_co
                                  ,l_co_vs_id
                                  ,l_cc
                                  ,l_cc_vs_id
                                  ,l_co_desc
                                  ,l_cc_desc
                                  ,l_org_name
                                  ,l_org_start_date
                                  ,l_org_end_date);
         --
         hr_utility.set_location(l_proc, 40);
         --
         if l_retcode = 0 then
           --
           if l_sql_num = 1 then
             --
             if l_org_name <> l_name or l_org_start_date <> l_start or
               nvl(l_org_end_date, hr_api.g_sot) <> nvl(l_end, hr_api.g_sot) then
               --
               hr_utility.set_location(l_proc, 50);
               --
               update hr_all_organization_units units
                  set units.name = l_org_name,
                      units.date_from = l_org_start_date,
                      units.date_to = l_org_end_date
                where units.rowid = l_rowid;
                --
               update hr_all_organization_units_tl
                  set name= l_org_name
                where organization_id = l_org_id
                  and language in (language, source_lang);
               --
               l_updrowcount := l_updrowcount + 1;
               --
             end if;
             --
           elsif l_sql_num = 2 then
             --
             if l_org_name <> l_name then
               --
               hr_utility.set_location(l_proc, 60);
               --
               update hr_all_organization_units units
                  set units.name = l_org_name
                where units.rowid = l_rowid;
               --
               update hr_all_organization_units_tl
                  set name=l_org_name
                where organization_id = l_org_id
                  and language in (language, source_lang);
               --
               l_updrowcount := l_updrowcount + 1;
               --
             end if;
             --
           elsif  l_sql_num = 3 then
             --
             if l_org_start_date <> l_start or
               nvl(l_org_end_date, hr_api.g_sot) <> nvl(l_end, hr_api.g_sot) then
               --
               hr_utility.set_location(l_proc, 70);
               --
               update hr_all_organization_units units
                  set units.date_from = l_org_start_date,
                      units.date_to = l_org_end_date
                where units.rowid = l_rowid;
               --
               l_updrowcount := l_updrowcount + 1;
               --
             end if;
             --
           end if;
           --
         end if;
         --
       end loop;
       --
       close c_ref;
       -- Commit the Org updates as this is atomic unit or work
       if l_updrowcount > 0 then
         --
         commit;
         writelog('Updated '||l_updrowcount||' organization details.','N');
         --
       end if;
       --
       hr_utility.set_location(l_proc, 80);
       --
     end if;
     --
     hr_utility.set_location('Leaving: '|| l_proc, 99);
     --
     return l_retcode;
     --
   exception
     --
     when others then
       --
       hr_utility.set_location('Leaving: '|| l_proc, 99);
       writelog(sqlerrm, 'N');
       rollback; -- explicitly release any lock taken by NOWAIT
       if c_ref%isopen then close c_ref; end if;
       l_retcode := 2;
     --
   end update_org_name_date;
   --
   -- ----------------------------------------------------------------------------
   -- |---------------------< get_co_cc_comb_into_temp >-------------------------|
   -- ----------------------------------------------------------------------------
   --
   function get_co_cc_comb_into_temp(
            p_business_group_id in number
           ,p_coa_id            in number
           ,p_co                in varchar2
           ,p_source            in varchar2
           ,p_rowcount          out nocopy number -- added for bug4346785.
           ) return number is
     --
     -- Local variables
     l_retcode     number := 0;
     l_rowcount    number := 0;
     l_delrowcount number := 0;
     l_co_vs_id    number; -- Company value set id
     l_cc_vs_id    number; -- Cost Center value set id
     l_co_seg      varchar2(240); -- Column name holding company segment value
     l_cc_seg      varchar2(240); -- Column name holding cost center segment value
     l_proc        varchar2(72) := g_package||'.get_co_cc_comb_into_temp';
     --
     -- Cursor to fetch the company codes within a business group
     -- and within the value set
     cursor c_companies(cp_co                in varchar2
                       ,cp_business_group_id in number
                       ,cp_co_vs_id          in number) is
            select distinct cc.org_information3 company_code
              from hr_all_organization_units units,
                   hr_organization_information class,
                   hr_organization_information cc
             where units.organization_id = class.organization_id
               and class.org_information_context = 'CLASS'
               and class.org_information1 = 'CC'
               and class.organization_id = cc.organization_id
               and cc.org_information_context = 'Company Cost Center'
               and cc.org_information2 is not null
               and cc.org_information3 is not null
               and cc.org_information3 = nvl(cp_co, cc.org_information3)
               and cc.org_information4 is null
               and cc.org_information5 is null
               and units.business_group_id = cp_business_group_id
               and cc.org_information3 in (
                   select flex_value
                     from fnd_flex_values_vl
                    where flex_value_set_id = cp_co_vs_id);
     --
     -- Cursor to fetch Cost Center Codes from the specified value set
     cursor c_cost_centers(cp_cc_vs_id in number) is
            select ffv.flex_value cost_center_code
              from fnd_flex_values_vl ffv
             where ffv.flex_value_set_id = cp_cc_vs_id
             order by ffv.flex_value;
     --
     -- Local exceptions
     e_no_records_to_process exception;
     --
   begin
     --
     hr_utility.set_location('Entering: '|| l_proc, 10);
     --
     -- Derive the Company value set and Cost Center value sets
     l_retcode := derive_value_sets(p_coa_id
                                   ,l_co_seg
                                   ,l_cc_seg
                                   ,l_co_vs_id
                                   ,l_cc_vs_id);
     writelog('Company Value Set Id: '||l_co_vs_id, 'Y');
     writelog('Cost Center Value Set Id: '||l_cc_vs_id, 'Y');
     --
     -- Get records to process into temp table
     if l_retcode = 0 then
       --
       hr_utility.set_location(l_proc, 20);
       --
       if p_source = 'CCVS' then
         -- Use company organizations within the business group and the
         -- cost center value set to build the company cost center
         -- combinations to process.
         hr_utility.set_location(l_proc, 30);
         -- Loop for company codes within the business group
         for cr_company in c_companies(p_co, p_business_group_id, l_co_vs_id) loop
           --
           hr_utility.set_message(800, 'PER_50159_COMP_CODE');
           fnd_message.set_token('COMP_CODE', cr_company.company_code);
           writelog(fnd_message.get(), 'Y');
           --
           for cr_cost_center in c_cost_centers(l_cc_vs_id) loop
             --
             hr_utility.set_message(800,'PER_50160_COST_CENTER_CODE');
             fnd_message.set_token('COST_CENTER_CODE',cr_cost_center.cost_center_code);
             writelog(fnd_message.get(),'Y');
             -- Insert record into temp table
             execute immediate 'insert into '||g_temp_table_name||
                               ' ( coa_id'||
                               ' , co'||
                               ' , co_vs_id'||
                               ' , cc'||
                               ' , cc_vs_id'||
                               ' ) values'||
                               ' ( :1, :2, :3, :4, :5 )'
                               using p_coa_id
                                    ,cr_company.company_code
                                    ,l_co_vs_id
                                    ,cr_cost_center.cost_center_code
                                    ,l_cc_vs_id;
             l_rowcount := l_rowcount + 1;
             --
           end loop; -- Cost Centers
           --
         end loop; -- Companies
         --
         if l_rowcount = 0 then
           raise e_no_records_to_process;
         else
           writelog('Inserted '||l_rowcount||' Company-CostCenter records into temp','Y');
         end if;
         --
       else -- p_source is GLCC
         -- Get the company cost center combinations to process from table
         -- GL_CODE_COMBIANTIONS.
         hr_utility.set_location(l_proc, 40);
         --
         execute immediate 'insert into '||g_temp_table_name||
                           ' ( coa_id'||
                           ' , co'||
                           ' , co_vs_id'||
                           ' , cc'||
                           ' , cc_vs_id )'||
                           ' select distinct'||
                           '  '||p_coa_id||
                           ', '||l_co_seg||
                           ', '||l_co_vs_id||
                           ', '||l_cc_seg||
                           ', '||l_cc_vs_id||
                           ' from  gl_code_combinations'||
                           ' where summary_flag = ''N'''||
                           ' and   chart_of_accounts_id = :1'||
                           ' and   '||l_co_seg||' = nvl(:2,'||l_co_seg||')'
                           using p_coa_id, p_co;
         --
         l_rowcount := sql%rowcount;
         if l_rowcount = 0 then
           raise e_no_records_to_process;
         else
           writelog('Inserted '||l_rowcount||' Company-CostCenter records from GLCC into temp','Y');
         end if;
         -- Delete combinations where company code does not exist as a company organization.
         hr_utility.set_location(l_proc, 50);
         --
         execute immediate 'delete from '||g_temp_table_name||
                           ' where (co,to_char(co_vs_id)) not in ('||
                           ' select distinct cc.org_information3, cc.org_information2'||
                           ' from hr_all_organization_units units,'||
                           ' hr_organization_information class,'||
                           ' hr_organization_information cc'||
                           ' where units.organization_id = class.organization_id'||
                           ' and   class.org_information_context = ''CLASS'''||
                           ' and   class.org_information1 = ''CC'''||
                           ' and   class.organization_id = cc.organization_id'||
                           ' and   cc.org_information_context = ''Company Cost Center'''||
                           ' and   units.business_group_id = :1 '||
                           ' and   cc.org_information4 is null'||
                           ' and   cc.org_information5 is null )'
                           using p_business_group_id;

         --
         l_delrowcount := sql%rowcount;
         writelog('Deleted '||l_delrowcount||' missing Company-ORG records from temp','Y');
         if l_rowcount = l_delrowcount then
           raise e_no_records_to_process;
         end if;
         --
       end if; -- p_source is CCVS
       --
     end if; -- rectcode is 0
     --
     p_rowcount := l_rowcount; -- Added for bug 4346785.
     --
     -- Create a performance index
     if l_retcode = 0 then
       --
       hr_utility.set_location(l_proc, 60);
       --
       execute immediate 'create index '||g_temp_table_name||'_n1 on '||
                          g_temp_table_name||'(co,co_vs_id,cc,cc_vs_id)';

       -- Note that the above DDL will implicitly commit the previously executed DML
     end if; -- rectcode is 0
     --
     hr_utility.set_location('Leaving: '|| l_proc, 99);
     --
     return l_retcode;
     --
   exception
     --
     when e_no_records_to_process then
       --
       hr_utility.set_location('Leaving: '|| l_proc, 999);
       hr_utility.set_message(800, 'PER_50154_NO_CO_CC_COMBS');
       writelog(fnd_message.get(), 'N');
       l_retcode := 1;
       return l_retcode;
       --
     when others then
       --
       hr_utility.set_location('Leaving: '|| l_proc, 999);
       writelog(sqlerrm,'N');
       l_retcode := 2;
       return l_retcode;
     --
   end get_co_cc_comb_into_temp;
   --
   -- ----------------------------------------------------------------------------
   -- |--------------------< delete_sync_orgs_from_temp >------------------------|
   -- ----------------------------------------------------------------------------
   --
   function delete_sync_orgs_from_temp(
     p_mode              in varchar2
    ,p_business_group_id in number
    ,p_coa_id            in number
    ,p_rowcount          in number -- Added for bug4346785.
    ) return number is
     --
     -- Local variables
     --
     l_retcode     number := 0;
     l_co_seg       varchar2(240); -- Column name holding company segment value
     l_cc_seg       varchar2(240); -- Column name holding cost center segment value
     l_co_vs_id     number; -- Company value set id
     l_cc_vs_id     number; -- Cost Center value set id
     l_rowcount     number;
     l_delrowcount  number := 0;
     l_del1rowcount number := 0;
     l_proc         varchar2(50) := g_package||'.delete_sync_orgs_from_temp';
     --
     -- Local exceptions
     --
     e_no_records_to_process EXCEPTION;
     --
   BEGIN
     hr_utility.set_location('Entering:'||l_proc, 10);
     --
     l_rowcount := p_rowcount; -- Added for bug4346785.
     --
     -- Derive the Company value set and Cost Center value sets
     --
     IF l_retcode = 0 THEN
        --
        hr_utility.set_location(l_proc, 30);
        l_retcode := derive_value_sets( p_coa_id
                                      , l_co_seg
                                      , l_cc_seg
                                      , l_co_vs_id
                                      , l_cc_vs_id
                                       );
         writelog('Company Value Set Id: '||l_co_vs_id,'Y');
         writelog('Cost Center Value Set Id: '||l_cc_vs_id,'Y');
         --
     END IF; -- retcode is 0
     --
     -- Now updates of corresponding orgs have been done,
     -- perform relevant delete ops to discard existing / synchroniized rows
     -- from g_temp_table_name
     --
     hr_utility.set_location(l_proc, 40);
     --
     IF l_retcode = 0 AND p_mode = 'CREATE_MAINTAIN' THEN
       --
       --
       hr_utility.set_location(l_proc, 60);
       --
       -- Note that l_co_seg and l_cc_seg hold the names of the columns
       -- which contain the company code value and cost center code value.
       --
       EXECUTE IMMEDIATE 'DELETE FROM '||g_temp_table_name||
                    ' WHERE (co,cc) IN ('||
                    ' SELECT DISTINCT '||l_co_seg||','||l_cc_seg||' FROM gl_code_combinations'||
                    ' WHERE chart_of_accounts_id = :1 AND company_cost_center_org_id IS NOT NULL)'
                    USING p_coa_id;
       --
       l_delrowcount := SQL%ROWCOUNT;
       writelog('Deleted '||l_delrowcount||' already synchronized records from temp table','Y');
       IF l_rowcount = l_delrowcount THEN
          hr_utility.set_location(l_proc, 70);
          RAISE e_no_records_to_process;
       END IF;
       --
       hr_utility.set_location(l_proc, 80);
       --
       -- Delete records from temp table where Company-CostCenter Orgs already exist
       -- in the system. These may not be already synchronized. This needs to be done
       -- only in CREATE_MAINTAIN mode but not in EXPORT mode. This routine does not
       -- get called for the SINGLE_ORG and SYNCHRONIZE modes.
       --
       EXECUTE IMMEDIATE 'DELETE FROM '||g_temp_table_name||
                     ' WHERE (TO_CHAR(co_vs_id), co'||
                     ', TO_CHAR(cc_vs_id), cc) IN ('||
                     ' SELECT CC.org_information2, CC.org_information3,'||
                     ' CC.org_information4, CC.org_information5'||
                     ' FROM hr_all_organization_units UNITS,'||
                     ' hr_organization_information CLASS,'||
                     ' hr_organization_information CC'||
                     ' WHERE UNITS.organization_id = CLASS.organization_id'||
                     ' AND   CLASS.org_information_context = ''CLASS'''||
                     ' AND   CLASS.org_information1 = ''CC'''||
                     ' AND   CLASS.organization_id = CC.organization_id'||
                     ' AND   CC.org_information_context = ''Company Cost Center'''||
                     ' AND   UNITS.business_group_id = :1 )'
                     USING p_business_group_id;
       --
       l_del1rowcount := SQL%ROWCOUNT;
       writelog('Deleted '||l_del1rowcount||' ORG already existing records from temp table','Y');
       IF l_rowcount = (l_delrowcount + l_del1rowcount) THEN
          hr_utility.set_location(l_proc, 90);
          RAISE e_no_records_to_process;
       END IF;
       --
     END IF; -- retcode is 0 and mode is CREATE_MAINTAIN
     --
     -- Close transaction as this is an integral unit of work
     --
     hr_utility.set_location(l_proc, 100);
     IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 110);
         COMMIT;
     END IF; -- retcode is 0
     --
     hr_utility.set_location('Leaving: '||l_proc, 120);
     --
     RETURN l_retcode;
     --
   EXCEPTION
     WHEN e_no_records_to_process THEN
        hr_utility.set_location('Leaving: '|| l_proc, 130);
        hr_utility.set_message(800,'PER_50154_NO_CO_CC_COMBS');
        writelog(fnd_message.get(),'N');
        l_retcode := 1;
        RETURN l_retcode;
     WHEN OTHERS THEN
        hr_utility.set_location('Leaving: '|| l_proc, 140);
        hr_utility.set_location(SQLERRM, 135);
        writelog(SQLERRM,'N');
        l_retcode := 2;
        RETURN l_retcode;
   END delete_sync_orgs_from_temp;
   --
   -- Fix for bug 3837139 ends here.
   --
   --
   -- Populate Co-CC combinations to process into temporary table
   --
   -- Derive company and cost center value sets for the chart of accounts.
   -- If source is CCVS
   --    Loop for company codes within the business group.
   --       Loop for cost center codes within the cost center value set.
   --          Insert Company Cost Center combinations into temp table.
   -- Else source is GLCC
   --    Fetch distinct Company Cost Center combinations from table
   --    GL_CODE_COMBINATIONS into temp table.
   -- Create a performance index on the temp table.
   -- Delete from temp table where CoCC combinations have been synchronized
   -- in GL_CODE_COMBINATIONS.
   -- Update existing CoCC orgs depending upon control params.
   -- Delete from temp table where CoCC Orgs already exist in the system.
   -- Close the transaction as this completes a unit of work.
   --
   FUNCTION get_co_cc_combinations( p_mode              IN VARCHAR2
                                  , p_business_group_id IN NUMBER
                                  , p_coa_id            IN NUMBER
                                  , p_co                IN VARCHAR2
                                  , p_source            IN VARCHAR2
                                  , p_sync_org_name     IN VARCHAR2 DEFAULT 'N'
                                  , p_sync_org_dates    IN VARCHAR2 DEFAULT 'N'
                                  ) RETURN NUMBER IS

      -- Local variables
      l_proc         VARCHAR2(50) := g_package||'.get_co_cc_combinations';
      l_retcode      NUMBER := 0;
      l_rowcount     NUMBER := 0;
      l_delrowcount  NUMBER := 0;
      l_updrowcount  NUMBER := 0;
      l_del1rowcount NUMBER := 0;
      l_co_seg       VARCHAR2(240); -- Column name holding company segment value
      l_cc_seg       VARCHAR2(240); -- Column name holding cost center segment value
      l_co_vs_id     NUMBER; -- Company value set id
      l_cc_vs_id     NUMBER; -- Cost Center value set id

      l_rowid          ROWID;
      l_sql_num        NUMBER(3);
      l_org_name       hr_all_organization_units.name%TYPE;
      l_name           hr_all_organization_units.name%TYPE;
      l_start          hr_all_organization_units.date_from%TYPE;
      l_end            hr_all_organization_units.date_to%TYPE;
      l_cc             VARCHAR2(240); -- Cost Center value
      l_cc_desc        fnd_flex_values_vl.description%TYPE;
      l_co             VARCHAR2(240); -- Company value
      l_co_desc        fnd_flex_values_vl.description%TYPE;
      l_co_vs_name     fnd_flex_value_sets.flex_value_set_name%TYPE;
      l_cc_vs_name     fnd_flex_value_sets.flex_value_set_name%TYPE;
      l_org_start_date fnd_flex_values_vl.start_date_active%TYPE;
      l_org_end_date   fnd_flex_values_vl.end_date_active%TYPE;
      l_delete_synced_orgs_flag BOOLEAN := FALSE;

      TYPE cur_type IS REF CURSOR;
      c_ref cur_type;


      -- Cursor to fetch the company codes within a business group
      -- and within the value set
      CURSOR c_companies ( cp_co                IN VARCHAR2
                         , cp_business_group_id IN NUMBER
                         , cp_co_vs_id          IN NUMBER
                         ) IS
         SELECT DISTINCT CC.org_information3 company_code
         FROM   hr_all_organization_units   UNITS
               ,hr_organization_information CLASS
               ,hr_organization_information CC
         WHERE UNITS.organization_id = CLASS.organization_id
         AND   CLASS.org_information_context = 'CLASS'
         AND   CLASS.org_information1 = 'CC'
         AND   CLASS.organization_id = CC.organization_id
         AND   CC.org_information_context = 'Company Cost Center'
         AND   CC.org_information2 IS NOT NULL
         AND   CC.org_information3 IS NOT NULL
         AND   CC.org_information3 = NVL(cp_co, CC.org_information3)
         AND   CC.org_information4 IS NULL
         AND   CC.org_information5 IS NULL
         AND   UNITS.business_group_id = cp_business_group_id
         AND   CC.org_information3 IN ( SELECT flex_value
                                        FROM   fnd_flex_values_vl
                                        WHERE  flex_value_set_id = cp_co_vs_id
                                      );

      -- Cursor to fetch Cost Center Codes from the specified value set
      CURSOR c_cost_centers(cp_cc_vs_id IN NUMBER) IS
         SELECT FFV.flex_value cost_center_code
         FROM   fnd_flex_values_vl FFV
         WHERE  FFV.flex_value_set_id = cp_cc_vs_id
         ORDER BY FFV.flex_value;

      -- Local exceptions
      e_no_records_to_process EXCEPTION;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Derive the Company value set and Cost Center value sets
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 20);
         l_retcode := derive_value_sets( p_coa_id
                                       , l_co_seg
                                       , l_cc_seg
                                       , l_co_vs_id
                                       , l_cc_vs_id
                                       );
         writelog('Company Value Set Id: '||l_co_vs_id,'Y');
         writelog('Cost Center Value Set Id: '||l_cc_vs_id,'Y');
      END IF; -- retcode is 0

      -- Get records to process into temp table
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 30);

         IF p_source = 'CCVS' THEN
            -- Use company organizations within the business group and the
            -- cost center value set to build the company cost center
            -- combinations to process.
            hr_utility.set_location(l_proc, 40);

            -- Loop for company codes within the business group
            FOR cr_company IN c_companies(p_co, p_business_group_id, l_co_vs_id) LOOP
               hr_utility.set_message(800,'PER_50159_COMP_CODE');
               fnd_message.set_token('COMP_CODE',cr_company.company_code);
               writelog(fnd_message.get(),'Y');

               FOR cr_cost_center IN c_cost_centers(l_cc_vs_id) LOOP
                  hr_utility.set_message(800,'PER_50160_COST_CENTER_CODE');
                  fnd_message.set_token('COST_CENTER_CODE',cr_cost_center.cost_center_code);
                  writelog(fnd_message.get(),'Y');

                  -- Insert record into temp table
                  EXECUTE IMMEDIATE 'INSERT INTO '||g_temp_table_name||
                                    ' ( coa_id'||
                                    ' , co'||
                                    ' , co_vs_id'||
                                    ' , cc'||
                                    ' , cc_vs_id'||
                                    ' ) VALUES'||
                                    ' ( :1, :2, :3, :4, :5 )'
                                    USING p_coa_id
                                        , cr_company.company_code
                                        , l_co_vs_id
                                        , cr_cost_center.cost_center_code
                                        , l_cc_vs_id;
                  l_rowcount := l_rowcount + 1;
               END LOOP; -- Cost Centers
            END LOOP; -- Companies

            IF l_rowcount = 0 THEN
               RAISE e_no_records_to_process;
            ELSE
               writelog('Inserted '||l_rowcount||' Company-CostCenter records into temp','Y');
            END IF;

            -- Trigger subsequent delete of records from temp table where records
            -- in GL_CODE_COMBINATIONS are already synchronized with HR Orgs
            -- i.e. COMPANY_COST_CENTER_ORG_ID is not null.
            -- Phase 2a - Note that this code is moved below, after the update of existing orgs,
            -- as the corresponding orgs for these rows may still need to be updated.
            --
            l_delete_synced_orgs_flag := true;

         ELSE -- p_source is GLCC
            -- Get the company cost center combinations to process from table
            -- GL_CODE_COMBIANTIONS.
            hr_utility.set_location(l_proc, 60);

            EXECUTE IMMEDIATE 'INSERT INTO '||g_temp_table_name||
                              ' ( coa_id'||
                              ' , co'||
                              ' , co_vs_id'||
                              ' , cc'||
                              ' , cc_vs_id )'||
                              ' SELECT DISTINCT'||
                                    '  '||p_coa_id||
                                    ', '||l_co_seg||
                                    ', '||l_co_vs_id||
                                    ', '||l_cc_seg||
                                    ', '||l_cc_vs_id||
                              ' FROM gl_code_combinations'||
                              ' WHERE company_cost_center_org_id IS NULL'||
                              ' AND summary_flag = ''N'''||
                              ' AND chart_of_accounts_id = :1'||
                              ' AND '||l_co_seg||' = NVL(:2,'||l_co_seg||')'
                              USING p_coa_id, p_co;

            l_rowcount := SQL%ROWCOUNT;
            IF l_rowcount = 0 THEN
               RAISE e_no_records_to_process;
            ELSE
               writelog('Inserted '||l_rowcount||' Company-CostCenter records from GLCC into temp','Y');
            END IF;

            -- Delete combinations where company code does not exist as a company organization.
            hr_utility.set_location(l_proc, 70);

            EXECUTE IMMEDIATE 'DELETE FROM '||g_temp_table_name||
                              ' WHERE (co,TO_CHAR(co_vs_id)) NOT IN ('||
                              ' SELECT DISTINCT CC.org_information3, CC.org_information2'||
                              ' FROM hr_all_organization_units UNITS,'||
                              ' hr_organization_information CLASS,'||
                              ' hr_organization_information CC'||
                              ' WHERE UNITS.organization_id = CLASS.organization_id'||
                              ' AND   CLASS.org_information_context = ''CLASS'''||
                              ' AND   CLASS.org_information1 = ''CC'''||
                              ' AND   CLASS.organization_id = CC.organization_id'||
                              ' AND   CC.org_information_context = ''Company Cost Center'''||
                              ' AND   UNITS.business_group_id = :1 '||
                              ' AND   CC.org_information4 IS NULL'||
                              ' AND   CC.org_information5 IS NULL )'
                              USING p_business_group_id;

            l_delrowcount := SQL%ROWCOUNT;
            writelog('Deleted '||l_delrowcount||' missing Company-ORG records from temp','Y');
            IF l_rowcount = l_delrowcount THEN
               RAISE e_no_records_to_process;
            END IF;

         END IF; -- p_source is CCVS

      END IF; -- rectcode is 0

      -- Create a performance index
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 80);

         EXECUTE IMMEDIATE 'CREATE INDEX '||g_temp_table_name||'_n1 ON '||
                           g_temp_table_name||'(co,co_vs_id,cc,cc_vs_id)';

         -- Note that the above DDL will implicitly commit the previously executed DML
      END IF; -- rectcode is 0


      -- Phase 2a: Do maintenance of corresponding orgs first running in CREATE_MAINTAIN mode,
      -- and then delete rows in temp table.

      IF l_retcode = 0 AND p_mode = 'CREATE_MAINTAIN' THEN
        hr_utility.set_location(l_proc, 90);

        IF p_sync_org_name = 'Y' OR p_sync_org_dates = 'Y' THEN

          -- choose the org update SQL based on params
          IF p_sync_org_name = 'Y' AND p_sync_org_dates = 'Y' THEN l_sql_num := 1;
          ELSIF p_sync_org_name = 'Y' AND p_sync_org_dates = 'N' THEN l_sql_num := 2;
          ELSIF p_sync_org_name = 'N' AND p_sync_org_dates = 'Y' THEN l_sql_num := 3;
          END IF;

          BEGIN

            -- PHASE 2a Conditionally update existing orgs' names, start_dates
            -- and end_dates to ensure they match the profile option name configuration
            -- and the latest values from their value sets descriptions and dates.
            -- Update will only be done if new and existing values differ.
            OPEN c_ref FOR ' SELECT UNITS.ROWID, UNITS.name, UNITS.date_from, UNITS.date_to, '||
                           ' t.CO_VS_ID, t.CO, t.CC_VS_ID, t.CC'||
                        ' FROM '|| g_temp_table_name ||' t , '||
                               ' hr_organization_information CC,'||
                               ' hr_organization_information CLASS,'||
                               ' hr_all_organization_units UNITS'||
                        ' WHERE TO_CHAR(t.co_vs_id) =  CC.org_information2 '||
                        ' AND t.co = CC.org_information3 '||
                        ' AND TO_CHAR(t.cc_vs_id) = CC.org_information4 '||
                        ' AND t.cc = CC.org_information5 '||
                        ' AND UNITS.organization_id = CLASS.organization_id'||
                        ' AND CLASS.org_information_context = ''CLASS'''||
                        ' AND CLASS.org_information1 = ''CC'''||
                        ' AND CLASS.organization_id = CC.organization_id'||
                        ' AND CC.org_information_context = ''Company Cost Center'''||
                        ' FOR UPDATE OF UNITS.name NOWAIT ';

            LOOP
              FETCH c_ref INTO l_rowid, l_name, l_start, l_end, l_co_vs_id, l_co, l_cc_vs_id, l_cc;
              EXIT WHEN c_ref%NOTFOUND;

              l_org_name := null;
              l_retcode := derive_org_name( p_mode
                                          , l_co
                                          , l_co_vs_id
                                          , l_cc
                                          , l_cc_vs_id
                                          , l_co_desc
                                          , l_cc_desc
                                          , l_org_name
                                          , l_org_start_date
                                          , l_org_end_date
                                         );

              IF l_retcode = 0 THEN
                IF l_sql_num = 1 THEN
                  IF l_org_name <> l_name OR l_org_start_date <> l_start OR
                     nvl(l_org_end_date,hr_api.g_sot) <> nvl(l_end,hr_api.g_sot) THEN

                      UPDATE hr_all_organization_units UNITS
                        SET UNITS.name = l_org_name,
                            UNITS.date_from = l_org_start_date,
                            UNITS.date_to = l_org_end_date
                        WHERE UNITS.rowid = l_rowid;

                      l_updrowcount := l_updrowcount+1;
                  END IF;
                ELSIF  l_sql_num = 2 THEN
                  IF l_org_name <> l_name THEN

                    UPDATE hr_all_organization_units UNITS
                      SET UNITS.name = l_org_name
                      WHERE UNITS.rowid = l_rowid;

                    l_updrowcount := l_updrowcount+1;
                  END IF;
                ELSIF  l_sql_num = 3 THEN
                  IF  l_org_start_date <> l_start OR
                      nvl(l_org_end_date,hr_api.g_sot) <> nvl(l_end,hr_api.g_sot) THEN

                    UPDATE hr_all_organization_units UNITS
                      SET UNITS.date_from = l_org_start_date,
                          UNITS.date_to = l_org_end_date
                      WHERE UNITS.rowid = l_rowid;

                    l_updrowcount := l_updrowcount+1;
                  END IF;
                END IF;

              END IF;

            END LOOP;
            CLOSE c_ref;

            -- Commit the Org updates as this is atomic unit or work
            IF l_updrowcount > 0 THEN
              COMMIT;
              writelog('Updated '||l_updrowcount||' organization details.','N');
            ELSE
              writelog('No organization details were updated.','N');
              ROLLBACK; -- just in case
            END IF;

          EXCEPTION
            WHEN OTHERS THEN
             hr_utility.set_location('Leaving: '|| l_proc, 93);
             hr_utility.set_location(SQLERRM, 93);
             writelog(SQLERRM,'N');
             ROLLBACK;             -- explicitly release any lock taken by NOWAIT
             IF c_ref%ISOPEN THEN
              CLOSE c_ref;
             END IF;
             l_retcode := 2;
          END;

        END IF; -- Phase 2a update org name and dates


        hr_utility.set_location(l_proc, 95);

        -- Now updates of corresponding orgs have been done,
        -- perform relevant delete ops to discard existing / synchroniized rows
        -- from g_temp_table_name

        IF l_retcode = 0  and l_delete_synced_orgs_flag THEN
               hr_utility.set_location(l_proc, 50);

               -- Note that l_co_seg and l_cc_seg hold the names of the columns
               -- which contain the company code value and cost center code value.
          EXECUTE IMMEDIATE 'DELETE FROM '||g_temp_table_name||
                           ' WHERE (co,cc) IN ('||
                           ' SELECT DISTINCT '||l_co_seg||','||l_cc_seg||' FROM gl_code_combinations'||
                           ' WHERE chart_of_accounts_id = :1 AND company_cost_center_org_id IS NOT NULL)'
                            USING p_coa_id;

          l_delrowcount := SQL%ROWCOUNT;
          writelog('Deleted '||l_delrowcount||' already synchronized records from temp table','Y');
          IF l_rowcount = l_delrowcount THEN
             RAISE e_no_records_to_process;
          END IF;
        END IF; -- retcode is 0

        hr_utility.set_location(l_proc, 100);

      -- Delete records from temp table where Company-CostCenter Orgs already exist
      -- in the system. These may not be already synchronized. This needs to be done
      -- only in CREATE_MAINTAIN mode but not in EXPORT mode. This routine does not
      -- get called for the SINGLE_ORG and SYNCHRONIZE modes.

         EXECUTE IMMEDIATE 'DELETE FROM '||g_temp_table_name||
                           ' WHERE (TO_CHAR(co_vs_id), co'||
                           ', TO_CHAR(cc_vs_id), cc) IN ('||
                           ' SELECT CC.org_information2, CC.org_information3,'||
                           ' CC.org_information4, CC.org_information5'||
                           ' FROM hr_all_organization_units UNITS,'||
                           ' hr_organization_information CLASS,'||
                           ' hr_organization_information CC'||
                           ' WHERE UNITS.organization_id = CLASS.organization_id'||
                           ' AND   CLASS.org_information_context = ''CLASS'''||
                           ' AND   CLASS.org_information1 = ''CC'''||
                           ' AND   CLASS.organization_id = CC.organization_id'||
                           ' AND   CC.org_information_context = ''Company Cost Center'''||
                           ' AND   UNITS.business_group_id = :1 )'
                           USING p_business_group_id;

        l_del1rowcount := SQL%ROWCOUNT;
        writelog('Deleted '||l_del1rowcount||' ORG already existing records from temp table','Y');
        IF l_rowcount = (l_delrowcount + l_del1rowcount) THEN
           RAISE e_no_records_to_process;
        END IF;
      END IF; -- retcode is 0 and mode is CREATE_MAINTAIN

      -- Close transaction as this is an integral unit of work
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 105);

         COMMIT;
      END IF; -- retcode is 0

      hr_utility.set_location('Leaving: '|| l_proc, 110);

      RETURN l_retcode;

   EXCEPTION

      WHEN e_no_records_to_process THEN
         hr_utility.set_location('Leaving: '|| l_proc, 120);
         hr_utility.set_message(800,'PER_50154_NO_CO_CC_COMBS');
         writelog(fnd_message.get(),'N');
         l_retcode := 1;
         RETURN l_retcode;

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 130);
         hr_utility.set_location(SQLERRM, 135);
         writelog(SQLERRM,'N');
         l_retcode := 2;
         RETURN l_retcode;

   END get_co_cc_combinations;

   --
   -- Populate Co-CC combinations to synchronize into temporary table
   --
   -- Derive company and cost center value sets for the chart of accounts.
   -- Get GL_CODE_COMBINATIONS records that have not yet been synchronized
   -- into temp table.
   -- Create an index on temp table.
   -- Delete those combinations for which a company org cannot be found.
   -- Close the transaction as this completes a unit of work.
   --
   FUNCTION get_gl_co_cc_to_sync( p_business_group_id    IN            NUMBER
                                , p_coa_id               IN            NUMBER
                                , p_co                   IN            VARCHAR2
                                , p_duplicate_orgs_found IN OUT NOCOPY BOOLEAN
                                ) RETURN NUMBER IS

      -- Local variables
      l_proc         VARCHAR2(50) := g_package||'.get_gl_co_cc_to_sync';
      l_retcode      NUMBER := 0;
      l_rowcount     NUMBER := 0;
      l_delrowcount  NUMBER := 0;
      l_del1rowcount NUMBER := 0;
      l_co_seg       VARCHAR2(240); -- Col name of seg holding company value
      l_cc_seg       VARCHAR2(240); -- Col name of seg holding cost center value
      l_co_vs_id     NUMBER(15); -- Id of company value set
      l_cc_vs_id     NUMBER(15); -- Id of cost center value set

      -- Local exceptions
      e_no_records_to_process EXCEPTION;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);
      p_duplicate_orgs_found := FALSE;

      -- Derive the Company value set and Cost Center value sets
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 20);

         l_retcode := derive_value_sets( p_coa_id
                                       , l_co_seg
                                       , l_cc_seg
                                       , l_co_vs_id
                                       , l_cc_vs_id
                                       );

         writelog('Company Value Set Id: '||l_co_vs_id,'Y');
         writelog('Cost Center Value Set Id: '||l_cc_vs_id,'Y');
      END IF; -- retcode is 0

      -- Get records from GL_CODE_COMBINATIONS for the given COA_ID and the
      -- account code combination is not for a summary account and  the
      -- company cost center org id is null, i.e. the CCID has not already
      -- been synchronized to an ORG.
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 30);

         EXECUTE IMMEDIATE 'INSERT INTO '||g_temp_table_name||
                           ' ( coa_id'||
                           ' , co'||
                           ' , co_vs_id'||
                           ' , cc'||
                           ' , cc_vs_id'||
                           ' , ccid'||
                           ' , org_id )'||
                           ' SELECT chart_of_accounts_id'||
                                 ', '||l_co_seg||
                                 ', '||l_co_vs_id||
                                 ', '||l_cc_seg||
                                 ', '||l_cc_vs_id||
                                 ', code_combination_id'||
                                 ', NULL'||
                           ' FROM gl_code_combinations'||
                           ' WHERE company_cost_center_org_id IS NULL'||
                           ' AND summary_flag = ''N'''||
                           ' AND chart_of_accounts_id = :1'
                           USING p_coa_id;

         l_rowcount := SQL%ROWCOUNT;
         IF l_rowcount = 0 THEN
            RAISE e_no_records_to_process;
         END IF;

         writelog('Inserted '||l_rowcount||' records to synchronize into temp table','Y');

      END IF; -- retcode is 0

      -- Create a performance index
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 40);

         EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX '||g_temp_table_name||'_u1 ON '||
                           g_temp_table_name||'(ccid)';

         -- Note that the above index creation will implicitly commit the transaction
         -- for populating records into the temp table.
      END IF; -- retcode is 0

      -- Delete those combinations for which a company cost center organization
      -- cannot be found.
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 50);

         EXECUTE IMMEDIATE 'DELETE FROM '||g_temp_table_name||
                           ' WHERE (TO_CHAR(co_vs_id), co'||
                           ', TO_CHAR(cc_vs_id), cc) NOT IN'||
                           ' (SELECT DISTINCT CC.org_information2'||
                                           ', CC.org_information3'||
                                           ', CC.org_information4'||
                                           ', CC.org_information5'||
                            ' FROM hr_all_organization_units UNITS'||
                                ', hr_organization_information CLASS'||
                                ', hr_organization_information CC'||
                            ' WHERE UNITS.organization_id = CLASS.organization_id'||
                            ' AND CLASS.org_information_context = ''CLASS'''||
                            ' AND CLASS.org_information1 = ''CC'''||
                            ' AND CLASS.organization_id = CC.organization_id'||
                            ' AND CC.org_information_context = ''Company Cost Center'''||
                            ' AND CC.org_information2 IS NOT NULL'||
                            ' AND CC.org_information3 IS NOT NULL'||
                            ' AND CC.org_information4 IS NOT NULL'||
                            ' AND CC.org_information5 IS NOT NULL'||
                            ' AND UNITS.business_group_id = :1)'
                            USING p_business_group_id;

         l_delrowcount := SQL%ROWCOUNT;
         writelog('Deleted '||l_delrowcount||' missing Company Cost Center ORG records from temp table','Y');
         IF l_delrowcount = l_rowcount THEN
            RAISE e_no_records_to_process;
         END IF;
      END IF; -- retcode is 0

      -- Delete combinations where duplicate matching Company Cost Center ORGs
      -- exist as these are invalid scenarios and cannot be automatically
      -- synchronized.
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 60);

         EXECUTE IMMEDIATE 'DELETE FROM '||g_temp_table_name||
                           ' WHERE (TO_CHAR(co_vs_id), co'||
                           ', TO_CHAR(cc_vs_id), cc) IN'||
                           ' (SELECT CC.org_information2'||
                                  ', CC.org_information3'||
                                  ', CC.org_information4'||
                                  ', CC.org_information5'||
                            ' FROM hr_all_organization_units UNITS'||
                                ', hr_organization_information CLASS'||
                                ', hr_organization_information CC'||
                            ' WHERE UNITS.organization_id = CLASS.organization_id'||
                            ' AND CLASS.org_information_context = ''CLASS'''||
                            ' AND CLASS.org_information1 = ''CC'''||
                            ' AND CLASS.organization_id = CC.organization_id'||
                            ' AND CC.org_information_context = ''Company Cost Center'''||
                            ' AND CC.org_information2 IS NOT NULL'||
                            ' AND CC.org_information3 IS NOT NULL'||
                            ' AND CC.org_information4 IS NOT NULL'||
                            ' AND CC.org_information5 IS NOT NULL'||
                            ' AND UNITS.business_group_id = :1'||
                            ' GROUP BY CC.org_information2'||
                                    ', CC.org_information3'||
                                    ', CC.org_information4'||
                                    ', CC.org_information5'||
                            ' HAVING COUNT(*) > 1)'
                            USING p_business_group_id;

         l_del1rowcount := SQL%ROWCOUNT;
         writelog('Deleted '||l_del1rowcount||' duplicate ORG records from temp table','Y');
         IF l_del1rowcount > 0 THEN
            p_duplicate_orgs_found := TRUE;
         END IF;
         IF (l_delrowcount + l_del1rowcount) = l_rowcount THEN
            RAISE e_no_records_to_process;
         END IF;
      END IF; -- retcode is 0

      -- Close transaction as this is an integral unit of work
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 70);

         COMMIT;
      END IF; -- retcode is 0

      hr_utility.set_location('Leaving: '|| l_proc, 80);

      RETURN l_retcode;

   EXCEPTION

      WHEN e_no_records_to_process THEN
         hr_utility.set_location('Leaving: '|| l_proc, 90);
         hr_utility.set_message(800,'PER_50154_NO_CO_CC_COMBS');
         writelog(fnd_message.get(),'N');
         l_retcode := 1;
         RETURN l_retcode;

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 100);
         hr_utility.set_location(SQLERRM, 105);
         writelog(SQLERRM,'N');
         l_retcode := 2;
         RETURN l_retcode;

   END get_gl_co_cc_to_sync;

   --
   -- Write header file
   --
   FUNCTION write_hdr_file( p_hdr_file_handle IN utl_file.file_type
                          , p_bg_name         IN VARCHAR2
                          , p_dat_file        IN VARCHAR2
                          ) RETURN NUMBER IS

      -- Local variables
      l_proc    VARCHAR2(50) := g_package||'.write_hdr_file';
      l_retcode NUMBER := 0;
      l_tab     VARCHAR2(5) := fnd_global.tab;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Write header file header
      utl_file.put_line( p_hdr_file_handle
                       , 'Header'||l_tab||'Start');
      utl_file.put_line( p_hdr_file_handle
                       , 'Batch Name'||l_tab||SUBSTR(p_bg_name||'-'||TO_CHAR(SYSDATE,'YYYY/MM/DD'),1,70));
      utl_file.put_line( p_hdr_file_handle
                       , 'Date'||l_tab||TO_CHAR(SYSDATE,'YYYY/MM/DD'));
      utl_file.put_line( p_hdr_file_handle
                       , 'Version'||l_tab||'1.0');
      utl_file.put_line( p_hdr_file_handle
                       , 'Date Format'||l_tab||'YYYY/MM/DD');
      utl_file.put_line( p_hdr_file_handle
                       , 'Number Format'||l_tab||'999999999999999');
      utl_file.put_line( p_hdr_file_handle
                       , 'Header'||l_tab||'End');

      hr_utility.set_location(l_proc, 20);

      -- Write header file data
      utl_file.put_line( p_hdr_file_handle
                       , 'Files'||l_tab||'Start');
      utl_file.put_line( p_hdr_file_handle
                       , 'create_company_cost_center'||l_tab||p_dat_file);
      utl_file.put_line( p_hdr_file_handle
                       , 'Files'||l_tab||'End');

      hr_utility.set_location('Leaving: '|| l_proc, 30);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 40);
         hr_utility.set_location(SQLERRM, 45);
         writelog(SQLERRM,'N');
         l_retcode := 2;
         RETURN l_retcode;

   END write_hdr_file;

   --
   -- Write data file
   --
   FUNCTION write_dat_file( p_dat_file_handle IN utl_file.file_type
                          ) RETURN NUMBER IS

      -- Local variables
      l_proc          VARCHAR2(50) := g_package||'.write_dat_file';
      l_retcode       NUMBER := 0;
      l_tab           VARCHAR2(5) := fnd_global.tab;
      l_dat_rec_count NUMBER := 0;
      l_org_name       hr_all_organization_units.name%TYPE;
      l_cc             VARCHAR2(240); -- Cost Center value
      l_cc_desc        fnd_flex_values_vl.description%TYPE;
      l_co             VARCHAR2(240); -- Company value
      l_co_desc        fnd_flex_values_vl.description%TYPE;
      l_co_vs_name     fnd_flex_value_sets.flex_value_set_name%TYPE;
      l_cc_vs_name     fnd_flex_value_sets.flex_value_set_name%TYPE;
      l_org_start_date fnd_flex_values_vl.start_date_active%TYPE;

      TYPE cur_type IS REF CURSOR;
      c_list cur_type;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Write data file header
      utl_file.put_line( p_dat_file_handle
                       , 'Descriptor'||l_tab||'Start');
      utl_file.put_line( p_dat_file_handle
                       , 'API'||l_tab||'create_company_cost_center');
      utl_file.put_line( p_dat_file_handle
                       , 'Title'||l_tab||'create company cost center');
      utl_file.put_line( p_dat_file_handle
                       , 'Process Order'||l_tab||'10');
      utl_file.put_line( p_dat_file_handle
                       , 'Descriptor'||l_tab||'End');

      hr_utility.set_location(l_proc, 20);

      -- Write data file data titles
      utl_file.put_line( p_dat_file_handle
                       , 'Data'||l_tab||'Start');
      utl_file.put_line( p_dat_file_handle
                       , 'ID'                      ||l_tab||
                         'organization_name'       ||l_tab||
                         'costcenter_id'           ||l_tab||
                         'costcenter_name'         ||l_tab||
                         'company_id'              ||l_tab||
                         'company_name'            ||l_tab||
                         'costcenter_valueset_name'||l_tab||
                         'company_valueset_name'   ||l_tab||
                         'start_date'              ||l_tab||
                         'language_code'
                       );

      hr_utility.set_location(l_proc, 30);

      -- Write data file data
      OPEN c_list FOR 'SELECT org_name'       ||
                           ', cc'             ||
                           ', cc_desc'        ||
                           ', co'             ||
                           ', co_desc'        ||
                           ', cc_vs_name'     ||
                           ', co_vs_name'     ||
                           ', org_start_date' ||
                      ' FROM '||g_temp_table_name||
                      ' ORDER BY cc,co';
      LOOP
         FETCH c_list INTO l_org_name
                         , l_cc
                         , l_cc_desc
                         , l_co
                         , l_co_desc
                         , l_cc_vs_name
                         , l_co_vs_name
                         , l_org_start_date;
         EXIT WHEN c_list%NOTFOUND;

         l_dat_rec_count := l_dat_rec_count + 1;

         utl_file.put_line( p_dat_file_handle
                          , l_dat_rec_count ||l_tab|| -- Data Record Id
                            l_org_name      ||l_tab|| -- Org Name
                            l_cc            ||l_tab|| -- Cost Center Code
                            l_cc_desc       ||l_tab|| -- Cost Center Name
                            l_co            ||l_tab|| -- Company Code
                            l_co_desc       ||l_tab|| -- Company Name
                            l_cc_vs_name    ||l_tab|| -- Cost Cetner Valueset Name
                            l_co_vs_name    ||l_tab|| -- Company Valueset Name
                            l_org_start_date||l_tab|| -- Org Start Date
                            'US'                      -- Language Code
                          );
      END LOOP;
      CLOSE c_list;

      utl_file.put_line( p_dat_file_handle
                       , 'Data'||l_tab||'End');

      writelog('Spooled '||l_dat_rec_count||' data records to data file','Y');

      hr_utility.set_location('Leaving: '|| l_proc, 40);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 50);
         hr_utility.set_location(SQLERRM, 55);
         writelog(SQLERRM,'N');
         IF c_list%ISOPEN THEN
            CLOSE c_list;
         END IF;
         l_retcode := 2;
         RETURN l_retcode;

   END write_dat_file;

   --
   -- Spool export data to file
   --
   FUNCTION spool_to_file( p_bg_id   IN NUMBER
                         , p_bg_name IN VARCHAR2
                         ) RETURN NUMBER IS

      -- Local variables
      l_proc            VARCHAR2(50) := g_package||'.spool_to_file';
      l_retcode         NUMBER := 0;
      l_hdr_file        VARCHAR2(80) := NULL;
      l_dat_file        VARCHAR2(80) := NULL;
      l_hdr_file_handle utl_file.file_type;
      l_dat_file_handle utl_file.file_type;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Open export header and data files
      l_retcode := open_export_files( p_bg_id
                                    , p_bg_name
                                    , l_hdr_file
                                    , l_dat_file
                                    , l_hdr_file_handle
                                    , l_dat_file_handle
                                    );

      -- Write header file
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 20);
         l_retcode := write_hdr_file( l_hdr_file_handle
                                    , p_bg_name
                                    , l_dat_file
                                    );
      END IF;

      -- Write data file
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 30);
         l_retcode := write_dat_file( l_dat_file_handle
                                    );
      END IF;

      -- Close export header and data files
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 40);
         l_retcode := close_export_files( l_hdr_file_handle
                                        , l_dat_file_handle
                                        );
      END IF;

      hr_utility.set_location('Leaving: '|| l_proc, 50);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 60);
         hr_utility.set_location(SQLERRM, 65);
         writelog(SQLERRM,'N');
         l_retcode := 2;
         RETURN l_retcode;

   END spool_to_file;

   --
   -- Process Single Org Mode
   --
   FUNCTION single_org_mode( p_mode IN VARCHAR2
                           , p_ccid IN NUMBER
                           ) RETURN NUMBER IS

      -- Local variables
      l_proc          VARCHAR2(50) := g_package||'.single_org_mode';
      l_retcode       NUMBER := 0;
      l_coa_id        gl_code_combinations.chart_of_accounts_id%TYPE;
      l_co_seg        VARCHAR2(240); -- Col name of seg holding company value
      l_cc_seg        VARCHAR2(240); -- Col name of seg holding cost center value
      l_co_vs_id      NUMBER(15); -- Id of company value set
      l_cc_vs_id      NUMBER(15); -- Id of cost center value set
      l_co_desc       fnd_flex_values_vl.description%TYPE;
      l_cc_desc       fnd_flex_values_vl.description%TYPE;
      l_co_start_date fnd_flex_values_vl.start_date_active%TYPE;
      l_cc_start_date fnd_flex_values_vl.start_date_active%TYPE;
      l_co            VARCHAR2(240);
      l_cc            VARCHAR2(240);
      l_org_id        hr_all_organization_units.organization_id%TYPE := -1;
      l_bg_id         hr_all_organization_units.business_group_id%TYPE := -1;

      TYPE cur_type IS REF CURSOR;
      c_list cur_type;

      -- Local exceptions
      e_invalid_ccid EXCEPTION;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Get the chart of accounts identifier
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 20);
         l_retcode := get_chart_of_accounts_id( p_ccid
                                              , l_coa_id
                                              );
         IF l_retcode = 0 THEN
            hr_utility.set_location(l_proc, 30);
            hr_utility.set_message(800,'PER_50172_PROC_CCID');
            fnd_message.set_token('CCID',p_ccid);
            fnd_message.set_token('COA_ID',l_coa_id);
            writelog(fnd_message.get(),'N');
         ELSE
            hr_utility.set_location(l_proc, 40);
         RAISE e_invalid_ccid;
         END IF;
      END IF; -- retocde

      -- Get the segments and value sets for the chart of accounts
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 50);
         l_retcode := derive_value_sets( l_coa_id
                                       , l_co_seg
                                       , l_cc_seg
                                       , l_co_vs_id
                                       , l_cc_vs_id
                                       );
         writelog('Company Value Set Id: '||l_co_vs_id,'Y');
         writelog('Cost Center Value Set Id: '||l_cc_vs_id,'Y');
      END IF; -- retocde

      -- Get the actual company code and cost center code
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 60);
         OPEN c_list FOR 'SELECT '||l_co_seg||', '||l_cc_seg||
                         ' FROM gl_code_combinations'||
                         ' WHERE code_combination_id = :1'
                         USING p_ccid;
         FETCH c_list INTO l_co, l_cc;
         CLOSE c_list;

         hr_utility.set_message(800,'PER_50159_COMP_CODE');
         fnd_message.set_token('COMP_CODE',l_co);
         writelog(fnd_message.get(),'N');
         hr_utility.set_message(800,'PER_50160_COST_CENTER_CODE');
         fnd_message.set_token('COST_CENTER_CODE',l_cc);
         writelog(fnd_message.get(),'N');
      END IF; -- retocde

      -- Check if Organization already exists
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 70);
         OPEN c_list FOR 'SELECT UNITS.organization_id'||
                         ' FROM hr_all_organization_units UNITS'||
                             ', hr_organization_information CLASS'||
                             ', hr_organization_information CC'||
                         ' WHERE UNITS.organization_id = CLASS.organization_id'||
                         ' AND CLASS.org_information_context = ''CLASS'''||
                         ' AND CLASS.org_information1 = ''CC'''||
                         ' AND CLASS.organization_id = CC.organization_id'||
                         ' AND CC.org_information_context = ''Company Cost Center'''||
                         ' AND CC.org_information2 = :1'||
                         ' AND CC.org_information3 = :2'||
                         ' AND CC.org_information4 = :3'||
                         ' AND CC.org_information5 = :4'
                         USING TO_CHAR(l_co_vs_id), l_co, TO_CHAR(l_cc_vs_id), l_cc;
         FETCH c_list INTO l_org_id;
         IF c_list%NOTFOUND THEN
            hr_utility.set_location(l_proc, 80);
            writelog('No matching ORG found', 'Y');
            l_org_id := -1;
         ELSE
            hr_utility.set_location(l_proc, 90);
            writelog('Found matching ORG with Id:'||l_org_id, 'Y');
         END IF;
         CLOSE c_list;
      END IF; -- retocde

      -- Get Business Group Identifier if Organization needs to be created
      IF l_retcode = 0 AND l_org_id = -1 THEN
         hr_utility.set_location(l_proc, 100);
         l_retcode := get_business_group_id( l_co_vs_id
                                           , l_co
                                           , l_bg_id
                                           );
      END IF; -- retocde

      -- Create Organization if required
      IF l_retcode = 0 AND l_org_id = -1 THEN
         hr_utility.set_location(l_proc, 110);
         l_retcode := gen_org_co_cc_class( p_mode
                                         , l_bg_id
                                         , l_coa_id
                                         , l_co
                                         , l_co_vs_id
                                         , l_cc
                                         , l_cc_vs_id
                                         , l_org_id
                                         );
         IF l_retcode = 0 THEN
            hr_utility.set_location(l_proc, 120);
            -- Close transaction for ORG.
            COMMIT;
         ELSE -- retcode is not 0
            hr_utility.set_location(l_proc, 130);
            -- Write warning to LOG
            hr_utility.set_message(800,'PER_50170_ERR_PROC_CO_CC');
            fnd_message.set_token('COMP_CODE',l_co);
            fnd_message.set_token('COST_CENTER_CODE',l_cc);
            writelog(fnd_message.get(),'N');
            -- Close transaction for ORG.
            ROLLBACK;
            l_retcode := 2;
            l_org_id := -1;
         END IF;
      END IF; -- retocde is 0

      -- Synchronize new organization (if created) to GL
      IF l_retcode = 0 AND l_org_id <> -1 THEN
         hr_utility.set_location(l_proc, 140);
         EXECUTE IMMEDIATE 'UPDATE gl_code_combinations'||
                           ' SET company_cost_center_org_id = :1'||
                              ', last_update_date = SYSDATE'||
                              ', last_updated_by = :2'||
                           ' WHERE code_combination_id = :3'
                           USING l_org_id, fnd_global.user_id, p_ccid;
         writelog('Updated GL Code Combinations with Org Id:'||l_org_id||
                  ' for CCID:'||p_ccid, 'Y');
         hr_utility.set_location('Updated GL Code Combinations with Org Id:'||
                                 l_org_id||' for CCID:'||p_ccid, 150);
      END IF; -- retocde is 0

      hr_utility.set_location('Leaving: '|| l_proc, 160);

      RETURN l_retcode;

   EXCEPTION

      WHEN e_invalid_ccid THEN
         hr_utility.set_location('Leaving: '|| l_proc, 170);
         hr_utility.set_message(800,'PER_50173_INVALID_CCID');
         fnd_message.set_token('CCID',p_ccid);
         writelog(fnd_message.get(),'N');
         l_retcode := 2;
         RETURN l_retcode;

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 180);
         hr_utility.set_location(SQLERRM, 185);
         writelog(SQLERRM,'N');
         IF c_list%ISOPEN THEN
            CLOSE c_list;
         END IF;
         l_retcode := 2;
         RETURN l_retcode;

   END single_org_mode;

   --
   -- Process Report Mode
   --
   FUNCTION report_mode( p_mode    IN VARCHAR2
                       , p_bg_id   IN NUMBER
                       , p_coa_id  IN NUMBER
                       , p_source  IN VARCHAR2
                       , p_bg_name IN VARCHAR2
                       ) RETURN NUMBER IS

      -- Local variables
      l_proc     VARCHAR2(50) := g_package||'.report_mode';
      l_retcode  NUMBER := 0;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Populate Company Cost Center Combinations into temp table and
      -- delete those which do not have company organizations in the
      -- current business group.
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 20);
         l_retcode := get_co_cc_combinations( p_mode
                                            , p_bg_id
                                            , p_coa_id
                                            , NULL
                                            , p_source
                                            );
      END IF;

      -- Fetch record details for reporting/exporting
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 30);
         l_retcode := get_details_to_report( p_mode
                                           );
      END IF;

      -- Spool data to output file
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 40);
         l_retcode := spool_to_file( p_bg_id
                                   , p_bg_name
                                   );
      END IF;

      hr_utility.set_location('Leaving: '|| l_proc, 50);

      RETURN l_retcode;

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 60);
         hr_utility.set_location(SQLERRM, 65);
         writelog(SQLERRM,'N');
         l_retcode := 2;
         RETURN l_retcode;

   END report_mode;

   --
   -- Process Synchronize Mode
   --
   -- Fetch GL Co-CC combinations to process into temp table
   -- Update the temp table with Id of matching ORGs.
   -- Update GL_CODE_COMBINATIONS with matching Ids from temp table.
   -- Close transaction.
   --
   FUNCTION synchronize_mode( p_business_group_id IN NUMBER
                            , p_coa_id            IN NUMBER
                            , p_co                IN VARCHAR2
                            ) RETURN NUMBER IS

      -- Local variables
      l_proc                 VARCHAR2(50) := g_package||'.synchronize_mode';
      l_retcode              NUMBER := 0;
      l_rowcount             NUMBER := 0;
      l_delrowcount          NUMBER := 0;
      l_updated_by           NUMBER := 0;
      l_ccid                 NUMBER;
      l_co                   VARCHAR2(240);
      l_cc                   VARCHAR2(240);
      l_org_id               hr_all_organization_units.organization_id%TYPE := -1;
      l_duplicate_orgs_found BOOLEAN;

      -- Local exceptions
      e_no_records_to_process EXCEPTION;

      TYPE cur_type IS REF CURSOR;
      c_list cur_type;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Populates Company Cost Center Combinations into temp table
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 20);
         l_retcode := get_gl_co_cc_to_sync( p_business_group_id
                                          , p_coa_id
                                          , p_co
                                          , l_duplicate_orgs_found
                                          );
      END IF; -- retcode is 0

      -- For each record in temp, identify matching ORG and update the Id
      -- into temp table.
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 30);

         EXECUTE IMMEDIATE 'UPDATE '||g_temp_table_name||' TEMP'||
                           ' SET TEMP.org_id ='||
                           ' (SELECT UNITS.organization_id'||
                           ' FROM hr_all_organization_units UNITS'||
                                ', hr_organization_information CLASS'||
                                ', hr_organization_information CC'||
                            ' WHERE UNITS.organization_id = CLASS.organization_id'||
                            ' AND CLASS.org_information_context = ''CLASS'''||
                            ' AND CLASS.org_information1 = ''CC'''||
                            ' AND CLASS.organization_id = CC.organization_id'||
                            ' AND CC.org_information_context = ''Company Cost Center'''||
                            ' AND CC.org_information2 = TO_CHAR(TEMP.co_vs_id)'||
                            ' AND CC.org_information3 = TEMP.co'||
                            ' AND CC.org_information4 = TO_CHAR(TEMP.cc_vs_id)'||
                            ' AND CC.org_information5 = TEMP.cc'||
                            ' AND UNITS.business_group_id = :1)'
                            USING p_business_group_id;

         l_rowcount := SQL%ROWCOUNT;
         IF l_rowcount = 0 THEN
            RAISE e_no_records_to_process;
         END IF;

         writelog('Updated '||SQL%ROWCOUNT||' ORGs to temp table','Y');
      END IF; -- retcode is 0

      -- Update GL Code Combinations with the matching ORG Id values
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 40);

         EXECUTE IMMEDIATE 'UPDATE gl_code_combinations GCC'||
                           ' SET ( GCC.company_cost_center_org_id'||
                                ', GCC.last_update_date'||
                                ', GCC.last_updated_by) ='||
                                ' (SELECT SYNC.org_id'||
                                       ', TRUNC(SYSDATE)'||
                                       ','||l_updated_by||
                                 ' FROM '||g_temp_table_name||' SYNC'||
                                 ' WHERE SYNC.ccid = GCC.code_combination_id'||
                                 ' AND SYNC.org_id IS NOT NULL)'||
                           ' WHERE GCC.company_cost_center_org_id IS NULL'||
                           ' AND GCC.code_combination_id IN (SELECT ccid'||
                                                 ' FROM '||g_temp_table_name||
                                                 ' WHERE org_id IS NOT NULL)';

         writelog('Updated '||SQL%ROWCOUNT||' ORGs to GL Code Combinations','Y');
      END IF; -- retcode is 0

      -- Close transaction on successfull completion
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 50);

         COMMIT;
      END IF; -- retcode is 0

      -- Log synchronized combinations with organizations
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 60);

         OPEN c_list FOR 'SELECT ccid, co, cc, org_id FROM '||g_temp_table_name;
         LOOP
            FETCH c_list INTO l_ccid, l_co, l_cc, l_org_id;
            EXIT WHEN c_list%NOTFOUND;

            hr_utility.set_message(800,'PER_50169_SYNC_REC_DETAILS');
            fnd_message.set_token('CCID',l_ccid);
            fnd_message.set_token('COMP_CODE',l_co);
            fnd_message.set_token('COST_CENTER_CODE',l_cc);
            fnd_message.set_token('ORG_ID',l_org_id);
            writelog(fnd_message.get(),'N');
         END LOOP; -- records in temp table
         CLOSE c_list;
      END IF; -- retcode is 0

      -- Flag whether duplicate Company Cost Center ORGs were found while
      -- getting records to synchronize by exiting with warnings.
      IF l_retcode = 0 AND l_duplicate_orgs_found THEN
         hr_utility.set_location(l_proc, 70);
         hr_utility.set_message(800,'PER_50176_DUPL_CO_CC_ORGS');
         writelog(fnd_message.get(),'N');
         l_retcode := 1;
      END IF; -- retcode is 0

      hr_utility.set_location('Leaving: '|| l_proc, 80);

      RETURN l_retcode;

   EXCEPTION

      WHEN e_no_records_to_process THEN
         hr_utility.set_location('Leaving: '|| l_proc, 90);
         hr_utility.set_message(800,'PER_50154_NO_CO_CC_COMBS');
         writelog(fnd_message.get(),'N');
         l_retcode := 1;
         RETURN l_retcode;

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 100);
         hr_utility.set_location(SQLERRM, 105);
         writelog(SQLERRM,'N');
         l_retcode := 2;
         RETURN l_retcode;

   END synchronize_mode;

   --
   -- Process Create/Maintain Mode
   --
   -- Fetch Co-CC combinations to process into temp table.
   -- For each record in temp table.
   --    Invoke gen_co_cc_class() to process the record.
   --    Commit record if successful else rollback.
   --
   FUNCTION create_maintain_mode( p_mode              IN VARCHAR2
                                , p_business_group_id IN NUMBER
                                , p_coa_id            IN NUMBER
                                , p_co                IN VARCHAR2
                                , p_source            IN VARCHAR2
                                , p_sync_org_name     IN VARCHAR2
                                , p_sync_org_dates    IN VARCHAR2
                                ) RETURN NUMBER IS

      -- Local variables
      l_proc           VARCHAR2(50) := g_package||'.create_maintain_mode';
      l_retcode        NUMBER := 0;
      l_rowcount       NUMBER;  -- Added for bug4346785.
      l_processed_recs BOOLEAN := FALSE;
      l_errored_recs   BOOLEAN := FALSE;
      l_coa_id         NUMBER;
      l_co             VARCHAR2(240); -- Company value
      l_cc             VARCHAR2(240); -- Cost Center value
      l_co_vs_id       NUMBER(15); -- Id of company value set
      l_cc_vs_id       NUMBER(15); -- Id of cost center value set
      l_org_id         hr_all_organization_units.organization_id%TYPE;

      -- Local exceptions
      e_no_records_to_process EXCEPTION;

      TYPE cur_type IS REF CURSOR;
      c_list cur_type;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Populates Company Cost Center Combinations into temp table
      -- that require ORG/Classification records to be created or
      -- maintained.
      -- phase 2a - Also does maintenance of existing org names before those
      -- combinations are deleted.
      --
      -- Fix for bug 3837139 starts here.
      --
      /*
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 20);
         l_retcode := get_co_cc_combinations( p_mode
                                            , p_business_group_id
                                            , p_coa_id
                                            , p_co
                                            , p_source
                                            , p_sync_org_name
                                            , p_sync_org_dates
                                            );
      END IF;
      */
      --
      IF l_retcode = 0 THEN
        hr_utility.set_location(l_proc, 20);
        l_retcode := get_co_cc_comb_into_temp(
                      p_business_group_id
                     ,p_coa_id
                     ,p_co
                     ,p_source
                     ,l_rowcount  -- Added for bug4346785.
                     );
      END IF;
      --

-- Fix For Bug # 6929228 Starts ---

      IF l_retcode = 0 THEN
        hr_utility.set_location(l_proc, 22);
        l_retcode := update_org_name_date(
                            p_mode
                           ,p_sync_org_name
                           ,p_sync_org_dates
                           );
      END IF;

-- Fix For Bug # 6929228 Ends ---

      --
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 24);
         l_retcode := delete_sync_orgs_from_temp(
                                  p_mode
                                 ,p_business_group_id
                                 ,p_coa_id
                                 ,l_rowcount  -- Added for bug4346785.
                                );
      END IF;
      --
      -- Fix for bug 3837139 ends here.
      --
      -- For each record in temp table, generate ORG, Co-Class, CC-Class as required
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 30);

         OPEN c_list FOR 'SELECT coa_id, co, co_vs_id, cc, cc_vs_id FROM '||g_temp_table_name;
         LOOP
            FETCH c_list INTO l_coa_id, l_co, l_co_vs_id, l_cc, l_cc_vs_id;
            EXIT WHEN c_list%NOTFOUND;
            l_processed_recs := TRUE;

            -- At this point, the system does not have an organization with the same
            -- company and cost center classifications. However the ORG can exist but
            -- without the requisite classifications or the ORG does not exist at all.
            l_retcode := gen_org_co_cc_class( p_mode
                                            , p_business_group_id
                                            , l_coa_id
                                            , l_co
                                            , l_co_vs_id
                                            , l_cc
                                            , l_cc_vs_id
                                            , l_org_id
                                            );
            IF l_retcode = 0 THEN
               -- Close transaction for ORG.
               COMMIT;
            ELSE -- retcode is not 0
               l_errored_recs := TRUE;
               -- Skip processing this company cost center combination and proceed with next.
               writelog('Error processing P_BG_ID: '||p_business_group_id||
                                       ', P_COA_ID: '||l_coa_id||
                                       ', P_CO: '||l_co||
                                       ', P_CO_VS_ID: '||l_co_vs_id||
                                       ', P_CC: '||l_cc||
                                       ', P_CC_VS_ID: '||l_cc_vs_id,'Y');
               -- Write warning to LOG
               hr_utility.set_message(800,'PER_50170_ERR_PROC_CO_CC');
               fnd_message.set_token('COMP_CODE',l_co);
               fnd_message.set_token('COST_CENTER_CODE',l_cc);
               writelog(fnd_message.get(),'N');
               -- Close transaction for ORG.
               ROLLBACK;
               -- Reset return code to continue processing next ORG.
               l_retcode := 0;
            END IF;
         END LOOP; -- records in temp table
         CLOSE c_list;

         IF NOT l_processed_recs THEN
            RAISE e_no_records_to_process;
         END IF;

         IF l_errored_recs THEN
            -- Force exit with warning to prompt the user to check the process LOG.
            l_retcode := 1;
         END IF;
      END IF; -- retcode is 0

      IF l_retcode = 0 THEN
        hr_utility.set_location(l_proc, 22);
        l_retcode := update_org_name_date(
                            p_mode
                           ,p_sync_org_name
                           ,p_sync_org_dates
                           );
      END IF;

      hr_utility.set_location('Leaving: '|| l_proc, 40);

      RETURN l_retcode;

   EXCEPTION

      WHEN e_no_records_to_process THEN
         hr_utility.set_location('Leaving: '|| l_proc, 50);
         hr_utility.set_message(800,'PER_50154_NO_CO_CC_COMBS');
         writelog(fnd_message.get(),'N');
         IF c_list%ISOPEN THEN
            CLOSE c_list;
         END IF;
         l_retcode := 1;
         RETURN l_retcode;

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 60);
         hr_utility.set_location(SQLERRM, 65);
         writelog(SQLERRM,'N');
         IF c_list%ISOPEN THEN
            CLOSE c_list;
         END IF;
         l_retcode := 2;
         RETURN l_retcode;

   END create_maintain_mode;

   --
   -- Initialize package globals.
   --
   -- Set length of ORG Name based on UTF8 trigger.
   -- Set debug level.
   -- Get values held in profile options.
   -- Get schema name for product PER.
   -- Coin temp table name.
   -- Start LOG and OUT files by invoking open_logs().
   -- Create temp table.
   --
   FUNCTION initialize( p_mode              IN VARCHAR2
                      , p_business_group_id IN NUMBER
                      , p_coa_id            IN NUMBER
                      , p_ccid              IN NUMBER
                      ) RETURN NUMBER IS

      -- Local Variables
      l_proc    VARCHAR2(50) := g_package||'.initialize';
      l_dummy   NUMBER := 0;
      l_retcode NUMBER := 0;

      -- Cursor to test the existence of the UTF8 trigger
      CURSOR c_utf8_trigger IS
         SELECT 1
         FROM   user_triggers
         WHERE  trigger_name = 'HR_ALL_ORGANIZATION_UNITS_UTF8';

      -- Cursor to get the debug level for the instance.
      CURSOR c_debug_level IS
         SELECT parameter_value
         FROM   pay_action_parameters
         WHERE  parameter_name = 'HR_GL_SYNC_DEBUG';

      -- Local Exceptions
      e_class_profile   EXCEPTION;
      e_org_name_format EXCEPTION;
      e_export_dir      EXCEPTION;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Set the global holding the max length of ORG Name based on the
      -- existence of the UTF8 trigger. If trigger exists, set the max
      -- length to 60, else 240.
      OPEN c_utf8_trigger;
      FETCH c_utf8_trigger INTO l_dummy;
      IF c_utf8_trigger%FOUND THEN
         hr_utility.set_location(l_proc, 20);
         g_org_name_max_length := 60;
      ELSE
         hr_utility.set_location(l_proc, 30);
         g_org_name_max_length := 240;
      END IF;
      CLOSE c_utf8_trigger;

      hr_utility.set_location(l_proc, 40);

      -- Set the debug level for the instance
      OPEN c_debug_level;
      FETCH c_debug_level INTO g_debug_level;
      IF c_debug_level%NOTFOUND THEN
         hr_utility.set_location(l_proc, 50);
         g_debug_level := 'NORMAL';
      END IF;
      CLOSE c_debug_level;

      hr_utility.set_location(l_proc, 60);

      -- Get profile option values
      g_class_profile := fnd_profile.value('HR_GENERATE_GL_ORGS');
      g_org_name_format := fnd_profile.value('HR_GL_ORG_NAME_FORMAT');
      g_export_dir := fnd_profile.value('PER_DATA_EXCHANGE_DIR');

      IF p_mode IN ('CREATE_MAINTAIN','SINGLE_ORG') THEN
         hr_utility.set_location(l_proc, 70);
         IF g_class_profile IS NULL OR g_class_profile = 'N' THEN
            hr_utility.set_location(l_proc, 80);
            RAISE e_class_profile;
         END IF;
      END IF; -- p_mode check

      IF p_mode IN ('CREATE_MAINTAIN','SINGLE_ORG','EXPORT') THEN
         hr_utility.set_location(l_proc, 90);
         IF g_org_name_format IS NULL THEN
            hr_utility.set_location(l_proc, 100);
            RAISE e_org_name_format;
         END IF;
      END IF; -- p_mode check

      IF p_mode = 'EXPORT' THEN
         hr_utility.set_location(l_proc, 110);
         IF g_export_dir IS NULL THEN
            hr_utility.set_location(l_proc, 120);
            RAISE e_export_dir;
         END IF;
      END IF; -- p_mode check

      hr_utility.set_location(l_proc, 130);

      -- Get the PER schema name
      g_per_schema := get_schema(g_appl_short_name);

      hr_utility.set_location(l_proc, 140);

      -- Initialize the temporary table name
      g_temp_table_name := g_per_schema || '.HR_CO_CC_TEMP';
      IF p_mode = 'SINGLE_ORG' THEN
         hr_utility.set_location(l_proc, 150);
         g_temp_table_name := g_temp_table_name || '_' || p_ccid;
      ELSIF p_mode IN ('CREATE_MAINTAIN','SYNCHRONIZE') THEN
         hr_utility.set_location(l_proc, 160);
         g_temp_table_name := g_temp_table_name || '_' || p_business_group_id;
      ELSIF p_mode = 'EXPORT' THEN
         hr_utility.set_location(l_proc, 170);
         g_temp_table_name := g_temp_table_name || '_' || p_coa_id;
      END IF;

      -- Open LOG and OUT files
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 180);
         l_retcode := open_logs( p_mode
                               , p_business_group_id
                               , p_ccid
                               );
      END IF;

      -- Create temporary table
      IF l_retcode = 0 THEN
         hr_utility.set_location(l_proc, 190);
         IF p_mode IN ('CREATE_MAINTAIN','SYNCHRONIZE','EXPORT') THEN
            hr_utility.set_location(l_proc, 200);
            create_temp_table(p_mode);
         END IF;
      END IF;

      hr_utility.set_location('Leaving: '|| l_proc, 210);

      RETURN l_retcode;

   EXCEPTION

      WHEN e_class_profile THEN
         hr_utility.set_location('Leaving: '|| l_proc, 220);
         hr_utility.set_message(800,'PER_50155_ORG_CLASS_PROF_WARN');
         writelog(fnd_message.get(),'N');
         l_retcode := 2;
         RETURN l_retcode;

      WHEN e_org_name_format THEN
         hr_utility.set_location('Leaving: '|| l_proc, 230);
         hr_utility.set_message(800,'HR_289489_NO_NAME_FORMAT');
         writelog(fnd_message.get(),'N');
         l_retcode := 2;
         RETURN l_retcode;

      WHEN e_export_dir THEN
         hr_utility.set_location('Leaving: '|| l_proc, 240);
         hr_utility.set_message(800,'HR_289427_NO_EXC_DIR');
         writelog(fnd_message.get(),'N');
         l_retcode := 2;
         RETURN l_retcode;

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 250);
         hr_utility.set_location(SQLERRM, 255);
         writelog(SQLERRM,'N');
         IF c_utf8_trigger%ISOPEN THEN
            CLOSE c_utf8_trigger;
         END IF;
         IF c_debug_level%ISOPEN THEN
            CLOSE c_debug_level;
         END IF;
         l_retcode := 2;
         RETURN l_retcode;

   END initialize;

   --
   -- Validate passed parameters.
   --
   -- Check that P_MODE is valid.
   -- Check that P_COA_ID is supplied.
   -- If mode is SINGLE_ORG
   --    Check that P_CCID is supplied.
   -- If mode is not SINGLE_ORG
   --    Check that P_BUSINESS_GROUP_ID is supplied.
   --
   FUNCTION validate_params( p_mode              IN VARCHAR2
                           , p_business_group_id IN NUMBER
                           , p_coa_id            IN NUMBER
                           , p_co                IN VARCHAR2
                           , p_ccid              IN NUMBER
                           , p_source            IN VARCHAR2
                           ) RETURN NUMBER IS

      -- Local variables
      l_proc    VARCHAR2(50) := g_package||'.validate_params';
      l_retcode NUMBER := 0;

      -- Local exceptions
      e_invalid_mode   EXCEPTION;
      e_no_coaid       EXCEPTION;
      e_no_ccid        EXCEPTION;
      e_no_bgid        EXCEPTION;
      e_invalid_source EXCEPTION;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      IF p_mode IS NULL OR
         p_mode NOT IN ('CREATE_MAINTAIN','SYNCHRONIZE','EXPORT','SINGLE_ORG') THEN
         hr_utility.set_location(l_proc, 20);
         RAISE e_invalid_mode;
      END IF;

      IF p_mode IN ('CREATE_MAINTAIN','SYNCHRONIZE','EXPORT') THEN
         hr_utility.set_location(l_proc, 30);
         IF p_coa_id IS NULL THEN
            hr_utility.set_location(l_proc, 40);
            RAISE e_no_coaid;
         END IF;
      END IF;

      IF p_mode = 'SINGLE_ORG' THEN
         hr_utility.set_location(l_proc, 50);
         IF p_ccid IS NULL THEN
            hr_utility.set_location(l_proc, 60);
            RAISE e_no_ccid;
         END IF;
      ELSE -- mode is not single org
         hr_utility.set_location(l_proc, 70);
         IF p_business_group_id IS NULL THEN
            hr_utility.set_location(l_proc, 80);
            RAISE e_no_bgid;
         END IF;
      END IF;

      IF p_mode IN ('CREATE_MAINTAIN','EXPORT') THEN
         hr_utility.set_location(l_proc, 90);
         IF p_source IS NULL OR p_source NOT IN ('GLCC','CCVS') THEN
            hr_utility.set_location(l_proc, 100);
            RAISE e_invalid_source;
         END IF;
      END IF;

      hr_utility.set_location('Leaving: '|| l_proc, 110);

      RETURN l_retcode;

   EXCEPTION

      WHEN e_invalid_mode THEN
         hr_utility.set_location('Leaving: '|| l_proc, 120);
         hr_utility.set_message(800,'PER_50150_INVAL_SYNC_ORG_MODE');
         fnd_message.set_token('MODE',p_mode);
         writelog(fnd_message.get(),'N');
         l_retcode := 2;
         RETURN l_retcode;

      WHEN e_no_coaid THEN
         hr_utility.set_location('Leaving: '|| l_proc, 130);
         hr_utility.set_message(800,'PER_50151_NO_COAID');
         writelog(fnd_message.get(),'N');
         l_retcode := 2;
         RETURN l_retcode;

      WHEN e_no_ccid THEN
         hr_utility.set_location('Leaving: '|| l_proc, 140);
         hr_utility.set_message(800,'PER_50152_NO_CCID');
         writelog(fnd_message.get(),'N');
         l_retcode := 2;
         RETURN l_retcode;

      WHEN e_no_bgid THEN
         hr_utility.set_location('Leaving: '|| l_proc, 150);
         hr_utility.set_message(800,'PER_50153_NO_BGID');
         writelog(fnd_message.get(),'N');
         l_retcode := 2;
         RETURN l_retcode;

      WHEN e_invalid_source THEN
         hr_utility.set_location('Leaving: '|| l_proc, 160);
         hr_utility.set_message(800,'PER_50156_INVAL_CO_CC_SOURCE');
         fnd_message.set_token('SOURCE',p_source);
         writelog(fnd_message.get(),'N');
         l_retcode := 2;
         RETURN l_retcode;

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 170);
         hr_utility.set_location(SQLERRM, 175);
         writelog(SQLERRM,'N');
         l_retcode := 2;
         RETURN l_retcode;

   END validate_params;

   --
   -- Main Entry Point Procedure for Concurrent Programs.
   --
   -- Validate parameter values passed in.
   -- Set global variables, open log and out files, create temp table.
   -- Log details of parameters passed and global values.
   -- If mode is CREATE_MAINTAIN
   --    Invoke create_maintain_mode().
   -- Else if mode is SYNCHRONIZE
   --    Invoke synchronize_mode().
   -- If mode is EXPORT
   --    Invoke report_mode().
   -- If mode is SINGLE_ORG
   --    Invoke single_org_mode().
   -- Log exit state.
   --
   PROCEDURE sync_orgs( errbuf              IN OUT NOCOPY VARCHAR2
                      , retcode             IN OUT NOCOPY NUMBER
                      , p_mode              IN            VARCHAR2
                      , p_business_group_id IN            NUMBER
                      , p_coa_id            IN            NUMBER
                      , p_co                IN            VARCHAR2
                      , p_ccid              IN            NUMBER
                      , p_source            IN            VARCHAR2
                      , p_sync_org_name     IN            VARCHAR2 DEFAULT 'N'
                      , p_sync_org_dates    IN            VARCHAR2 DEFAULT 'N'
                      ) IS

      -- Local variables
      l_proc    VARCHAR2(50) := g_package||'.sync_orgs';
      l_bg_name hr_all_organization_units.name%TYPE;

      -- Cursor to fetch business group name
      CURSOR c_bg_name IS
         SELECT name
         FROM   hr_all_organization_units
         WHERE  organization_id = p_business_group_id;

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      -- Validate Parameters
      IF retcode = 0 THEN
         hr_utility.set_location(l_proc, 20);
         retcode := validate_params( p_mode
                                   , p_business_group_id
                                   , p_coa_id
                                   , p_co
                                   , p_ccid
                                   , p_source
                                   );
      END IF; -- retcode is 0

      -- Initialize variables, files and temp tables
      IF retcode = 0 THEN
         hr_utility.set_location(l_proc, 30);
         retcode := initialize( p_mode
                              , p_business_group_id
                              , p_coa_id
                              , p_ccid);
      END IF; -- retcode is 0

      -- Fetch the business group name
      IF retcode = 0 THEN
         hr_utility.set_location(l_proc, 40);
         OPEN c_bg_name;
         FETCH c_bg_name INTO l_bg_name;
         IF c_bg_name%NOTFOUND THEN
            hr_utility.set_location(l_proc, 50);
            l_bg_name := 'UNKNOWN';
         END IF;
         CLOSE c_bg_name;
      END IF; -- retcode is 0

      -- Log instance state
      IF retcode = 0 THEN
         hr_utility.set_location(l_proc, 60);
         writelog('==========================================','Y');
         writelog('Starting Synchronize Organizations Program','Y');
         writelog('==========================================','Y');
         hr_utility.set_message(800,'PER_50157_BUS_GRP_NAME');
         fnd_message.set_token('BUS_GRP_NAME',l_bg_name);
         fnd_message.set_token('BUS_GRP_ID',p_business_group_id);
         writelog(fnd_message.get(),'N');
         writelog('----------','Y');
         writelog('Parameters','Y');
         writelog('----------','Y');
         writelog('P_MODE: '||p_mode,'Y');
         writelog('P_COA_ID: '||p_coa_id,'Y');
         writelog('P_CO: '||p_co,'Y');
         writelog('P_CCID: '||p_ccid,'Y');
         writelog('P_SOURCE: '||p_source,'Y');
         writelog('P_SYNC_ORG_NAME: '||p_sync_org_name,'Y');
         writelog('P_SYNC_ORG_DATES: '||p_sync_org_dates,'Y');
         writelog('-------','Y');
         writelog('Globals','Y');
         writelog('-------','Y');
         writelog('G_PACKAGE: '||g_package,'Y');
         writelog('G_ORG_NAME_MAX_LENGTH: '||g_org_name_max_length,'Y');
         writelog('G_DEBUG_LEVEL: '||g_debug_level,'Y');
         writelog('G_CLASS_PROFILE: '||g_class_profile,'Y');
         writelog('G_ORG_NAME_FORMAT: '||g_org_name_format,'Y');
         writelog('G_PER_SCHEMA: '||g_per_schema,'Y');
         writelog('G_TEMP_TABLE_NAME: '||g_temp_table_name,'Y');
         writelog('G_EXPORT_DIR: '||g_export_dir,'Y');
         writelog('--','Y');
      END IF; -- retcode is 0

      -- Process in appropriate mode
      IF retcode = 0 THEN
         IF p_mode = 'CREATE_MAINTAIN' THEN
            hr_utility.set_location(l_proc, 70);
            retcode := create_maintain_mode( p_mode
                                           , p_business_group_id
                                           , p_coa_id
                                           , p_co
                                           , p_source
                                           , p_sync_org_name
                                           , p_sync_org_dates
                                           );

         ELSIF p_mode = 'SYNCHRONIZE' THEN
            hr_utility.set_location(l_proc, 80);
            retcode := synchronize_mode( p_business_group_id
                                       , p_coa_id
                                       , p_co
                                       );

         ELSIF p_mode = 'EXPORT' THEN
            hr_utility.set_location(l_proc, 90);
            retcode := report_mode( p_mode
                                  , p_business_group_id
                                  , p_coa_id
                                  , p_source
                                  , l_bg_name
                                  );

         ELSIF p_mode = 'SINGLE_ORG' THEN
            hr_utility.set_location(l_proc, 100);
            retcode := single_org_mode( p_mode
                                      , p_ccid
                                      );

         END IF; -- p_mode test

         IF p_mode IN ('CREATE_MAINTAIN','SYNCHRONIZE','EXPORT') THEN
            hr_utility.set_location(l_proc, 110);
            drop_temp_table;
         END IF; -- p_mode test

      END IF; -- retcode = 0

      hr_utility.set_location(l_proc, 120);

      -- Exit Messages
      IF retcode = 0 THEN
         hr_utility.set_location(l_proc, 130);
         writelog('==============================','Y');
         writelog('Program Completed Successfully','Y');
         writelog('==============================','Y');
      ELSIF retcode = 1 THEN
         hr_utility.set_location(l_proc, 140);
         writelog('===============================','Y');
         writelog('Program Completed with Warnings','Y');
         writelog('===============================','Y');
      ELSIF retcode = 2 THEN
         hr_utility.set_location(l_proc, 150);
         writelog('===========================','Y');
         writelog('Program Terminated in Error','Y');
         writelog('===========================','Y');
      ELSE
         hr_utility.set_location(l_proc, 160);
         writelog('========================================','Y');
         writelog('Program Terminated with unknown code ('||TO_CHAR(retcode)||')','Y');
         writelog('========================================','Y');
      END IF;

      hr_utility.set_location('Leaving: '|| l_proc, 170);

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 180);
         errbuf := SQLERRM;
         hr_utility.set_location(errbuf, 185);
         writelog(errbuf,'N');
         retcode := 2;

   END sync_orgs;

   --
   -- Main Entry Point Procedure for GL Code Hook.
   --
   -- Validate if single ORG processing is enabled and if it is,
   -- spawn an instance of the create maintain concurrent process
   -- in single ORG mode.
   --
   PROCEDURE sync_single_org( p_ccid IN NUMBER
                            ) IS

      -- Local variables
      l_proc               VARCHAR2(50) := g_package||'.sync_single_org';
      l_request_id         NUMBER := -1;
      l_class_profile      VARCHAR2(10);
      l_single_org_profile VARCHAR2(10);

   BEGIN

      hr_utility.set_location('Entering: '|| l_proc, 10);

      l_class_profile      := fnd_profile.value('HR_GENERATE_GL_ORGS');
      l_single_org_profile := fnd_profile.value('HR_SYNC_SINGLE_GL_ORG');

      -- Check if single Org mode is enabled
      IF l_class_profile IS NULL OR
         l_class_profile NOT IN ('CC','CCHR') OR
         l_single_org_profile IS NULL OR
         l_single_org_profile NOT IN ('Y') THEN
         hr_utility.set_location(l_proc, 20);
         RETURN;
      END IF;

      hr_utility.set_location(l_proc, 30);

      -- Launch the Sync Orgs concurrent program in 'SINGLE_ORG' mode.
      l_request_id := fnd_request.submit_request
         (APPLICATION => g_appl_short_name,
          PROGRAM     => 'HR_GL_CREATE_MAINTAIN_ORGS',
          DESCRIPTION => NULL,
          START_TIME  => NULL,
          SUB_REQUEST => FALSE,
          ARGUMENT1   => 'SINGLE_ORG', -- Mode
          ARGUMENT2   => NULL,         -- Business Group Id
          ARGUMENT3   => NULL,         -- Chart Of Accounts Id
          ARGUMENT4   => NULL,         -- Company Code
          ARGUMENT5   => p_ccid,       -- Code Combination Id
          ARGUMENT6   => NULL,         -- Source
          ARGUMENT7   => CHR(0),
          ARGUMENT8   => NULL, ARGUMENT9   => NULL, ARGUMENT10  => NULL,
          ARGUMENT11  => NULL, ARGUMENT12  => NULL, ARGUMENT13  => NULL,
          ARGUMENT14  => NULL, ARGUMENT15  => NULL, ARGUMENT16  => NULL,
          ARGUMENT17  => NULL, ARGUMENT18  => NULL, ARGUMENT19  => NULL,
          ARGUMENT20  => NULL, ARGUMENT21  => NULL, ARGUMENT22  => NULL,
          ARGUMENT23  => NULL, ARGUMENT24  => NULL, ARGUMENT25  => NULL,
          ARGUMENT26  => NULL, ARGUMENT27  => NULL, ARGUMENT28  => NULL,
          ARGUMENT29  => NULL, ARGUMENT30  => NULL, ARGUMENT31  => NULL,
          ARGUMENT32  => NULL, ARGUMENT33  => NULL, ARGUMENT34  => NULL,
          ARGUMENT35  => NULL, ARGUMENT36  => NULL, ARGUMENT37  => NULL,
          ARGUMENT38  => NULL, ARGUMENT39  => NULL, ARGUMENT40  => NULL,
          ARGUMENT41  => NULL, ARGUMENT42  => NULL, ARGUMENT43  => NULL,
          ARGUMENT44  => NULL, ARGUMENT45  => NULL, ARGUMENT46  => NULL,
          ARGUMENT47  => NULL, ARGUMENT48  => NULL, ARGUMENT49  => NULL,
          ARGUMENT50  => NULL, ARGUMENT51  => NULL, ARGUMENT52  => NULL,
          ARGUMENT53  => NULL, ARGUMENT54  => NULL, ARGUMENT55  => NULL,
          ARGUMENT56  => NULL, ARGUMENT57  => NULL, ARGUMENT58  => NULL,
          ARGUMENT59  => NULL, ARGUMENT60  => NULL, ARGUMENT61  => NULL,
          ARGUMENT62  => NULL, ARGUMENT63  => NULL, ARGUMENT64  => NULL,
          ARGUMENT65  => NULL, ARGUMENT66  => NULL, ARGUMENT67  => NULL,
          ARGUMENT68  => NULL, ARGUMENT69  => NULL, ARGUMENT70  => NULL,
          ARGUMENT71  => NULL, ARGUMENT72  => NULL, ARGUMENT73  => NULL,
          ARGUMENT74  => NULL, ARGUMENT75  => NULL, ARGUMENT76  => NULL,
          ARGUMENT77  => NULL, ARGUMENT78  => NULL, ARGUMENT79  => NULL,
          ARGUMENT80  => NULL, ARGUMENT81  => NULL, ARGUMENT82  => NULL,
          ARGUMENT83  => NULL, ARGUMENT84  => NULL, ARGUMENT85  => NULL,
          ARGUMENT86  => NULL, ARGUMENT87  => NULL, ARGUMENT88  => NULL,
          ARGUMENT89  => NULL, ARGUMENT90  => NULL, ARGUMENT91  => NULL,
          ARGUMENT92  => NULL, ARGUMENT93  => NULL, ARGUMENT94  => NULL,
          ARGUMENT95  => NULL, ARGUMENT96  => NULL, ARGUMENT97  => NULL,
          ARGUMENT98  => NULL, ARGUMENT99  => NULL, ARGUMENT100 => NULL);

      hr_utility.set_location(l_proc, 40);

      IF l_request_id > 0 THEN
         hr_utility.set_location(l_proc, 50);
         -- Commit the launch
         COMMIT;
      END IF;

      hr_utility.set_location('Leaving: '|| l_proc, 60);

   EXCEPTION

      WHEN OTHERS THEN
         hr_utility.set_location('Leaving: '|| l_proc, 70);
         hr_utility.set_location(SQLERRM, 75);
         writelog(SQLERRM,'N');

   END sync_single_org;

END hr_gl_sync_orgs;

/
