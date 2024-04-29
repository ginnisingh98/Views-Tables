--------------------------------------------------------
--  DDL for Package Body OKI_BUT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_BUT_PVT" as
/* $Header: OKIRBUTB.pls 115.10 2002/12/19 19:36:16 brrao noship $*/

--------------------------------------------------------------------------------
-- Modification History
-- 04-Jan-2002  mezra         Created
-- 20-Mar-2002  mezra         Added logic to retrieve title at contract level.
-- 27-Mar-2002  mezra         Added new procedure and functions to support
--                            scaling factor
-- 04-Apr-2002  mezra         Moved dbdrv command to top of file.
--                            Synched branch with mainline.
-- 26-NOV-2002 rpotnuru       NOCOPY Changes
-- 19-DEC-2002 brrao          UTF-8 Changes to Organization_name
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
  -- Function to get the refresh date.

--------------------------------------------------------------------------------
  FUNCTION get_rfh_date
  (   p_name IN VARCHAR2
  ) RETURN  VARCHAR2 IS

  -- Cursor declaration

  -- Cursor to get the refresh date
  CURSOR rfh_csr
  (   p_name IN VARCHAR2
  ) IS
  SELECT  INITCAP(RTRIM(TO_CHAR(rfh.program_update_date, 'MONTH')))
        , TO_CHAR(rfh.program_update_date,'DD, RRRR HH24:MI')
  FROM    oki_refreshs rfh
  WHERE   UPPER(rfh.object_name) = UPPER(p_name)
  ;

  l_month             VARCHAR2(40) := NULL ;
  l_time              VARCHAR2(40) := NULL ;
  l_datetime          VARCHAR2(80) := NULL ;

  l_message           VARCHAR2(50) := NULL ;

  l_object_refreshed  VARCHAR2(30) := NULL ;

  BEGIN
    -- Get name of the object that that has been refreshed
    l_object_refreshed := jtfb_dcf.get_parameter_value(p_name,'P_OBJECT_REFRESHED');

    OPEN rfh_csr( l_object_refreshed ) ;
    FETCH rfh_csr INTO l_month, l_time ;
    IF (rfh_csr%NOTFOUND) OR (l_month is NULL) THEN
      -- Get the standard message for no refresh date found
      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_GET_RFH_DATE_FAILURE');
    ELSE
      -- Refresh date found
      l_datetime := l_month  || ' '  || l_time ;

      -- Get the standard message for refresh date found
      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_GET_RFH_DATE_SUCCESS');

      fnd_message.set_token(  token => 'DATETIME'
                            , value => l_datetime);
    END IF;
    CLOSE rfh_csr ;

      l_message := fnd_message.get;

      return l_message ;


  EXCEPTION
    WHEN OTHERS THEN
      -- return the error number to the calling program;
      l_message := substr(sqlerrm, 1, (instr(sqlerrm, ':') - 1) ) ;
      return l_message ;

  END get_rfh_date ;

--------------------------------------------------------------------------------
  -- Function to get the period set name based on the user's profile.

--------------------------------------------------------------------------------
  FUNCTION get_period_set
  (   p_profile_value IN VARCHAR2
  ) RETURN  VARCHAR2 IS

  --Local variable declarion

  -- The default period set name from the user's profile.
  l_period_set_name   VARCHAR2(15) ;

  -- The message id when an error occurs
  l_message_id  VARCHAR2(40) := null ;

  BEGIN

    l_period_set_name := fnd_profile.value( 'OKI_DEFAULT_PERIOD_SET' ) ;

    return l_period_set_name ;

  EXCEPTION
    WHEN OTHERS THEN
      -- return the error number to the calling program;
      l_message_id := substr(sqlerrm, 1, (instr(sqlerrm, ':') - 1) ) ;
      return l_message_id ;

  END get_period_set ;

--------------------------------------------------------------------------------
  -- Function to get the period type based on the user's profile.

--------------------------------------------------------------------------------
  FUNCTION get_period_type
  (   p_profile_value IN VARCHAR2
  ) RETURN  VARCHAR2 IS

  --Local variable declarion

  -- The default period type from the user's profile.
  l_period_type   VARCHAR2(15) ;

  -- The message id when an error occurs
  l_message_id  VARCHAR2(40) := null ;

  BEGIN

    l_period_type := fnd_profile.value( 'OKI_DEFAULT_PERIOD_TYPE' ) ;

    return l_period_type ;

  EXCEPTION
    WHEN OTHERS THEN
      -- return the error number to the calling program;
      l_message_id := substr(sqlerrm, 1, (instr(sqlerrm, ':') - 1) ) ;
      return l_message_id ;

  END get_period_type ;


--------------------------------------------------------------------------------
  -- Function to get the default the period name based on the user's profile:
  -- period set and period type

--------------------------------------------------------------------------------
  FUNCTION get_period_name
  (   p_profile_value IN VARCHAR2
  ) RETURN VARCHAR2 IS

  --Local variable declarion

  -- The default period type from the user's profile.
  l_period_type   VARCHAR2(15) ;

  -- The default period set name from the user's profile.
  l_period_set_name   VARCHAR2(15) ;


  l_period_name       VARCHAR2(15) ;

  -- Use sysdate as the default date
  l_default_date      DATE := TRUNC(sysdate) ;

  -- The message id when an error occurs
  l_message_id  VARCHAR2(40) := null ;

  -- Cursor declaration

  -- Cursor to get the period name based on the user's profile:
  -- period set name, period type
  CURSOR l_period_name_csr
  (   p_period_set_name IN  VARCHAR2
    , p_period_type     IN  VARCHAR2
    , p_default_date    IN  DATE
  ) IS
    SELECT glpr.period_name period_name
    FROM   gl_periods glpr
    WHERE  p_period_set_name = glpr.period_set_name
    AND    p_period_type     = glpr.period_type
    AND    glpr.adjustment_period_flag = 'N'
    AND    p_default_date    BETWEEN TRUNC(glpr.start_date)
                                 AND TRUNC(glpr.end_date)
    ;
  rec_l_period_name_csr l_period_name_csr%ROWTYPE ;

  BEGIN

    l_period_set_name := oki_but_pvt.get_period_set(NULL)  ;
    l_period_type     := oki_but_pvt.get_period_type(NULL) ;

    OPEN l_period_name_csr ( l_period_set_name, l_period_type,
         l_default_date ) ;
    FETCH l_period_name_csr INTO rec_l_period_name_csr ;
      IF l_period_name_csr%NOTFOUND THEN
        RAISE NO_DATA_FOUND ;
      ELSE
        l_period_name := rec_l_period_name_csr.period_name ;
      END IF ;
    CLOSE l_period_name_csr ;

    return l_period_name ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- return the error number to the calling program;
      l_message_id := substr(sqlerrm, 1, (instr(sqlerrm, ':') - 1) ) ;
      return l_message_id ;

    WHEN OTHERS THEN
      -- return the error number to the calling program;
      l_message_id := substr(sqlerrm, 1, (instr(sqlerrm, ':') - 1) ) ;
      return l_message_id ;

  END get_period_name ;

--------------------------------------------------------------------------------
  -- Function that returns the column labels for the renewal aging report
--------------------------------------------------------------------------------

  FUNCTION get_aging_label(p_col_pos IN VARCHAR2) return varchar2 IS

  -- Local variable declaration
  l_retval          VARCHAR2(60) := NULL ;
  l_aging_range     NUMBER       := NULL ;
  l_start_age_group VARCHAR2(10) := NULL ;
  l_end_age_group   VARCHAR2(10) := NULL ;
  l_separator       varchar2(1)  := '-'  ;

  l_label_postfix   CONSTANT VARCHAR2(5) := 'Days' ;

  BEGIN
    l_aging_range := to_number(fnd_profile.value('OKI_AGING_RANGE')) ;

    -- In cases where the aging range is not defined, return a
    -- generic column label
    IF (p_col_pos IS NULL) or (l_aging_range IS NULL) THEN
      l_retval := 'Age Group' ;
      return l_retval ;
    END IF ;

    IF p_col_pos = '1' THEN
      l_start_age_group := '0' ;
      l_end_age_group   := to_char(l_start_age_group + l_aging_range) ;
    ELSIF p_col_pos = '2' THEN
      l_start_age_group := to_char(l_aging_range + 1) ;
      l_end_age_group   := to_char(l_aging_range * 2)  ;
    ELSIF p_col_pos = '3' THEN
      l_start_age_group := to_char((l_aging_range * 2) + 1) ;
      l_end_age_group   := to_char(l_aging_range  * 3) ;
    ELSIF p_col_pos = '4' THEN
      l_start_age_group := to_char((l_aging_range * 3) + 1) ;
      l_separator       := '+' ;
    END IF ;

    l_retval := l_start_age_group || l_separator || l_end_age_group ||
                ' ' || l_label_postfix ;
    return l_retval ;

  END get_aging_label ;


--------------------------------------------------------------------------------
  -- Function that returns the column labels for the first column of the
  -- renewal aging report
--------------------------------------------------------------------------------
  FUNCTION get_aging_label1(p_col_pos IN VARCHAR2) return varchar2 IS

  -- Indicates it's the first column
  l_col_pos CONSTANT VARCHAR2(1)  := 1 ;
  l_retval           VARCHAR2(60) := NULL ;

    -- The message id when an error occurs
  l_message_id       VARCHAR2(40) := null ;


  BEGIN
    -- Retrieve the column label for the first column
    l_retval := oki_but_pvt.get_aging_label( p_col_pos => l_col_pos ) ;

    return l_retval ;

  EXCEPTION
    WHEN OTHERS THEN
      -- return the error number to the calling program;
      l_message_id := substr(sqlerrm, 1, (instr(sqlerrm, ':') - 1) ) ;
      return l_message_id ;

  END get_aging_label1 ;


--------------------------------------------------------------------------------
-- Function that returns the column labels for the second column of the
-- renewal aging report
--------------------------------------------------------------------------------
  FUNCTION get_aging_label2(p_col_pos IN VARCHAR2) return varchar2 IS

  -- Indicates it's the second column
  l_col_pos CONSTANT VARCHAR2(1)  := 2 ;
  l_retval           VARCHAR2(60) := NULL ;

    -- The message id when an error occurs
  l_message_id       VARCHAR2(40) := null ;


  BEGIN
    -- Retrieve the column label for the second column
    l_retval := oki_but_pvt.get_aging_label( p_col_pos => l_col_pos ) ;

    return l_retval ;

  EXCEPTION
    WHEN OTHERS THEN
      -- return the error number to the calling program;
      l_message_id := substr(sqlerrm, 1, (instr(sqlerrm, ':') - 1) ) ;
      return l_message_id ;

  END get_aging_label2 ;

--------------------------------------------------------------------------------
-- Function that returns the column labels for the third column of the
-- renewal aging report
--------------------------------------------------------------------------------
  FUNCTION get_aging_label3(p_col_pos IN VARCHAR2) return varchar2 IS

  -- Indicates it's the third column
  l_col_pos CONSTANT VARCHAR2(1)  := 3 ;
  l_retval           VARCHAR2(60) := NULL ;

    -- The message id when an error occurs
  l_message_id       VARCHAR2(40) := null ;


  BEGIN
    -- Retrieve the column label for the third column
    l_retval := oki_but_pvt.get_aging_label( p_col_pos => l_col_pos ) ;

    return l_retval ;

  EXCEPTION
    WHEN OTHERS THEN
      -- return the error number to the calling program;
      l_message_id := substr(sqlerrm, 1, (instr(sqlerrm, ':') - 1) ) ;
      return l_message_id ;

  END get_aging_label3 ;

--------------------------------------------------------------------------------
-- Function that returns the column labels for the fourth column of the
-- renewal aging report
--------------------------------------------------------------------------------
  FUNCTION get_aging_label4(p_col_pos IN VARCHAR2) return varchar2 IS

  -- Indicates it's the fourth column
  l_col_pos CONSTANT VARCHAR2(1)  := 4 ;
  l_retval           VARCHAR2(60) := NULL ;

    -- The message id when an error occurs
  l_message_id       VARCHAR2(40) := null ;


  BEGIN
    -- Retrieve the column label for the fourth column
    l_retval := oki_but_pvt.get_aging_label( p_col_pos => l_col_pos ) ;

    return l_retval ;

  EXCEPTION
    WHEN OTHERS THEN
      -- return the error number to the calling program;
      l_message_id := substr(sqlerrm, 1, (instr(sqlerrm, ':') - 1) ) ;
      return l_message_id ;

  END get_aging_label4 ;

--------------------------------------------------------------------------------
  -- Function that returns the either the start age age value or the end age
  -- value of the age group.
--------------------------------------------------------------------------------
  FUNCTION get_start_end_age_val
  (  p_start_end_pos IN VARCHAR2
   , p_col_pos       IN VARCHAR2
  ) return varchar2 IS

    l_age_value       VARCHAR2(10) := NULL ;
    l_aging_range     NUMBER       := NULL ;
  BEGIN
    l_aging_range := to_number(fnd_profile.value('OKI_AGING_RANGE')) ;

    IF p_start_end_pos = 'START' THEN
      -- Calculate the start age of the aging group
      IF p_col_pos = '1' THEN
        l_age_value := 0 ;
      ELSIF p_col_pos = '2' THEN
        l_age_value :=  to_char(l_aging_range + 1) ;
      ELSIF p_col_pos = '3' THEN
        l_age_value := to_char((l_aging_range * 2) + 1) ;
      ELSIF p_col_pos = '4' THEN
        l_age_value := to_char((l_aging_range * 3) + 1) ;
      END IF ;

    ELSIF p_start_end_pos = 'END' THEN
      -- Calculate the end age of the aging group
      IF p_col_pos = '1' THEN
        l_age_value := to_char(l_aging_range) ;
      ELSIF p_col_pos = '2' THEN
        l_age_value := to_char(l_aging_range * 2)  ;
      ELSIF p_col_pos = '3' THEN
        l_age_value := to_char(l_aging_range  * 3) ;
      END IF;
    END IF ;

    return l_age_value ;
  END get_start_end_age_val ;

--------------------------------------------------------------------------------
  -- Function that returns the title for a bin.
--------------------------------------------------------------------------------
  FUNCTION get_bin_title
  (  p_grouping   IN VARCHAR2
   , p_bin_name   IN VARCHAR2
   , p_code       IN VARCHAR2
  ) return varchar2 IS

  l_prefix    VARCHAR2(30)  := NULL ;
  l_postfix   VARCHAR2(30)  := NULL ;
  l_separator vARCHAR2(5)   := NULL ;
  l_title     VARCHAR2(100) := NULL ;
  BEGIN
    IF p_grouping = 'Aging' THEN
      IF p_bin_name IN ('OKI_RAG_ORG_AG1_RPT', 'OKI_RAG_ORG_AG2_RPT',
                        'OKI_RAG_ORG_AG3_RPT', 'OKI_RAG_ORG_AG4_RPT') THEN
        l_prefix    := 'Renewal Aging' ;
        l_separator := ' - ' ;
        l_postfix   := oki_but_pvt.get_aging_label(p_code) ;
      END IF ;
    END IF ;


    l_title := l_prefix || l_separator || l_postfix ;
    return l_title ;

  END get_bin_title ;
--------------------------------------------------------------------------------
  -- Function that returns the title for a bin.
--------------------------------------------------------------------------------
  FUNCTION get_bin_title2
  (  p_param IN VARCHAR2
  ) RETURN VARCHAR2 IS

  l_context     VARCHAR2(1000);
  l_code        VARCHAR2(30) ;
  l_title_value VARCHAR2(60);

  BEGIN
    l_context := jtfb_dcf.get_parameter_value( p_param, 'pContext') ;
    l_code := substr(l_context, (instr(l_context, ':', 1, 1 ) + 1 ),
        ((instr(l_context, ':', 1, 2 )) - (instr(l_context, ':', 1, 1 ) + 1 ))) ;
    IF l_code = 'BACTK' THEN
      l_title_value := 'Beginning active contracts by organization ' ;
    ELSIF l_code = 'EXPINQTR' THEN
      l_title_value := 'Expiring during quarter by organization ' ;
    ELSIF l_code = 'BKLGKRNW' THEN
      l_title_value := 'Backlog contracts renewed by organization ' ;
    ELSIF l_code = 'KRNW' THEN
      l_title_value := 'Quarter contracts renewed by organization ' ;
    ELSIF l_code = 'NEWBUS' THEN
      l_title_value := 'New business by organization' ;
    ELSIF l_code = 'TRMNK' THEN
      l_title_value := 'Terminated contracts by organization' ;
    END IF ;

    return l_title_value ;

  END get_bin_title2 ;

--------------------------------------------------------------------------------
  -- Function that returns the title for contracts bin.
--------------------------------------------------------------------------------
  FUNCTION get_top_n_k_title
  (  p_param IN VARCHAR2
  ) RETURN VARCHAR2 IS

  l_context     VARCHAR2(1000);
  l_code        VARCHAR2(30) ;
  l_title_value VARCHAR2(200) ;
  l_prefix      VARCHAR2(60) := 'Top 10 ' ;
  l_org_id      VARCHAR2(40) ;
  l_org_name    VARCHAR2(240) := NULL ;

  CURSOR l_get_org_name_csr
  ( p_org_id IN NUMBER
  ) IS
    SELECT oru.name
    FROM hr_all_organization_units oru
    WHERE oru.organization_id = p_org_id
    ;
  rec_l_get_org_name_csr l_get_org_name_csr%ROWTYPE ;

  BEGIN
    l_context := jtfb_dcf.get_parameter_value( p_param, 'pContext') ;

    l_code := substr(l_context, (instr(l_context, ':', 1, 1 ) + 1 ),
             ((instr(l_context, ':', 1, 2 )) - (instr(l_context, ':', 1, 1 ) + 1 ))) ;
    l_org_id := substr(l_context, (instr(l_context, ':', 1, 3 ) + 1 )) ;

    OPEN l_get_org_name_csr( TO_NUMBER(l_org_id) ) ;
    FETCH l_get_org_name_csr INTO rec_l_get_org_name_csr ;
      l_org_name := rec_l_get_org_name_csr.name ;
    CLOSE l_get_org_name_csr ;

    IF l_code = 'BACTK' THEN
      l_title_value := l_prefix || 'beginning active contracts: ' || l_org_name ;
    ELSIF l_code = 'EXPINQTR' THEN
      l_title_value := l_prefix || 'expiring during quarter: ' || l_org_name ;
    ELSIF l_code = 'BKLGKRNW' THEN
      l_title_value := l_prefix || 'backlog contracts renewed: ' || l_org_name ;
    ELSIF l_code = 'KRNW' THEN
      l_title_value := l_prefix || 'quarter contracts renewed: ' || l_org_name ;
    ELSIF l_code = 'NEWBUS' THEN
      l_title_value := l_prefix || 'new business: ' || l_org_name ;
    ELSIF l_code = 'TRMNK' THEN
      l_title_value := l_prefix || 'terminated contracts: ' || l_org_name ;
    ELSIF l_code = 'TACTK' THEN
      l_title_value := l_prefix || 'total active contracts: ' || l_org_name ;
    END IF ;

    return l_title_value ;

  END get_top_n_k_title ;
--------------------------------------------------------------------------------
  -- Function that returns the title for the bin.
  --
--------------------------------------------------------------------------------
  FUNCTION get_title_for_bin
  (  p_param IN VARCHAR2
  ) RETURN VARCHAR2 IS

  l_bin_name     VARCHAR2(1000) ;
  l_param1       VARCHAR2(1000) ;
  l_title        VARCHAR2(200) := NULL ;
  l_title_prefix VARCHAR2(100) := NULL ;
  l_title_suffix VARCHAR2(100) := NULL ;
  l_title_var1    VARCHAR2(100) := NULL ;

  BEGIN
    l_bin_name := jtfb_dcf.get_parameter_value(p_param, 'P_BIN_NAME') ;
    l_param1   := jtfb_dcf.get_parameter_value(p_param, 'P_SCALING_FACTOR') ;
    IF l_bin_name = 'OKI_EXPIRATION_GRAPH' THEN
      -- set up for expiration graph title
      l_title_prefix := 'Expiration to Renewal Graph' ;
      IF l_param1 = 1000 THEN
        l_title_var1 := '(in thousands)' ;
      ELSIF l_param1  = 10000 THEN
        l_title_var1 := '(in tens thousands)' ;
      ELSIF l_param1  = 100000 THEN
        l_title_var1 := '(in hundred thousands)' ;
      ELSIF l_param1  = 1000000 THEN
        l_title_var1 := '(in millions)' ;
      ELSIF l_param1  = 10000000 THEN
        l_title_var1 := '(in ten millions)' ;
      ELSIF l_param1  = 100000000 THEN
        l_title_var1 := '(in hundred millions)' ;
      END IF ;
      l_title := l_title_prefix || ' ' || l_title_var1 ||
                                   ' ' || l_title_suffix ;
    END IF ;
    return l_title ;
  END get_title_for_bin ;

--------------------------------------------------------------------------------
-- Function to return the scaling factor
--
--------------------------------------------------------------------------------
  FUNCTION get_scaling_factor RETURN VARCHAR2 IS
  BEGIN
    return g_scaling_factor ;
  END get_scaling_factor ;

--------------------------------------------------------------------------------
-- Function to retrieve the scaling factor from the bin parameter
--
--------------------------------------------------------------------------------
  PROCEDURE set_scaling_factor
  ( p_param IN VARCHAR2
   ) IS
    l_message            VARCHAR2(50) := NULL ;
  BEGIN
    g_scaling_factor := jtfb_dcf.get_parameter_value(p_param, 'P_SCALING_FACTOR') ;
  END set_scaling_factor ;
--------------------------------------------------------------------------------
  -- Function to get the default value for the build summary date.

--------------------------------------------------------------------------------
  FUNCTION dflt_summary_build_date
  (   p_name IN VARCHAR2
  ) RETURN  VARCHAR2 IS


  l_summary_build_date VARCHAR2(60) := NULL ;

  l_message            VARCHAR2(50) := NULL ;


  BEGIN
    l_summary_build_date := TO_CHAR(TRUNC(sysdate - 1),
                               fnd_profile.value('ICX_DATE_FORMAT_MASK')) ;
    return l_summary_build_date ;


  EXCEPTION
    WHEN OTHERS THEN
      -- return the error number to the calling program;
      l_message := substr(sqlerrm, 1, (instr(sqlerrm, ':') - 1) ) ;
      return l_message ;

  END dflt_summary_build_date ;


END oki_but_pvt ;

/
