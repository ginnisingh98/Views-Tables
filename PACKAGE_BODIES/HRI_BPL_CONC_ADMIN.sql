--------------------------------------------------------
--  DDL for Package Body HRI_BPL_CONC_ADMIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_CONC_ADMIN" AS
/* $Header: hribcnca.pkb 120.5 2006/10/06 12:18:28 jtitmas noship $ */

/******************************************************************************/
/* Returns 'Yes' for full refresh if the table is empty, and 'No' otherwise   */
/******************************************************************************/
FUNCTION get_full_refresh_flag( p_table_name        IN VARCHAR2 )
                RETURN VARCHAR2 IS

  l_full_refresh_flag_code   VARCHAR2(30);

BEGIN

  l_full_refresh_flag_code := get_full_refresh_code(p_table_name);

  RETURN hr_bis.bis_decode_lookup('YES_NO', l_full_refresh_flag_code);

END get_full_refresh_flag;

/******************************************************************************/
/* Returns 'Y' for full refresh if the table is empty, and 'N' otherwise      */
/******************************************************************************/
FUNCTION get_full_refresh_code( p_table_name        IN VARCHAR2 )
                RETURN VARCHAR2 IS

  l_sql_stmt                 VARCHAR2(500);
  l_row_exists               NUMBER;
  l_full_refresh_flag_code   VARCHAR2(30);

BEGIN

  l_sql_stmt := 'SELECT count(*) FROM ' || p_table_name || ' WHERE rownum < 2';

  EXECUTE IMMEDIATE l_sql_stmt INTO l_row_exists;

  IF (l_row_exists > 0) THEN
    l_full_refresh_flag_code := 'N';
  ELSE
    l_full_refresh_flag_code := 'Y';
  END IF;

  RETURN l_full_refresh_flag_code;

END get_full_refresh_code;

--
-- -----------------------------------------------------------------------------
-- This procedure returns the full refresh parameter for the HRI Full Refresh --
-- Events Capture Process. If any of the base table for which the process     --
-- populates the events queue is not empty then return N else return Y        --
-- -----------------------------------------------------------------------------
--
FUNCTION get_events_full_refresh_flag
                RETURN VARCHAR2 IS
  --
  l_full_refresh_flag_code   VARCHAR2(30);
  --
  CURSOR c_events_full_refresh is
  SELECT DECODE(NVL(SUM(recs),0),0,'Y','N')
  FROM  (SELECT 1 recs
         FROM   hri_cs_suph
         WHERE  rownum = 1
         UNION ALL
         SELECT 1 recs
         FROM   hri_mb_asgn_events_ct
         WHERE rownum = 1
         UNION ALL
         SELECT 1 recs
	 FROM   hri_cl_wkr_sup_status_ct
         WHERE rownum = 1
         );
  --
BEGIN
  --
  OPEN  c_events_full_refresh;
  FETCH c_events_full_refresh into l_full_refresh_flag_code;
  CLOSE c_events_full_refresh;
  --
  RETURN hr_bis.bis_decode_lookup('YES_NO', l_full_refresh_flag_code);
  --
END get_events_full_refresh_flag;

--
-- -----------------------------------------------------------------------------
-- Returns HRI global start date
-- -----------------------------------------------------------------------------
--
FUNCTION get_hri_global_start_date
                RETURN DATE IS
  l_return_date   DATE;
BEGIN

  -- Trap profile format exception
  BEGIN
    l_return_date := to_date(fnd_profile.value
                              ('HRI_GLOBAL_START_DATE'), 'MM/DD/YYYY');
  EXCEPTION WHEN OTHERS THEN
    null;
  END;

  RETURN l_return_date;

END get_hri_global_start_date;


--
-- -----------------------------------------------------------------------------
-- Returns request set PK and linked DBI pages for currently
-- executing request set
-- -----------------------------------------------------------------------------
--
PROCEDURE get_request_set_details
   (p_request_set_id   OUT NOCOPY NUMBER,
    p_application_id   OUT NOCOPY NUMBER,
    p_refresh_mode     OUT NOCOPY VARCHAR2,
    p_page_list        OUT NOCOPY page_list_tab_type) IS

  CURSOR rsg_page_csr(v_request_id  NUMBER) IS
  SELECT
   rso.object_name
  ,rso.object_owner
  ,rso.object_type
  ,opt.option_value       refresh_mode
  ,rset.request_set_id
  ,rset.application_id
  FROM
   fnd_concurrent_requests  fcr
  ,fnd_request_sets_vl      rset
  ,bis_request_set_objects  rso
  ,bis_request_set_options  opt
  WHERE fcr.request_id = v_request_id
  AND rso.set_app_id = rset.application_id
  AND rso.request_set_name = rset.request_set_name
  AND rset.application_id = to_number(fcr.argument1)
  AND rset.request_set_id = to_number(fcr.argument2)
  AND opt.request_set_name = rso.request_set_name
  AND opt.set_app_id = rso.set_app_id
  AND opt.option_name = 'REFRESH_MODE';

  l_index              NUMBER := 0;
  l_master_request_id  NUMBER;
  l_empty_page_list    page_list_tab_type;

BEGIN

  -- Get request id for request set
  l_master_request_id := fnd_global.conc_priority_request;

  -- If request set id is provided, get the details
  IF (l_master_request_id IS NOT NULL) THEN

    -- Exception may be raised if:
    --   - Process is not run from a request set
    --   - Request set submission program changes
    BEGIN

      -- Loop through pages
      FOR page_rec IN rsg_page_csr(l_master_request_id) LOOP
        l_index := l_index + 1;
        p_page_list(l_index).page_owner := page_rec.object_owner;
        p_page_list(l_index).page_name  := page_rec.object_name;
        p_page_list(l_index).page_type  := page_rec.object_type;
        p_refresh_mode   := page_rec.refresh_mode;
        p_request_set_id := page_rec.request_set_id;
        p_application_id := page_rec.application_id;
      END LOOP;

    -- If anything goes wrong, return no details
    EXCEPTION WHEN OTHERS THEN
      p_refresh_mode   := null;
      p_request_set_id := to_number(null);
      p_application_id := to_number(null);
      p_page_list      := l_empty_page_list;
    END;

  END IF;

END get_request_set_details;

END hri_bpl_conc_admin;

/
