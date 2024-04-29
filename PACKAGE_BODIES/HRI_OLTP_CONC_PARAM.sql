--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_CONC_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_CONC_PARAM" AS
/* $Header: hriocprm.pkb 120.2 2005/11/11 03:06:10 jtitmas noship $ */

-- Sets the full refresh value for a concurrent process
FUNCTION get_full_refresh_value(p_process_table_name    IN VARCHAR2)
          RETURN VARCHAR2 IS

  l_page_list        hri_bpl_conc_admin.page_list_tab_type;
  l_refresh_mode     VARCHAR2(240);
  l_request_set_id   NUMBER;
  l_application_id   NUMBER;
  l_full_refresh     VARCHAR2(30);
  l_table_is_empty   VARCHAR2(30);

BEGIN

  -- Get request set information
  hri_bpl_conc_admin.get_request_set_details
   (p_request_set_id => l_request_set_id,
    p_application_id => l_application_id,
    p_refresh_mode   => l_refresh_mode,
    p_page_list      => l_page_list);

  -- If request set is incremental then do not full refresh
  IF (l_refresh_mode = 'INCR') THEN

    l_full_refresh := 'N';

  -- Otherwise check:
  --    1) Profile options - force full refresh / force shared HR
  --    2) Whether table has data
  --    3) Whether table is "owned" by a page in the request set
  ELSE

    -- If force full refresh profile is set
    -- or shared hr mode is detected
    -- return full refresh
    IF (fnd_profile.value('HRI_DBI_FORCE_FULL_REFRESH') = 'Y' OR
        hr_general.chk_product_installed(800) = 'FALSE' OR
        fnd_profile.value('HRI_DBI_FORCE_SHARED_HR') = 'Y') THEN

      l_full_refresh := 'Y';

    ELSE

      -- Check whether the table is empty
      l_table_is_empty := hri_bpl_conc_admin.get_full_refresh_code
                           (p_table_name => p_process_table_name);

      -- If the table is empty then full refresh
      IF (l_table_is_empty = 'Y') THEN

        l_full_refresh := 'Y';

      ELSE

        -- If the table is owned by a DBI page associated with the request set
        -- then full refresh otherwise incremental
        IF (hri_mtdt_conc_request.is_table_owned_by_page
             (p_page_list  => l_page_list,
              p_table_name => p_process_table_name) = 'N') THEN
          l_full_refresh := 'N';
        ELSE
          l_full_refresh := 'Y';
        END IF;

      END IF; -- Table is empty

    END IF; -- Profile options

  END IF; -- Refresh mode

  RETURN l_full_refresh;

END get_full_refresh_value;

-- Sets the refresh from date for a concurrent process
FUNCTION get_full_refresh_from_value(p_process_table_name    IN VARCHAR2)
          RETURN VARCHAR2 IS

  l_hri_start_date   DATE;
  l_dbi_start_date   DATE;

BEGIN

  -- Check the DBI start date
  l_dbi_start_date := hri_bpl_parameter.get_bis_global_start_date;

  -- If the program is also a non-dbi process check the HRI start date
  IF (hri_mtdt_conc_request.is_core_hri_process
       (p_table_name => p_process_table_name) = 'Y') THEN

    l_hri_start_date := hri_bpl_conc_admin.get_hri_global_start_date;

    -- Pick the earlier date
    IF (l_hri_start_date < l_dbi_start_date) THEN
      l_dbi_start_date := l_hri_start_date;
    END IF;

  END IF;

  -- Return the date as a string
  RETURN fnd_date.date_to_canonical(l_dbi_start_date);

END get_full_refresh_from_value;

-- Generic function to return a parameter value
FUNCTION get_parameter_value(p_parameter_name      IN VARCHAR2,
                             p_process_table_name  IN VARCHAR2)
          RETURN VARCHAR2 IS

  l_parameter_value  VARCHAR2(240);

BEGIN

  -- Call appropriate subfunction
  IF (p_parameter_name = 'FULL_REFRESH') THEN
    l_parameter_value := get_full_refresh_value
                          (p_process_table_name => p_process_table_name);
  ELSIF (p_parameter_name = 'FULL_REFRESH_FROM_DATE') THEN
    l_parameter_value := get_full_refresh_from_value
                          (p_process_table_name => p_process_table_name);
  END IF;

  RETURN l_parameter_value;

END get_parameter_value;

-- Generic function to return a parameter value
FUNCTION get_date_parameter_value(p_parameter_name      IN VARCHAR2,
                                  p_process_table_name  IN VARCHAR2)
          RETURN DATE IS

  l_date_string   VARCHAR2(240);

BEGIN

  l_date_string := get_parameter_value
                    (p_parameter_name => p_parameter_name,
                     p_process_table_name => p_process_table_name);

  RETURN fnd_date.canonical_to_date(l_date_string);

END get_date_parameter_value;

END hri_oltp_conc_param;

/
