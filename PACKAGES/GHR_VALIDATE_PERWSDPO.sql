--------------------------------------------------------
--  DDL for Package GHR_VALIDATE_PERWSDPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_VALIDATE_PERWSDPO" AUTHID CURRENT_USER AS
/* $Header: ghrwsdpo.pkh 120.1 2006/08/30 11:53:30 arbasu noship $ */

  g_bypass_vert boolean :=false;                  -- Global Vertical Status
  g_package       constant varchar2(33) := '  ghr_validate_perwsdpo.';

  procedure update_posn_status (p_position_id in number,
                                p_effective_date in date );

  procedure validate_perwsdpo (p_position_id in number,
                               p_effective_date in date);

  function chk_position_obligated (p_position_id in number
                                  ,p_date        in date)
    return boolean;

  function chk_par_exists (p_position_id in number) return boolean;
    pragma restrict_references (chk_par_exists, WNDS);

--  Bug 3501968: Added below, function chk_par_exists_f_per.
-- This functions returns if a given has atleast one PA request record.
  function chk_par_exists_f_per (p_person_id in number) return boolean;

-- ---------------------------------------------------------------------------
-- ---------------------------< Function: return_upd_hr_vert_status >-------------
-- ---------------------------------------------------------------------------
  function return_upd_hr_vert_status return boolean;

-- ---------------------------------------------------------------------------
-- ---------------------------< Function: chk_location_assigned >-------------
-- ---------------------------------------------------------------------------
  function chk_location_assigned (p_location_id in number) return boolean;
    pragma restrict_references (chk_location_assigned , WNDS);

-- ---------------------------------------------------------------------------
-- ---------------------------< Function: chk_postion_assigned >--------------
-- ---------------------------------------------------------------------------
  function chk_position_assigned (p_position_id in number) return boolean;
    pragma restrict_references (chk_position_assigned , WNDS);

-- ---------------------------------------------------------------------------
-- ---------------------------< Function: chk_postion_assigned_date >--------------
-- ---------------------------------------------------------------------------
  function chk_position_assigned_date (p_position_id in number
                                      ,p_date        in date)
    return boolean;
    pragma restrict_references (chk_position_assigned , WNDS);

-- ---------------------------------------------------------------------------
-- ---------------------------< Function: chk_position_assigned_other >--------------
-- ---------------------------------------------------------------------------
  function chk_position_assigned_other (p_position_id in number
                                       ,p_assignment_id in number
                                       ,p_date        in date)
    return boolean;
    pragma restrict_references (chk_position_assigned , WNDS);

-- ---------------------------------------------------------------------------
-- ---------------------------< Function: chk_position_assigned_cwk >--------------
-- ---------------------------------------------------------------------------
  function chk_position_assigned_cwk  (p_position_id in number
                                       ,p_date        in date)
    return boolean;
    pragma restrict_references (chk_position_assigned , WNDS);



  -- This function checks if there are any future PA Request actions for a given position
  -- that have been completed.
  FUNCTION check_pend_future_pars (p_position_id    IN NUMBER
                                  ,p_effective_date IN DATE)
  RETURN VARCHAR2;

  -- Bug#2458573
  -- This function checks if the element is created through RPA or through element entry screen
  -- If the element is created through RPA, function returns TRUE; Otherwise it returns FALSE.
  FUNCTION is_rpa_element(p_element_entry_id IN NUMBER)
  RETURN BOOLEAN;

-- --------------------------------------------------------------------------
-- ---------------------------< Function: chk_future_assigned >--------------
-- --------------------------------------------------------------------------
  function chk_future_assigned (p_position_id in number
                               ,p_date        in date)
  return boolean;

-- --------------------------------------------------------------------------
-- ---------------------------< Function: chk_rpa_sourced_next>--------------
-- --------------------------------------------------------------------------
  Function chk_rpa_sourced_next(p_position_id         in number
                               ,p_effective_end_date      in date)

  return boolean;

-- --------------------------------------------------------------------------
-- ---------------------------< Function: chk_rpa_sourced_all>--------------
-- --------------------------------------------------------------------------
  Function chk_rpa_sourced_all(p_position_id         in number
                              ,p_effective_end_date      in date)

  return boolean;

-- --------------------------------------------------------------------------
-- ------------------------ < Function: get_position_eff_date>---------------
-- --------------------------------------------------------------------------
  Function get_position_eff_date(p_position_id         in number)
  return date;

end ghr_validate_perwsdpo;


/
