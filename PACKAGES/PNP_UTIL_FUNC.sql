--------------------------------------------------------
--  DDL for Package PNP_UTIL_FUNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNP_UTIL_FUNC" AUTHID CURRENT_USER AS
  -- $Header: PNPFUNCS.pls 120.9 2007/04/19 09:50:45 sdmahesh ship $


  -- Global Variable for use by
  -- SET_VIEW_CONTEXT (procedure)  and  GET_VIEW_CONTEXT (function)

  g_view_context             VARCHAR2(2) DEFAULT NULL;
  g_start_of_time            DATE := TO_DATE('01-01-0001','DD-MM-YYYY');
  g_end_of_time              DATE := TO_DATE('31-12-4712','DD-MM-YYYY');
  g_as_of_date               DATE := SYSDATE;
  g_retro_enabled            BOOLEAN := FALSE;
  g_mini_retro_enabled       BOOLEAN := TRUE;
  g_as_of_date_4_loc_pubview DATE := NULL;
  g_as_of_date_4_emp_pubview DATE := NULL;

  TYPE emp_hr_data_rec IS RECORD (
          person_id                     PER_ALL_PEOPLE_F.person_id%TYPE,
          effective_start_date          PER_ALL_PEOPLE_F.effective_start_date%TYPE,
          effective_end_date            PER_ALL_PEOPLE_F.effective_end_date%TYPE,
          assignment_id                 PER_ALL_ASSIGNMENTS_F.assignment_id%TYPE,
          last_name                     PER_ALL_PEOPLE_F.last_name%TYPE,
          employee_number               PER_ALL_PEOPLE_F.employee_number%TYPE,
          email_address                 PER_ALL_PEOPLE_F.email_address%TYPE,
          first_name                    PER_ALL_PEOPLE_F.first_name%TYPE,
          full_name                     PER_ALL_PEOPLE_F.full_name%TYPE,
          person_type_id                PER_ALL_PEOPLE_F.person_type_id%TYPE,
          employee_type                 PER_PERSON_TYPES_tl.user_person_type%TYPE,
          phone_number                  PER_PHONES.phone_number%TYPE,
          position_id                   PER_ALL_ASSIGNMENTS_F.position_id%TYPE,
          position                      VARCHAR2(2000),
          job_id                        PER_ALL_ASSIGNMENTS_F.job_id%TYPE,
          job                           PER_JOBS.name%TYPE,
          organization_id               PER_ALL_ASSIGNMENTS_F.organization_id%TYPE,
          organization                  HR_ORGANIZATION_UNITS.name%TYPE,
          employment_category           PER_ALL_ASSIGNMENTS_F.employment_category%TYPE,
          employment_category_meaning   FND_COMMON_LOOKUPS.meaning%TYPE
          );

  TYPE emp_pr_data_rec IS RECORD (
          segment1                      PA_PROJECTS.segment1%TYPE,
          name                          HR_ORGANIZATION_UNITS.name%TYPE
          );

  TYPE emp_tr_data_rec IS RECORD (
          task_name                     PA_TASKS.task_name%TYPE
          );

  TYPE location_name_rec IS RECORD (
          office_location_code          PN_LOCATIONS.location_code%TYPE,
          office                        PN_LOCATIONS.office%TYPE,
          floor_location_code           PN_LOCATIONS.location_code%TYPE,
          floor                         PN_LOCATIONS.floor%TYPE,
          building_location_code        PN_LOCATIONS.location_code%TYPE,
          building                      PN_LOCATIONS.building%TYPE,
          property_code                 PN_PROPERTIES.property_code%TYPE,
          property_name                 PN_PROPERTIES.property_name%TYPE,
          office_park_name              PN_LOCATION_PARKS.name%TYPE,
          region_name                   PN_LOCATION_PARKS.name%TYPE
          );

  TYPE currency_table_type IS TABLE OF pn_currencies%ROWTYPE
     INDEX BY BINARY_INTEGER;

  TYPE num_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  /* table to create virtual schedule bug # 4229248 */
  TYPE virtual_sched_rec IS RECORD(
     start_date     DATE,
     end_date       DATE,
     schedule_date  DATE);

  TYPE virtual_sched_tbl_type IS TABLE OF virtual_sched_rec INDEX BY BINARY_INTEGER;

  TYPE item_end_dt_rec IS RECORD (term_id          pn_payment_terms_all.payment_term_id%TYPE,
                                  item_end_dt      DATE,
                                  index_period_id  pn_payment_terms_all.index_period_id%TYPE);

  TYPE item_end_dt_tbl_type IS TABLE OF item_end_dt_rec INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------

  currencies_table currency_table_type;

-------------------------------------------------------------------------------


  TYPE space_assignment_rec IS RECORD (

          location_id                   PN_LOCATIONS_ALL.location_id%type,
          assignment_id                 PN_SPACE_ASSIGN_CUST_ALL.cust_space_assign_id%type,
          assign_start_date             PN_SPACE_ASSIGN_CUST_ALL.cust_assign_start_date%type,
          assign_end_date               PN_SPACE_ASSIGN_CUST_ALL.cust_assign_start_date%type,
          allocated_area_pct            PN_SPACE_ASSIGN_CUST_ALL.allocated_area_pct%type,
          allocated_area                PN_SPACE_ASSIGN_CUST_ALL.allocated_area%type,
          utilized_area                 PN_SPACE_ASSIGN_CUST_ALL.utilized_area%type,
          project_id                    PN_SPACE_ASSIGN_CUST_ALL.project_id%type,
          task_id                       PN_SPACE_ASSIGN_CUST_ALL.task_id%type,
          person_id                     PN_SPACE_ASSIGN_EMP_ALL.person_id%type,
          cust_account_id               PN_SPACE_ASSIGN_CUST_ALL.cust_account_id%type,
          org_id                        PN_SPACE_ASSIGN_CUST_ALL.org_id%type,
          lease_id                      PN_SPACE_ASSIGN_CUST_ALL.lease_id%type
          );


  TYPE space_assignment_tbl IS TABLE OF space_assignment_rec INDEX BY BINARY_INTEGER;

  FUNCTION validate_lease_terminate_date (p_lease_id IN NUMBER,
                                          p_termination_date IN DATE)
  RETURN BOOLEAN;

  FUNCTION min_lease_terminate_date (p_lease_id IN NUMBER) RETURN DATE;

  FUNCTION item_end_date (p_term_id IN NUMBER,p_freq_code IN VARCHAR) RETURN DATE;

  FUNCTION fetch_item_end_dates( p_lease_id NUMBER)
  RETURN pnp_util_func.item_end_dt_tbl_type;

  FUNCTION norm_trm_exsts (p_lease_id IN NUMBER) RETURN BOOLEAN;

  FUNCTION get_total_payment_item_amt (
                                        p_status IN VARCHAR2,
                                        p_curr_code IN VARCHAR2,
                                        p_payment_schedule_id IN NUMBER,
                                        p_called_from         IN VARCHAR2 DEFAULT 'PNTAUPMT'

                                      ) RETURN NUMBER;

-------------------------------------------------------------------------------

  FUNCTION get_total_payment_term_amt (
                                        p_paymentTermId IN NUMBER
                                      ) RETURN NUMBER;


-------------------------------------------------------------------------------

  FUNCTION get_concatenated_address (
                                      address_style        IN VARCHAR2,
                                      address_line1        IN VARCHAR2,
                                      address_line2        IN VARCHAR2,
                                      address_line3        IN VARCHAR2,
                                      address_line4        IN VARCHAR2,
                                      city                 IN VARCHAR2,
                                      county               IN VARCHAR2,
                                      state                IN VARCHAR2,
                                      province             IN VARCHAR2,
                                      zip_code             IN VARCHAR2,
                                      territory_short_name IN VARCHAR2
                                     )RETURN VARCHAR2;


-------------------------------------------------------------------------------

  FUNCTION get_vacant_area ( p_location_id  IN  NUMBER,
                             p_As_Of_Date   IN  DATE default NULL ) RETURN NUMBER;

-------------------------------------------------------------------------------

  FUNCTION get_vacant_area_percent ( p_location_id  IN  NUMBER,
                                     p_As_Of_Date   IN  DATE default NULL  ) RETURN NUMBER;

-------------------------------------------------------------------------------

  FUNCTION get_load_factor ( p_location_id  IN  NUMBER ,
                             p_As_Of_Date   IN  DATE default NULL  ) RETURN NUMBER;

-------------------------------------------------------------------------------

  FUNCTION get_floors ( p_location_id  IN  NUMBER ,
                        p_as_of_date   IN  DATE DEFAULT NULL) RETURN NUMBER;

-------------------------------------------------------------------------------

  FUNCTION get_offices ( p_location_id  IN  NUMBER ,
                        p_as_of_date   IN  DATE DEFAULT NULL) RETURN NUMBER;

-------------------------------------------------------------------------------

  FUNCTION get_utilized_capacity ( p_location_id  IN  NUMBER,
                                   p_as_Of_Date   IN  DATE default NULL
                                  ) RETURN NUMBER;

-------------------------------------------------------------------------------

  FUNCTION get_vacancy ( p_location_id  IN  NUMBER ,
                         p_as_of_Date   IN  DATE default NULL ) RETURN NUMBER;

-------------------------------------------------------------------------------

  FUNCTION get_occupancy_percent ( p_location_id  IN  NUMBER ,
                         p_as_of_Date   IN  DATE default NULL ) RETURN NUMBER;

-------------------------------------------------------------------------------

  FUNCTION get_area_utilized ( p_location_id  IN  NUMBER ,
                         p_as_of_Date   IN  DATE default NULL ) RETURN NUMBER;

-------------------------------------------------------------------------------

  FUNCTION get_total_leased_area (
                  p_leaseId IN NUMBER ,
                  p_as_of_Date   IN  DATE default NULL ) RETURN NUMBER;


-------------------------------------------------------------------------------

FUNCTION GET_LEASE_STATUS (
                                p_leaseId        NUMBER
                                  ) RETURN VARCHAR2;


-------------------------------------------------------------------------------

FUNCTION pn_distinct_zip_code (
  p_address_id          NUMBER,
  p_zip_code            VARCHAR2
) RETURN NUMBER ;


-------------------------------------------------------------------------------

----------------------------------------------------------------------
-- FUNCTION : GET_LOCATION_OCCUPANCY
--            This function returns the number of employees assigned
--            to a location
----------------------------------------------------------------------
FUNCTION GET_LOCATION_OCCUPANCY (
                p_locationId          IN        NUMBER,
        p_As_Of_Date          IN    DATE DEFAULT NULL
        ) RETURN NUMBER ;



----------------------------------------------------------------------
-- Returns the cost center of an employee at HR assignment level
-- 28-NOV-05    sdmahesh         o Added parameter org_id
----------------------------------------------------------------------
FUNCTION get_cost_center ( p_employee_id IN NUMBER,
                           p_column_name IN VARCHAR2 DEFAULT NULL,
                           p_org_id      IN  NUMBER
                         ) RETURN VARCHAR2;
  -- Don't put in pragma for this, pkg body will not compile!  Naga


-------------------------------------
-- valid_lookup_code
--------------------------------------
  FUNCTION valid_lookup_code (
    p_lookup_type  VARCHAR2,
    p_lookup_code  VARCHAR2 )
  RETURN BOOLEAN;


-------------------------------------
-- valid_country_code
--------------------------------------
  FUNCTION valid_country_code (
    p_country  VARCHAR2 )
  RETURN BOOLEAN;



-------------------------------------
-- valid_uom_code
--------------------------------------
  FUNCTION valid_uom_code (
    p_uom_code  VARCHAR2 )
  RETURN BOOLEAN;



-------------------------------------
-- valid_employee
--------------------------------------
  FUNCTION valid_employee (
    p_employee_id  NUMBER )
  RETURN BOOLEAN;



-------------------------------------------------------------------------------
-- valid_cost_center
-- 28-NOV-2005 sdmahesh     o Added parameter p_org_id
-------------------------------------------------------------------------------
  FUNCTION valid_cost_center (
     p_cost_center  VARCHAR2, p_org_id NUMBER )
  RETURN BOOLEAN;

  -- Don't put in pragma for this, pkg body will not compile!  Naga


-------------------------------------
-- valid_emp_cc_comb
--------------------------------------
  FUNCTION valid_emp_cc_comb (
    p_employee_id  NUMBER,
    p_cost_center  VARCHAR2 )
  RETURN BOOLEAN;

  -- Don't put in pragma for this, pkg body will not compile!  Naga

-------------------------------------
-- valid_location
--------------------------------------
  FUNCTION valid_location (
    p_location_id  NUMBER ,
    p_as_of_date IN DATE DEFAULT NULL)
  RETURN BOOLEAN;



/*-- This should be taken care of by a l_vacant_area in PNVLOSPB.pls --

-------------------------------------
-- allowed_allocated_area
--------------------------------------
  FUNCTION allowed_allocated_area (
    p_allocated_area  NUMBER )
  RETURN BOOLEAN;

  pragma restrict_references ( allowed_allocated_area, WNDS, WNPS );

-- Read Comment at start of function spec --*/


-------------------------------------------------------------------------------
-- get_cc_code
--28-NOV-05  sdmahesh o Added parameter P_ORG_ID

-------------------------------------------------------------------------------
  FUNCTION get_cc_code (
    p_employee_id  NUMBER,
    p_org_id       NUMBER)
  RETURN VARCHAR2;

  -- Don't put in pragma for this, pkg body will not compile!  Naga


-------------------------------------
-- get_segment_column_name
--28-NOV-05 sdmahesh o Added parameter p_org_id
--------------------------------------
  FUNCTION get_segment_column_name(p_org_id NUMBER)
  RETURN VARCHAR2;

-------------------------------------
-- pn_get_next_location_id
--------------------------------------
  FUNCTION pn_get_next_location_id RETURN NUMBER;

-------------------------------------
-- pn_get_next_space_alloc_id
--------------------------------------
  FUNCTION pn_get_next_space_alloc_id RETURN NUMBER;

-------------------------------------
-- SET_VIEW_CONTEXT
--------------------------------------
  PROCEDURE SET_VIEW_CONTEXT(p_ap_ar  VARCHAR2);

-------------------------------------
-- GET_VIEW_CONTEXT
--------------------------------------
  FUNCTION GET_VIEW_CONTEXT RETURN VARCHAR2;

-------------------------------------------------------------------
-- For getting the daily conversion rate from GL's new API in 11.5
-- The form uses this, to display the amount in foreign currency,
-- when user chooses a currency code different from the functional
-- currency.
-------------------------------------------------------------------

-------------------------------------------------------------------
-- To Return EXPORT_CURRENCY_AMOUNT column
-- Get Export Currency Amount from GL's API
-------------------------------------------------------------------
FUNCTION Export_Curr_Amount (
  currency_code             in        VARCHAR2,
  export_currency_code      in        VARCHAR2,
  export_date               in        DATE,
  conversion_type           in        VARCHAR2,
  actual_amount             in        NUMBER,
  p_called_from             IN        VARCHAR2 DEFAULT NULL
)

RETURN NUMBER ;

  -- Don't put in pragma for this, pkg body will not compile!  Naga


-------------------------------------------------------------------
-- To Return the Start_Date, given the Period_Name
-- For use in PN_EXP_TO_AP, PN_EXP_TO_AR packkages
--28-NOV-05  sdmahesh o Added parameter P_ORG_ID
-------------------------------------------------------------------
FUNCTION Get_Start_Date(p_Period_Name  VARCHAR2,p_org_id NUMBER)
RETURN date ;


-------------------------------------------------------
-- FUNCTION Get_Occupancy_Status
-------------------------------------------------------
FUNCTION Get_Occupancy_Status(p_location_id NUMBER,
                              p_As_Of_Date  DATE default NULL)
RETURN   NUMBER ;


-------------------------------------------------------
-- FUNCTION  Get_Location_Code
-------------------------------------------------------

FUNCTION  Get_Location_Code ( p_location_id NUMBER ,
                              p_As_Of_Date  DATE    default NULL,
                              p_ignore_date BOOLEAN default FALSE)
RETURN    VarChar2 ;

-------------------------------------------------------
-- FUNCTION  Get_Location_Type_Lookup_Code
-------------------------------------------------------

FUNCTION  Get_Location_Type_Lookup_Code ( p_location_id NUMBER ,
                                          p_as_of_date  DATE    default NULL,
                                          p_ignore_date BOOLEAN default FALSE)
RETURN    VarChar2 ;

-------------------------------------------------------------
-- FUNCTION  Get_Allocated_Area_By_CC - For use in Report PNSPALLO
-------------------------------------------------------------
FUNCTION  Get_Allocated_Area_By_CC ( p_Location_Id  NUMBER ,
                                     p_Cost_Center  VarChar2,
                                     p_As_Of_Date   DATE default NULL )
RETURN    NUMBER ;


-------------------------------------------------------------
-- FUNCTION  Get_High_Schedule_Date - For use in Form PNTLEASE
-------------------------------------------------------------
FUNCTION Get_High_Schedule_Date ( p_leaseId NUMBER )
RETURN Date;


-------------------------------------------------------------
-- FUNCTION  Get_High_Change_Comm_Date - For use in Form PNTLEASE
-------------------------------------------------------------
FUNCTION  Get_High_Change_Comm_Date ( p_leaseId  NUMBER )
RETURN    Date ;

-------------------------------------------------------------
-- FUNCTION  Get_Emp_Hr_Data - For use in Form PNTSPACE
-------------------------------------------------------------
FUNCTION  Get_Emp_Hr_Data ( p_personId  NUMBER )
RETURN    emp_hr_data_rec;

-------------------------------------------------------------
-- FUNCTION  Get_Emp_Pr_Data - For use in Form PNTSPACE
-------------------------------------------------------------
FUNCTION  Get_Emp_Pr_Data ( p_projectId  NUMBER )
RETURN    emp_pr_data_rec;

-------------------------------------------------------------
-- FUNCTION  Get_Emp_Tr_Data - For use in Form PNTSPACE
-------------------------------------------------------------
FUNCTION  Get_Emp_Tr_Data ( p_taskId  NUMBER )
RETURN    emp_tr_data_rec;

-------------------------------------------------------------------------------

  FUNCTION get_building_rentable_area ( p_location_id  IN  NUMBER ,
                    p_as_of_date IN DATE DEFAULT NULL) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  FUNCTION get_building_usable_area( p_location_id  IN  NUMBER ,
               p_as_of_date IN DATE DEFAULT NULL
           ) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  FUNCTION get_building_assignable_area ( p_location_id  IN  NUMBER ,
                   p_as_of_date IN DATE DEFAULT NULL
           ) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  FUNCTION get_floor_rentable_area ( p_location_id  IN  NUMBER ,
                   p_as_of_date IN DATE DEFAULT NULL
  ) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  FUNCTION get_floor_usable_area( p_location_id  IN  NUMBER ,
                   p_as_of_date IN DATE DEFAULT NULL
   ) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  FUNCTION get_floor_assignable_area ( p_location_id  IN  NUMBER ,
                   p_as_of_date IN DATE DEFAULT NULL
           ) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  FUNCTION get_floor_common_area ( p_location_id  IN  NUMBER ,
                   p_as_of_date IN DATE DEFAULT NULL
  ) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
 FUNCTION get_building_common_area ( p_location_id  IN  NUMBER ,
                   p_as_of_date IN DATE DEFAULT NULL
  ) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------



  FUNCTION get_building_max_capacity ( p_location_id  IN  NUMBER ,
                   p_as_of_date IN DATE DEFAULT NULL
  ) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  FUNCTION get_building_optimum_capacity( p_location_id  IN  NUMBER ,
                   p_as_of_date IN DATE DEFAULT NULL
  ) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  FUNCTION get_floor_max_capacity ( p_location_id  IN  NUMBER ,
                   p_as_of_date IN DATE DEFAULT NULL
  ) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  FUNCTION get_floor_optimum_capacity( p_location_id  IN  NUMBER ,
                   p_as_of_date IN DATE DEFAULT NULL
  ) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  FUNCTION get_floor_vacancy ( p_location_id  IN  NUMBER,
                   p_as_of_date IN DATE DEFAULT NULL ) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  FUNCTION get_office_vacancy (p_location_id  IN  NUMBER ,
                               p_as_of_date   IN DATE DEFAULT NULL
  ) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  FUNCTION get_space_assigned_status (p_location_id   IN NUMBER,
                                      p_as_of_date    IN DATE DEFAULT NULL
                                        )
  RETURN BOOLEAN;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  FUNCTION get_floor_secondary_area ( p_location_id  IN  NUMBER,
                                      p_as_of_date    IN DATE DEFAULT NULL ) RETURN NUMBER;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  FUNCTION get_office_secondary_area ( p_location_id  IN  NUMBER ,
               p_as_of_date IN DATE DEFAULT NULL
           ) RETURN NUMBER;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
  FUNCTION get_parent_location_id (  p_location_id IN NUMBER ) RETURN NUMBER;

-------------------------------------------------------------------------------
  FUNCTION get_normalize_flag (    p_paymentTermId IN NUMBER
                                      ) RETURN VarChar2;

-------------------------------------------------------------------
-- To Return the  Hire Date, given the Person_Id
-- For use in insert script pninsspa.sql
-------------------------------------------------------------------
FUNCTION get_hire_date(p_PersonId  IN NUMBER)
RETURN date ;

-------------------------------------------------------------
-- FUNCTION  Get_Location_Name - For use in RXi
-------------------------------------------------------------
FUNCTION  get_location_name ( p_Location_Id IN NUMBER ,
              p_as_of_date IN DATE DEFAULT NULL)
RETURN    location_name_rec;

-------------------------------------------------------------------
-- To Return the Termination Date, given the Person_Id
-- For use in the PNEMPDSP.rdf
-------------------------------------------------------------------
FUNCTION get_termination_date(p_PersonId  IN NUMBER)
RETURN date ;

-------------------------------------------------------------------
-- To return Rentable Area, given Location Type Lookup Code and
-- Location ID. For use in PNSPUTIL.rdf
-------------------------------------------------------------------
FUNCTION get_rentable_area(p_loc_type_lookup_code IN VARCHAR2,
                           p_location_id IN NUMBER,
                           p_as_of_date DATE DEFAULT NULL  )
RETURN NUMBER;

---------------------------------------------------------------------
-- To return default GL period name for a given GL date. If GL period
-- for that date is closed then next open GL period name is defaulted.
-- 28-NOV-2005  sdmahesh    o Added parameter P_ORG_ID
---------------------------------------------------------------------
FUNCTION get_default_gl_period(p_sch_date       IN DATE,
                               p_application_id IN NUMBER,
                               p_org_id         IN NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------------
-- To return the UOM_CODE, given Location Type Lookup Code and
-- Location ID. For use in PNTSPACE.fmb
-- Bug Fix for the Bug ID#1540803.
-------------------------------------------------------------------
FUNCTION Get_Unit_Of_Measure (p_location_id IN NUMBER,
                              p_loc_type    IN VARCHAR2 DEFAULT NULL,
                              p_as_of_date  IN DATE DEFAULT NULL
)
RETURN VARCHAR2;

-------------------------------------------------------------------
-- To return Payment Term Name for a given Term Id for Payables.
-------------------------------------------------------------------
FUNCTION Get_Ap_Payment_term (p_ap_term_id IN NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------------
-- To return Payment Term Name for a given Term Id for Receivables.
-------------------------------------------------------------------
FUNCTION Get_Ar_Payment_term (p_ar_term_id IN NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------------
-- To return Distribution Set Name for a given Distribution Set Id.
-------------------------------------------------------------------
FUNCTION Get_Distribution_Set_Name (p_dist_set_id IN NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------------
-- To return Project Name for a given Porject Id for Payables.
-------------------------------------------------------------------
FUNCTION Get_Ap_Project_Name (p_project_id IN NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------------
-- To return Task Name for a given Task Id for Payables.
-------------------------------------------------------------------
FUNCTION Get_Ap_Task_Name (p_task_id IN NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------------
-- To return Organization Name for a given Organization Id for Payables.
-------------------------------------------------------------------
FUNCTION Get_Ap_Organization_Name (p_org_id IN NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------------------------
-- To return Transaction Type for a given Customer Transaction Type
-- Id from Receivables.
-- IMPORTANT - Do not use this after MOAC goes ON
-------------------------------------------------------------------------------
FUNCTION Get_Ar_Trx_type (p_trx_id IN NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------------
-- To return Invoice Rule Name for a given Invoice Rule Id from Receivables.
-------------------------------------------------------------------
FUNCTION Get_Ar_Rule_Name (p_rule_id IN NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------------
-- To return Sales Person Name for a given Sales Person Id from Receivables.
-------------------------------------------------------------------
FUNCTION Get_Salesrep_Name (p_salesrep_id IN NUMBER,
                            p_org_id IN NUMBER)
RETURN VARCHAR2;

--------------------------------------------------------------------------------
-- To return allocated area for a date range.
-- 07-Jan-04 dthota  o bug # 3354278 - new param p_allocated_area_pct
-- 30-DEC-04 Kiran   o Bug # 4093603 - new param p_called_frm_mode
--------------------------------------------------------------------------------
PROCEDURE get_allocated_area (p_loc_id             IN     NUMBER,
                              p_str_dt             IN     DATE,
                              p_new_end_dt         IN OUT NOCOPY DATE,
                              p_allocated_area     OUT NOCOPY NUMBER,
                              p_allocated_area_pct OUT NOCOPY NUMBER,
                              p_future             OUT NOCOPY VARCHAR2,
                              p_called_frm_mode    IN VARCHAR2 DEFAULT NULL);

--------------------------------------------------------------------------------
-- To return end_date, assignable_area and to indicate if future
-- dated assignment exists and if vacant area is available for a location
-- for a gien start and end date.
-- 30-DEC-04 Kiran   o Bug # 4093603 - new param p_called_frm_mode
--------------------------------------------------------------------------------
PROCEDURE validate_vacant_area (p_location_id            IN NUMBER,
                                p_st_date                IN DATE,
                                p_end_dt                 IN OUT NOCOPY DATE,
                                p_assignable_area        IN OUT NOCOPY NUMBER,
                                p_old_allocated_area     IN NUMBER,
                                p_new_allocated_area     IN NUMBER,
                                p_old_allocated_area_pct IN NUMBER,
                                p_new_allocated_area_pct IN NUMBER,
                                p_display_message        IN VARCHAR2,
                                p_future                 OUT NOCOPY VARCHAR2,
                                p_available_vacant_area  OUT NOCOPY BOOLEAN,
                                p_called_frm_mode        IN VARCHAR2 DEFAULT NULL);

--------------------------------------------------------------------------------
-- To return Minimum Future start date for an assigned location on a given date.
--------------------------------------------------------------------------------
FUNCTION get_min_futr_str_dt(p_loc_id IN NUMBER,
                             p_str_dt IN DATE)
RETURN DATE;

-----------------------------------------------------------------------------------
-- To return Conversion Rate Type either from profile option setup or pn_currencies.
-- 28-NOV-2005  sdmahesh       o Added parameter P_ORG_ID
-----------------------------------------------------------------------------------
FUNCTION check_conversion_type(p_curr_code IN VARCHAR2,
                               p_org_id IN NUMBER) RETURN VARCHAR2;

-----------------------------------------------------------------------------------
-- This procedure updates allocated_area_pct in pn_space_assign_emp and pn_space_assign_cust
-- when assignable area is changed for a given location.
-----------------------------------------------------------------------------------
PROCEDURE loctn_assgn_area_update(p_loc_id       IN NUMBER,
                                  p_assgn_area   IN NUMBER,
                                  p_str_dt       IN DATE,
                                  p_end_dt       IN DATE);



FUNCTION get_as_of_date(p_as_of_date IN DATE) RETURN DATE;

-----------------------------------------------------------------------------------
--These type are  used to get the output  from get_area procedure
-----------------------------------------------------------------------------------

TYPE PN_LOCATION_AREA_REC IS  RECORD (assignable_area       NUMBER    ,
                                      rentable_area         NUMBER    ,
                                      usable_area           NUMBER    ,
                                      common_area           NUMBER    ,
                                      secondary_area        NUMBER    ,
                                      max_capacity          NUMBER    ,
                                      optimum_capacity      NUMBER
                                      );

TYPE PN_SPACE_AREA_REC IS  RECORD (allocated_area           NUMBER    ,
                                   allocated_area_emp       NUMBER    ,
                                   allocated_area_cust      NUMBER    ,
                                   UtilizedCapacityEmp      NUMBER    ,
                                   UtilizedCapacityCust     NUMBER    ,
                                   UtilizedCapacity         NUMBER    ,
                                   Occupancy_percent        NUMBER    ,
                                   vacant_area              NUMBER    ,
                                   vacant_area_percent      NUMBER    ,
                                   vacancy                  NUMBER    ,
                                   area_utilized            NUMBER
                                   );

PROCEDURE  get_area ( p_Location_Id                   IN     NUMBER   ,
                      p_location_type                 IN     VARCHAR2 ,
                      p_area_type                     IN     VARCHAR2   DEFAULT NULL,
                      p_as_of_date                    IN     DATE      DEFAULT NULL,
                      p_loc_area                         OUT NOCOPY PN_LOCATION_AREA_REC,
                      p_space_area                       OUT NOCOPY PN_SPACE_AREA_REC
                     );

----------------------------------------------------------------------------------------
-- Validate_Assignable_Area Fix for Bug#2384573
-- For use in PNSULOCN. Checks if the new Assignable_Area is greater than Allocated_Area
-- irrespective of date.
----------------------------------------------------------------------------------------

FUNCTION validate_assignable_area ( p_Location_Id        IN    NUMBER,
                                    p_Location_Type      IN    VARCHAR2,
                                    p_Assignable_Area    IN    NUMBER )
                                    RETURN BOOLEAN;

----------------------------------------------------------------------------------------
-- Validate Term Template for all required data to create a term when Term Template is
-- used by Index Rent or Variable Rent forms.
----------------------------------------------------------------------------------------
FUNCTION validate_term_template(p_term_temp_id   IN NUMBER,
                                p_lease_cls_code IN VARCHAR2)
RETURN BOOLEAN;

-------------------------------------------------------------------
-- To return Term Template Name for a given Term Template Id.
-------------------------------------------------------------------
FUNCTION get_term_template_name(p_term_temp_id   IN NUMBER)
RETURN VARCHAR2;

-----------------------------------------------------
-- Procedure to return all attributes of a location
-- If location is at a higher level than OFFICE/SECTION
-- it drills down to the leaf level and return all
-- attributes from the assignment tables
-----------------------------------------------------
PROCEDURE Get_space_assignments
    ( p_location_id                   IN     NUMBER,
      p_location_type                 IN     VARCHAR2 DEFAULT NULL,
      p_start_date                    IN     DATE,
      p_end_date                      IN     DATE,
      x_space_assign_cust_tbl            OUT NOCOPY SPACE_ASSIGNMENT_TBL,
      x_space_assign_emp_tbl             OUT NOCOPY SPACE_ASSIGNMENT_TBL,
      x_return_status                    OUT NOCOPY VARCHAR2,
      x_return_message                   OUT NOCOPY VARCHAR2
    );

----------------------------------------------
-- Procedure to validate if there are any
-- existing assignment for the date range
--------------------------------------------

PROCEDURE Validate_assignment_for_date (
    p_location_id                   IN     NUMBER,
    p_start_date                    IN     DATE,
    p_end_date                      IN     DATE,
    p_start_date_old                IN     DATE,
    p_end_date_old                  IN     DATE,
    x_return_status                    OUT NOCOPY VARCHAR2,
    x_return_message                   OUT NOCOPY VARCHAR2
    );

-----------------------------------------
-- Procedure to validate availability
-- of assignable area
----------------------------------------
PROCEDURE Validate_assignable_area (
    p_location_id                   IN     NUMBER,
    p_assignable_area               IN     NUMBER,
    p_start_date                    IN     DATE,
    p_end_date                      IN     DATE,
    x_return_status                    OUT NOCOPY VARCHAR2,
    x_return_message                   OUT NOCOPY VARCHAR2
   );
---------------------------------------------------------------------
-- Procedure that will be called by client programs to validate
-- date effectivity of the location and also to validate the changes
-- made to assignable_area. This is to make sure that there are
-- no assignments within the proposed end dates
--------------------------------------------------------------------
PROCEDURE validate_date_assignable_area
    ( p_location_id                   IN      NUMBER,
      p_location_type                 IN      VARCHAR2,
      p_start_date                    IN      DATE,
      p_end_date                      IN      DATE,
      p_active_start_date_old         IN      DATE,
      p_active_end_date_old           IN      DATE,
      p_change_mode                   IN      VARCHAR2 DEFAULT 'CORRECT',
      p_assignable_area               IN     NUMBER DEFAULT NULL,
      x_return_status                    OUT NOCOPY VARCHAR2,
      x_return_message                   OUT NOCOPY VARCHAR2
    );

---------------------------------------------------------
-- This procedure will validate the start and end dates
-- for space assignments to make sure that they lie within
-- the effective date range for that location
-------------------------------------------------
PROCEDURE Validate_date_for_assignments
   ( p_location_id                   IN     NUMBER,
     p_start_date                    IN     DATE,
     p_end_date                      IN     DATE DEFAULT G_END_OF_TIME,
     x_return_status                    OUT NOCOPY VARCHAR2,
     x_return_message                   OUT NOCOPY VARCHAR2
    );

--------------------------------------------------------------------------
-- This Function validates if there exists atleast one primary tenancy
-- with an end date greater than the new end date
--
-- History:
-- 24-jun-2003  Kiran   o Created. CAM impact on Locations.
--------------------------------------------------------------------------

FUNCTION Exist_Tenancy_For_End_Date
  ( p_Location_Id            IN  NUMBER,
    p_New_End_Date           IN  DATE
  )
RETURN BOOLEAN;

--------------------------------------------------------------------------
-- This Function validates if there exists atleast one primary tenancy
-- with a start date lesser than the new start date
--
-- History:
-- 24-jun-2003  Kiran   o Created. CAM impact on Locations.
--------------------------------------------------------------------------

FUNCTION Exist_Tenancy_For_Start_Date
  ( p_Location_Id            IN  NUMBER,
    p_New_Start_Date         IN  DATE
  )
RETURN BOOLEAN;

--------------------------------------------------------------------------
-- This function returns TRUE if there exists if there is atleast one
-- Area Class Detail for the goven Location or any of its child locations.
-- The check is actually mde against the pn_rec_arcl_dtlln table.
--
-- History:
-- 24-jun-2003  Kiran   o Created. CAM impact on locations.
--------------------------------------------------------------------------

FUNCTION Exist_Area_Class_Dtls_For_Loc
  ( p_Location_Id            IN  NUMBER,
    p_active_start_date      IN  DATE   default NULL,
    p_active_end_date        IN  DATE   default NULL)
RETURN BOOLEAN;

--------------------------------------------------------------------------
-- FUNCTION   : chk_terms_for_tenancy
-- DESCRIPTION: checks payment terms for ties to tenancy
-- RETURNS    : TRUE if any payment term is associated to the tenancy
--            : FALSE otherwise
-- HISTORY
-- 15-JAN-04 ftanudja o created.
--------------------------------------------------------------------------
FUNCTION chk_terms_for_tenancy(
             p_tenancy_id  NUMBER,
             p_type        VARCHAR2) RETURN BOOLEAN;


--------------------------------------------------------------------------
-- PROCEDURE  : chk_terms_for_lease_area_chg
-- DESCRIPTION: checks payment terms for possible impacts of changes in
--              lease rentable, usable or assignable area.
-- RETURNS    : 1) a table containing list of impacted term ID's.
--              2) a table containing their new respective areas.
-- HISTORY
-- 08-JAN-04 ftanudja o created
-- 11-FEB-04 ftanudja o added NOCOPY hint for OUT param
-- 20-FEB-04 ftanudja o added parameter p_share_pct
--------------------------------------------------------------------------
PROCEDURE chk_terms_for_lease_area_chg(
             p_tenancy_id  NUMBER,
             p_lease_id    NUMBER,
             p_rentable    NUMBER,
             p_usable      NUMBER,
             p_assignable  NUMBER,
             p_share_pct   NUMBER,
             x_term_id_tbl OUT NOCOPY num_tbl,
             x_area_tbl    OUT NOCOPY num_tbl);

--------------------------------------------------------------------------
-- PROCEDURE  : chk_terms_for_locn_area_chg
-- DESCRIPTION: checks payment terms for possible impacts of changes in
--              location rentable, usable or assignable area.
-- RETURNS    : 1) a table containing list of impacted term ID's.
--              2) a table containing their new respective areas.
-- HISTORY
-- 08-JAN-04 ftanudja o created
-- 11-FEB-04 ftanudja o added NOCOPY hint for OUT param
--------------------------------------------------------------------------
PROCEDURE chk_terms_for_locn_area_chg (
             p_bld_loc_id  NUMBER,
             p_flr_loc_id  NUMBER,
             p_ofc_loc_id  NUMBER,
             p_rentable    NUMBER,
             p_usable      NUMBER,
             p_assignable  NUMBER,
             x_term_id_tbl OUT NOCOPY num_tbl,
             x_area_tbl    OUT NOCOPY num_tbl);

--------------------------------------------------------------------------
-- PROCEDURE  : batch_update_terms_area
-- DESCRIPTION: performs batch updates of area value onto the payment
--              terms table.
-- HISTORY
-- 08-JAN-04 ftanudja o created
--------------------------------------------------------------------------
PROCEDURE batch_update_terms_area(
             x_area_tbl    num_tbl,
             x_term_id_tbl num_tbl);

--------------------------------------------------------------------------
-- PROCEDURE  : fetch_loctn_area
-- DESCRIPTION: Generic function to fetch area.
-- HISTORY
-- 25-FEB-04 ftanudja o created.
--------------------------------------------------------------------------
PROCEDURE fetch_loctn_area(
              p_type        VARCHAR2,
              p_location_id NUMBER,
              p_as_of_date  DATE,
              x_area        OUT NOCOPY pn_location_area_rec);

-------------------------------------------------------------------------------
-- FUNCTION    : fetch_tenancy_area
-- RETURNS     : gets area given an area type code, taking into account
--               the tenancy percentage share.
-- HISTORY
-- 21-APR-05 ftanudja o created. #4324777
-- 01-SEP-05 Kiran    o Changed the type of params from
--                      pn_payment_terms.%TYPE to pn_payment_terms_all.%TYPE
-------------------------------------------------------------------------------
FUNCTION fetch_tenancy_area (
            p_lease_id       pn_payment_terms_all.lease_id%TYPE,
            p_location_id    pn_payment_terms_all.location_id%TYPE,
            p_as_of_date     pn_payment_terms_all.start_date%TYPE,
            p_area_type_code pn_payment_terms_all.area_type_code%TYPE)
RETURN NUMBER;

--------------------------------------------------------------------------------
-- FUNCTION   : create_virtual_schedules
-- DESCRIPTION: Creates VIRTUAL SCHEDULE
-- HISTORY
-- 01-JUL-04  Kiran  o Created. bug # 4229248
--------------------------------------------------------------------------------
FUNCTION create_virtual_schedules( p_start_date DATE
                                  ,p_end_date   DATE
                                  ,p_sch_day    NUMBER
                                  ,p_term_freq  VARCHAR2
                                  ,p_limit_date DATE)
RETURN PNP_UTIL_FUNC.virtual_sched_tbl_type;

--------------------------------------------------------------------------
-- FUNCTION   : valid_early_term_date
-- DESCRIPTION: Validates the early termination date
-- HISTORY
-- 01-JUL-04  Kiran  o Created. bug # 3562487
--------------------------------------------------------------------------
FUNCTION valid_early_term_date( p_lease_id         NUMBER
                               ,p_term_id          NUMBER
                               ,p_normalized       VARCHAR2
                               ,p_frequency        VARCHAR2
                               ,p_termination_date DATE
                               ,p_called_from      VARCHAR2)
RETURN  BOOLEAN;

-- Retro Start
FUNCTION retro_enabled RETURN BOOLEAN;
FUNCTION retro_enabled_char RETURN VARCHAR2;

PROCEDURE check_var_rent_retro( p_term_id        IN NUMBER
                               ,p_new_start_date IN DATE
                               ,p_new_end_date   IN DATE
                               ,p_error          OUT NOCOPY BOOLEAN);

PROCEDURE get_yr_mth_days(p_from_date IN DATE
                         ,p_to_date   IN DATE
                         ,p_yrs       OUT NOCOPY NUMBER
                         ,p_mths      OUT NOCOPY NUMBER
                         ,p_days      OUT NOCOPY NUMBER);

FUNCTION get_date_from_ymd(p_from_date IN DATE
                          ,p_yrs       IN NUMBER
                          ,p_mths      IN NUMBER
                          ,p_days      IN NUMBER)
RETURN DATE;
-- Retro End

/* public view as of date setter/getters functions */
/*------------------------------------------------------------------------------
-- set G_AS_OF_DATE_4_LOC_PUBVIEW
------------------------------------------------------------------------------*/
FUNCTION set_as_of_date_4_loc_pubview(p_date IN DATE) RETURN NUMBER;

/*------------------------------------------------------------------------------
-- get G_AS_OF_DATE_4_LOC_PUBVIEW
------------------------------------------------------------------------------*/
FUNCTION get_as_of_date_4_loc_pubview RETURN DATE;

/*------------------------------------------------------------------------------
-- set G_AS_OF_DATE_4_EMP_PUBVIEW
------------------------------------------------------------------------------*/
FUNCTION set_as_of_date_4_emp_pubview(p_date IN DATE) RETURN NUMBER;

/*------------------------------------------------------------------------------
-- get G_AS_OF_DATE_4_EMP_PUBVIEW
------------------------------------------------------------------------------*/
FUNCTION get_as_of_date_4_emp_pubview RETURN DATE;

/* public view as of date setter/getters functions */

/* overloaded functions and procedures for MOAC */
-------------------------------------------------------------------------------
-- To return Transaction Type for a given Customer Transaction Type
-- Id from Receivables.
-- USE THIS IN R12
-------------------------------------------------------------------------------
FUNCTION Get_Ar_Trx_type (p_trx_id IN NUMBER, p_org_id IN NUMBER)
RETURN VARCHAR2;

/*-----------------------------------------------------------------------------
-- Returns a boolean TRUE if mini retro is enabled
-----------------------------------------------------------------------------*/
FUNCTION mini_retro_enabled RETURN BOOLEAN;

/*-----------------------------------------------------------------------------
-- Returns 'Y' if mini retro is enabled
-----------------------------------------------------------------------------*/
FUNCTION mini_retro_enabled_char RETURN VARCHAR2;


/*----------------------------------------------------------------------------
-- Functions added for MTM uptake. Called from leases form-view.
-----------------------------------------------------------------------------*/
FUNCTION get_loc_name_disp(p_lease_id IN NUMBER,
                           p_as_of_date IN DATE)
RETURN VARCHAR2;

FUNCTION get_loc_code_disp(p_lease_id IN NUMBER,
                           p_as_of_date IN DATE)
RETURN VARCHAR2;

FUNCTION get_prop_name_disp(p_lease_id IN NUMBER,
                            p_as_of_date IN DATE)
RETURN VARCHAR2;


--------------------------------------
-- End of Package Spec --
--------------------------------------
END pnp_util_func;

/
