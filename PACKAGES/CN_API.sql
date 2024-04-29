--------------------------------------------------------
--  DDL for Package CN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_API" AUTHID CURRENT_USER as
/* $Header: cnputils.pls 120.6.12010000.2 2009/10/04 11:35:52 ramchint ship $ */

G_RET_STS_WARNING  CONSTANT VARCHAR2(1) := 'W';

TYPE code_combination_rec IS RECORD
  (  ccid             gl_code_combinations.code_combination_id%TYPE,
     code_combination VARCHAR2(2000));

TYPE code_combination_tbl IS TABLE OF code_combination_rec INDEX BY BINARY_INTEGER;

--| ---------------------------------------------------------------------+
--| Procedure Name :  get_fnd_message
--| Desc : Read from FND Message Stack and put into CN Message stack
--|        Will initialize FND message stack and flush CN Message stack
--|        at the end.
--|     ** This procedure will do a 'COMMIT' inside the code. **
--| ---------------------------------------------------------------------+
PROCEDURE get_fnd_message( p_msg_count NUMBER,
                           p_msg_data  VARCHAR2);

--| ---------------------------------------------------------------------+
--| Function Name :  get_rate_table_name
--| Desc : Pass in rate table id then return rate table name
--| ---------------------------------------------------------------------+
FUNCTION  get_rate_table_name( p_rate_table_id	NUMBER)
  RETURN cn_rate_schedules.name%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_rate_table_name,WNDS,WNPS);

--| ---------------------------------------------------------------------+
--| Function Name :  get_rate_table_id
--| Desc : Pass in rate table name then return rate table id
--| ---------------------------------------------------------------------+
FUNCTION  get_rate_table_id( p_rate_table_name	VARCHAR2, p_org_id NUMBER)
  RETURN cn_rate_schedules.rate_schedule_id%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_rate_table_id,WNDS,WNPS);
--| ---------------------------------------------------------------------+
--| Function Name :  get_period_name
--| Desc : Pass in period id then return period name only if the period
--|        is 'opened' or 'future entry' status
--| ---------------------------------------------------------------------+
FUNCTION  get_period_name( p_period_id  NUMBER,  p_org_id NUMBER)
  RETURN cn_periods.period_name%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_period_name,WNDS,WNPS);
--| ---------------------------------------------------------------------+
--| Function Name :  get_period_id
--| Desc : Pass in period name then return period id only if the period
--|        is 'opened' or 'future entry' status
--| ---------------------------------------------------------------------+
FUNCTION  get_period_id( p_period_name  VARCHAR2,  p_org_id NUMBER)
  RETURN cn_periods.period_id%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_period_id,WNDS,WNPS);
--| ---------------------------------------------------------------------+
--| Function Name :  get_rev_class_id
--| Desc : Pass in revenue class name then return revenue class id
--| ---------------------------------------------------------------------+
FUNCTION  get_rev_class_id( p_rev_class_name  VARCHAR2,  p_org_id NUMBER)
  RETURN cn_revenue_classes.revenue_class_id%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_rev_class_id,WNDS,WNPS);
--| ---------------------------------------------------------------------+
--| Function Name :  get_rev_class_name
--| Desc : Pass in revenue class id then return revenue class name
--| ---------------------------------------------------------------------+
FUNCTION  get_rev_class_name( p_rev_class_id  number)
  RETURN cn_revenue_classes.name%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_rev_class_name,WNDS,WNPS);
--| ---------------------------------------------------------------------+
--| Function Name :  get_lkup_meaning
--| Desc : Pass in lookup code and lookup type then return lookup meaning
--| ---------------------------------------------------------------------+
FUNCTION  get_lkup_meaning( p_lkup_code VARCHAR2,
			    p_lkup_type VARCHAR2 )
  RETURN cn_lookups.meaning%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_lkup_meaning,WNDS,WNPS);
--| ---------------------------------------------------------------------+
--| Function Name : chk_miss_char_para
--| Desc : Check if the passed in char type parameter is missing
--|        If so, add error message onto FND message stack and update error
--|        x_loading_status
--| ---------------------------------------------------------------------+
FUNCTION chk_miss_char_para ( p_char_para  IN VARCHAR2 ,
			      p_para_name  IN VARCHAR2 ,
			      p_loading_status IN VARCHAR2 ,
			      x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 ;
--| ---------------------------------------------------------------------+
--| Function Name : chk_miss_num_para
--| Desc : Check if the passed in number type parameter is missing
--|        If so, add error message onto FND message stack and update error
--|        x_loading_status
--| ---------------------------------------------------------------------+
FUNCTION chk_miss_num_para ( p_num_para   IN NUMBER ,
			     p_para_name  IN VARCHAR2 ,
			     p_loading_status IN VARCHAR2 ,
			     x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 ;
--| ---------------------------------------------------------------------+
--| Function Name : chk_miss_date_para
--| Desc : Check if the passed in date type parameter is missing
--|        If so, add error message onto FND message stack and update error
--|        x_loading_status
--| ---------------------------------------------------------------------+
FUNCTION chk_miss_date_para ( p_date_para  IN DATE ,
			      p_para_name  IN VARCHAR2 ,
			      p_loading_status IN VARCHAR2 ,
			      x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 ;

--| ---------------------------------------------------------------------+
--| Function Name : chk_null_num_para
--| Desc : Check if the passed in number type parameter is null
--|        If so, add error message onto FND message stack and update error
--|        x_loading_status
--| ---------------------------------------------------------------------+
FUNCTION chk_null_num_para ( p_num_para   IN NUMBER ,
			     p_obj_name   IN VARCHAR2 ,
			     p_loading_status IN VARCHAR2 ,
			     x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 ;

--| ---------------------------------------------------------------------+
--|   Function Name :  chk_null_char_para
--|   Desc : Check if the passed in char type parameter is null
--|        If so, add error message onto FND message stack and update error
--|        x_loading_status
--| ---------------------------------------------------------------------+
FUNCTION chk_null_char_para ( p_char_para  IN VARCHAR2 ,
			      p_obj_name  IN VARCHAR2 ,
			      p_loading_status IN VARCHAR2 ,
			      x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 ;
--| ---------------------------------------------------------------------+
--|   Function Name :  chk_miss_null_date_para
--|   Desc : Check if the passed in date type parameter is null
--|        If so, add error message onto FND message stack and update error
--|        x_loading_status
--| ---------------------------------------------------------------------+
FUNCTION chk_null_date_para ( p_date_para IN DATE ,
			      p_obj_name  IN VARCHAR2 ,
			      p_loading_status IN VARCHAR2 ,
			      x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 ;

--| ---------------------------------------------------------------------+
--| Function Name : chk_miss_null_num_para
--| Desc : Check if the passed in number type parameter is missing or null
--|        If so, add error message onto FND message stack and update error
--|        x_loading_status
--| ---------------------------------------------------------------------+
FUNCTION chk_miss_null_num_para ( p_num_para   IN NUMBER ,
			     p_obj_name   IN VARCHAR2 ,
			     p_loading_status IN VARCHAR2 ,
			     x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2;

--| ---------------------------------------------------------------------+
--|   Function Name :  chk_miss_null_char_para
--|   Desc : Check if the passed in char type parameter is missing or null
--|        If so, add error message onto FND message stack and update error
--|        x_loading_status
--| ---------------------------------------------------------------------+
FUNCTION chk_miss_null_char_para ( p_char_para  IN VARCHAR2 ,
			      p_obj_name  IN VARCHAR2 ,
			      p_loading_status IN VARCHAR2 ,
			      x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2;
--| ---------------------------------------------------------------------+
--|   Function Name :  chk_miss_null_date_para
--|   Desc : Check if the passed in date type parameter is missing or null
--|        If so, add error message onto FND message stack and update error
--|        x_loading_status
--| ---------------------------------------------------------------------+
FUNCTION chk_miss_null_date_para ( p_date_para IN DATE ,
			      p_obj_name  IN VARCHAR2 ,
			      p_loading_status IN VARCHAR2 ,
			      x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2;

--| ---------------------------------------------------------------------+
--|   Function Name :  pe_num_field_must_null
--|   Desc : Check if the Number type field is null
--|        If NOT,add error message onto FND message stack and update error
--|        x_loading_status
--| ---------------------------------------------------------------------+
FUNCTION pe_num_field_must_null   ( p_num_field  IN NUMBER ,
				    p_pe_type IN VARCHAR2 ,
				    p_obj_name  IN VARCHAR2 ,
				    p_token1    IN VARCHAR2 ,
				    p_token2    IN VARCHAR2 ,
				    p_token3    IN VARCHAR2 ,
				    p_loading_status IN VARCHAR2 ,
				    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 ;

--| ---------------------------------------------------------------------+
--|   Function Name :  pe_char_field_must_null
--|   Desc : Check if the char type field is null
--|        If NOT,add error message onto FND message stack and update error
--|        x_loading_status
--| ---------------------------------------------------------------------+
FUNCTION pe_char_field_must_null   ( p_char_field  IN VARCHAR2 ,
				     p_pe_type IN VARCHAR2 ,
				     p_obj_name  IN VARCHAR2 ,
				     p_token1    IN VARCHAR2 ,
				     p_token2    IN VARCHAR2 ,
				     p_token3    IN VARCHAR2 ,
				     p_loading_status IN VARCHAR2 ,
				     x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 ;

--| ---------------------------------------------------------------------+
--|   Function Name :  pe_num_field_cannot_null
--|   Desc : Check the numbeer type field can not be null
--|        If NULL,add error message onto FND message stack and update error
--|        x_loading_status
--| ---------------------------------------------------------------------+
FUNCTION pe_num_field_cannot_null( p_num_field  IN NUMBER ,
				   p_pe_type IN VARCHAR2 ,
				   p_obj_name  IN VARCHAR2 ,
				   p_token1    IN VARCHAR2 ,
				   p_token2    IN VARCHAR2 ,
				   p_token3    IN VARCHAR2 ,
				   p_loading_status IN VARCHAR2 ,
				   x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 ;

--| ---------------------------------------------------------------------+
--|   Function Name :  pe_char_field_cannot_null
--|   Desc : Check the char type field can not be null
--|        If NULL,add error message onto FND message stack and update error
--|        x_loading_status
--| ---------------------------------------------------------------------+
FUNCTION pe_char_field_cannot_null( p_char_field  IN VARCHAR2 ,
				    p_pe_type IN VARCHAR2 ,
				    p_obj_name  IN VARCHAR2 ,
				    p_token1    IN VARCHAR2 ,
				    p_token2    IN VARCHAR2 ,
				    p_token3    IN VARCHAR2 ,
				    p_loading_status IN VARCHAR2 ,
				    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 ;
--| ---------------------------------------------------------------------+
--| Function Name :  get_cp_name
--| Desc : Pass in comp plan id then return comp plan name
--| ---------------------------------------------------------------------+
FUNCTION  get_cp_name( p_comp_plan_id  NUMBER)
  RETURN cn_comp_plans.name%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_cp_name,WNDS,WNPS);
--| ---------------------------------------------------------------------+
--| Function Name :  get_cp_id
--| Desc : Pass in comp plan name then return comp plan id
--| ---------------------------------------------------------------------+
FUNCTION  get_cp_id( p_comp_plan_name  VARCHAR2,  p_org_id NUMBER)
  RETURN cn_comp_plans.comp_plan_id%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_cp_id,WNDS,WNPS);

--| ---------------------------------------------------------------------+
--| Function Name :  get_pp_name
--| Desc : Pass in payment plan id then return payment plan name
--| ---------------------------------------------------------------------+
FUNCTION  get_pp_name( p_pmt_plan_id  NUMBER)
  RETURN cn_pmt_plans.name%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_pp_name,WNDS,WNPS);
--| ---------------------------------------------------------------------+
--| Function Name :  get_pp_id
--| Desc : Pass in payment plan name then return payment plan id
--| ---------------------------------------------------------------------+
FUNCTION  get_pp_id( p_pmt_plan_name  VARCHAR2,  p_org_id NUMBER)
  RETURN cn_pmt_plans.pmt_plan_id%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_pp_id,WNDS,WNPS);

--| ---------------------------------------------------------------------+
--| Function Name :  get_salesrep_name
--| Desc : Pass in salesrep id then return salesrep name
--| ---------------------------------------------------------------------+
FUNCTION  get_salesrep_name( p_salesrep_id  NUMBER,  p_org_id NUMBER)
  RETURN cn_salesreps.name%TYPE;

----PRAGMA RESTRICT_REFERENCES (get_salesrep_name,WNDS,WNPS);

--| ---------------------------------------------------------------------+
--| Function Name :  get_salesrep_id
--| Desc : Pass in salesrep name and employee number then return salesrep id
--| ---------------------------------------------------------------------+
FUNCTION  get_salesrep_id( p_salesrep_name  VARCHAR2, p_emp_num VARCHAR2,  p_org_id NUMBER)
  RETURN cn_salesreps.salesrep_id%TYPE;

--| ---------------------------------------------------------------------+
--| Function Name :  chk_and_get_salesrep_id
--| Desc : Pass in employee number and salesrep type,
--|        Check if retrieve only one record, if yes get the salesrep_id
--| ---------------------------------------------------------------------+
PROCEDURE  chk_and_get_salesrep_id( p_emp_num         IN VARCHAR2,
				    p_type            IN VARCHAR2,
				    p_org_id          IN NUMBER,
				    x_salesrep_id     OUT NOCOPY cn_salesreps.salesrep_id%TYPE,
				    x_return_status   OUT NOCOPY VARCHAR2,
				    x_loading_status  OUT NOCOPY VARCHAR2,
				    p_show_message    IN VARCHAR2 := FND_API.G_TRUE);


-- --------------------------------------------------------------------------+
-- Function : date_range_overlap
-- Desc     : Check if two set of dates (a_start_date,a_end_date) and
--            (b_start_date, b_end_date) are overlap or not.
--            Assuming
--            1. a_start_date is not null and a_start_date > a_end_date
--            2. b_start_date is not null and b_start_date > b_end_date
--            3. both end_date can be open (null)
-- -------------------------------------------------------------------------+
FUNCTION date_range_overlap
  (
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE
   ) RETURN BOOLEAN;

--PRAGMA RESTRICT_REFERENCES (date_range_overlap,WNDS,WNPS);

-- --------------------------------------------------------------------------+
-- Function : date_range_within
-- Desc     : Check if (a_start_date,a_end_date) is within (b_start_date, b_end_date)
--            Assuming
--            1. a_start_date is not null and a_start_date > a_end_date
--            2. b_start_date is not null and b_start_date > b_end_date
--            3. both end_date can be open (null)
-- -------------------------------------------------------------------------+
FUNCTION date_range_within
  (
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE
   ) RETURN BOOLEAN;

--PRAGMA RESTRICT_REFERENCES (date_range_within,WNDS,WNPS);

--| ---------------------------------------------------------------------+
--| Function Name :  invalid_date_range
--| Desc : Check if start date exist, if start_date > end_date
--|        If so, add error message onto FND message stack and update error
--|        x_loading_status
--| Input : p_end_date_nullable : end_date is nullable only if
--|             p_end_date_nullable = FND_API.G_TRUE
--| ---------------------------------------------------------------------+
FUNCTION invalid_date_range
  ( p_start_date  IN DATE ,
    p_end_date    IN DATE ,
    p_end_date_nullable IN VARCHAR2 := FND_API.G_TRUE,
    p_loading_status IN VARCHAR2 := NULL ,
    x_loading_status OUT NOCOPY VARCHAR2,
    p_show_message IN VARCHAR2 := fnd_api.G_TRUE )
  RETURN VARCHAR2 ;


--| ---------------------------------------------------------------------+
--| Function Name :  get_role_id
--| Desc : Get the  role id using the role name
--| ---------------------------------------------------------------------+
FUNCTION  get_role_id ( p_role_name     VARCHAR2 )
  RETURN cn_roles.role_id%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_role_id,WNDS,WNPS);
--| ---------------------------------------------------------------------+
--| Function Name :  get_role_name
--| Desc : Get the  role name using the role ID
--| ---------------------------------------------------------------------+
FUNCTION  get_role_name ( p_role_id     VARCHAR2 )
  RETURN cn_roles.name%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_role_name,WNDS,WNPS);
-- --------------------------------------------------------------------------+
-- Function : get_role_plan_id
-- Desc     : get the role_plan_id if it exists in cn_role_plans
-- --------------------------------------------------------------------------+
FUNCTION get_role_plan_id
  (
   p_role_name              IN  VARCHAR2,
   p_comp_plan_name         IN  VARCHAR2,
   p_start_date             IN  DATE,
   p_end_date               IN  DATE,
   p_org_id                 IN  NUMBER
   ) RETURN cn_role_plans.role_plan_id%TYPE;
-- --------------------------------------------------------------------------+
-- Function : get_role_pmt_plan_id
-- Desc     : get the role_pmt_plan_id if it exists in cn_role_pmt_plans
-- --------------------------------------------------------------------------+
FUNCTION get_role_pmt_plan_id
  (
   p_role_name              IN  VARCHAR2,
   p_pmt_plan_name         IN  VARCHAR2,
   p_start_date             IN  DATE,
   p_end_date               IN  DATE,
   p_org_id                 IN NUMBER
   ) RETURN cn_role_pmt_plans.role_pmt_plan_id%TYPE;
-- --------------------------------------------------------------------------+
-- Function : get_srp_role_plan_id
-- Desc     : get the srp_role_plan_id if it exists in cn_srp_roles
-- --------------------------------------------------------------------------+
FUNCTION get_srp_role_id
  (p_emp_num    IN cn_salesreps.employee_number%type,
   p_type       IN cn_salesreps.TYPE%type,
   p_role_name  IN cn_roles.name%type,
   p_start_date IN cn_srp_roles.start_date%type,
   p_end_date   IN cn_srp_roles.end_date%TYPE,
   p_org_id     IN cn_salesreps.org_id%type
   ) RETURN cn_srp_roles.srp_role_id%TYPE;
--| ---------------------------------------------------------------------+
--| Function Name :  get_srp_payee_assign_id
--| Desc : Get the  srp_payee_assign_id using the
--| payee_id, salesrep_id, quota_id, start_date, end_date
--| ---------------------------------------------------------------------+
FUNCTION  get_srp_payee_assign_id ( p_payee_id     NUMBER,
				    p_salesrep_id  NUMBER,
				    p_quota_id     NUMBER,
				    p_start_date   DATE,
				    p_end_date     DATE,
				    p_org_id       NUMBER)
  RETURN cn_srp_payee_assigns.srp_payee_assign_id%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_srp_payee_assign_id,WNDS,WNPS);

--| ---------------------------------------------------------------------+
--| Function Name :  next_period
--| ---------------------------------------------------------------------+
FUNCTION next_period (p_end_date DATE,  p_org_id NUMBER)
   RETURN cn_acc_period_statuses_v.end_date%TYPE ;

--PRAGMA RESTRICT_REFERENCES (next_period,WNDS,WNPS);

FUNCTION get_pay_period(p_salesrep_id NUMBER,
			p_date        DATE,
			p_org_id      NUMBER )
  RETURN cn_commission_lines.pay_period_id%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_pay_period,WNDS,WNPS);

FUNCTION get_itd_flag(p_calc_formula_id NUMBER)
  RETURN cn_calc_formulas.itd_flag%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_itd_flag,WNDS,WNPS);
--| ---------------------------------------------------------------------+
--| Function Name :  get_acc_period_id
--| Desc : Pass in period name then return period id only if the period
--|        is 'opened' or 'future entry' status
--| ---------------------------------------------------------------------+
FUNCTION  get_acc_period_id( p_period_name  VARCHAR2,  p_org_id NUMBER)
  RETURN cn_periods.period_id%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_acc_period_id,WNDS,WNPS);
--| ---------------------------------------------------------------------+
--| Function Name :  get_acc_period_name
--| Desc : Pass in period id then return period name only if the period
--|        is 'opened' or 'future entry' status
--| ---------------------------------------------------------------------+
FUNCTION  get_acc_period_name( p_period_id  NUMBER,  p_org_id NUMBER)
  RETURN cn_periods.period_name%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_acc_period_name,WNDS,WNPS);
--| ---------------------------------------------------------------------+
--| Function Name :  get_quota_assign_id
--| Desc : Pass in quota id , comp_plan_id then return quota_assing_id
--| ---------------------------------------------------------------------+
FUNCTION  get_quota_assign_id( p_quota_id  NUMBER,
						 p_comp_plan_id NUMBER)
  RETURN cn_quota_assigns.quota_assign_id%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_quota_assign_id,WNDS,WNPS);


TYPE date_range_rec_type IS RECORD
  (start_date  DATE,
   end_date    DATE               );

TYPE date_range_tbl_type IS TABLE OF date_range_rec_type
  INDEX BY BINARY_INTEGER;

-- --------------------------------------------------------------------------+
-- PROCEDURE : get_date_range_overlap
-- Desc     : get the overlap portion of the two date ranges
--            Assuming
--            1. a_start_date is not null and a_start_date < a_end_date
--            2. b_start_date is not null and b_start_date < b_end_date
--            3. both end_date can be open (null)
-- -------------------------------------------------------------------------+
PROCEDURE get_date_range_overlap
  (
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE,
   p_org_id       NUMBER,
   x_date_range_tbl OUT NOCOPY date_range_tbl_type );

--PRAGMA RESTRICT_REFERENCES (get_date_range_overlap,WNDS,WNPS);

-- -------------------------------------------------------------------------+
-- PROCEDURE : get_date_range_diff
-- Desc     : get the difference portion of the two date ranges
--            Assuming
--            1. a_start_date is not null and a_start_date < a_end_date
--            2. b_start_date is not null and b_start_date < b_end_date
--            3. both end_date can be open (null)
-- -------------------------------------------------------------------------+
PROCEDURE get_date_range_diff
  (
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE,
   x_date_range_tbl OUT NOCOPY date_range_tbl_type );

--PRAGMA RESTRICT_REFERENCES (get_date_range_overlap,WNDS,WNPS);

-- -------------------------------------------------------------------------+
-- PROCEDURE : get_date_range_intersect
-- Desc     : get the intersection of two date ranges
--            Assuming
--            1. a_start_date is not null and a_start_date < a_end_date
--            2. b_start_date is not null and b_start_date < b_end_date
--            3. both end_date can be open (null)
--            4. the two date ranges overlap
-- -------------------------------------------------------------------------+
PROCEDURE get_date_range_intersect
  (
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE,
   x_start_date   OUT NOCOPY DATE,
   x_end_date     OUT NOCOPY DATE);

--PRAGMA RESTRICT_REFERENCES (get_date_range_diff,WNDS,WNPS);

TYPE date_range_action_rec_type IS RECORD
  (start_date  DATE,
   end_date    DATE,
   action_flag VARCHAR2(1));

TYPE date_range_action_tbl_type IS TABLE OF date_range_action_rec_type
  INDEX BY BINARY_INTEGER;

-- -------------------------------------------------------------------------+
-- PROCEDURE : get_date_range_diff_action
-- Desc     : get the difference portion of the two date ranges
--            Assuming
--            1. start_date_new is not null and start_date_new < end_date_new
--            2. start_date_old is not null and start_date_old < end_date_old
--            3. both end_date can be open (null)
-- -------------------------------------------------------------------------+
PROCEDURE get_date_range_diff_action
  (
   start_date_new   DATE,
   end_date_new     DATE,
   start_date_old   DATE,
   end_date_old     DATE,
   x_date_range_action_tbl OUT NOCOPY date_range_action_tbl_type );

--PRAGMA RESTRICT_REFERENCES (get_date_range_diff_action,WNDS,WNPS);

-- -------------------------------------------------------------------------+
-- FUNCTION: get_acc_period_id
-- Desc     : get the accumulation period_id given the date
--            If the date is null, will return the latest accumulation period
--            with period_status = 'O'
-- -------------------------------------------------------------------------+
FUNCTION get_acc_period_id (p_date   DATE,  p_org_id NUMBER) RETURN NUMBER;

-- -------------------------------------------------------------------------+
-- FUNCTION: get_acc_period_id_fo
-- Desc     : get the accumulation period_id given the date
--            If the date is null, will return the first accumulation period
--            with period_status = 'O'
-- -------------------------------------------------------------------------+
FUNCTION get_acc_period_id_fo (p_date   DATE,  p_org_id NUMBER) RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES (get_acc_period_id,WNDS,WNPS);
--| ---------------------------------------------------------------------+
--| Procedure Name : check_revenue_class_overlap
--| Desc : Pass in Comp  Plan ID
--|        pass in Comp Plan Name
--|        pass in p_loading_status
--|        out     x_loading_status
--|        out     x_return_status
--| ---------------------------------------------------------------------+
PROCEDURE  check_revenue_class_overlap
  (
   p_comp_plan_id   IN NUMBER,
   p_rc_overlap     IN VARCHAR2,
   p_loading_status IN VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2 );

--| ---------------------------------------------------------------------+
--| Function Name :  get_comp_group_name
--| Desc : Pass in comp_group id then return comp_group_name
--| ---------------------------------------------------------------------+
FUNCTION  get_comp_group_name( p_comp_group_id  NUMBER)
  RETURN cn_comp_groups.name%TYPE;

--PRAGMA RESTRICT_REFERENCES (get_comp_group_name,WNDS,WNPS);

--| ---------------------------------------------------------------------+
--| Function Name :  get_order_booked_date
--| Desc : Pass in order header_id then return date order was booked (or NULL)
--| ---------------------------------------------------------------------+
--FUNCTION  get_order_booked_date(p_order_header_id  NUMBER) RETURN DATE;
--PRAGMA RESTRICT_REFERENCES (get_order_booked_date,WNDS,WNPS);

--| ---------------------------------------------------------------------+
--| Function Name :  get_site_address_id
--| Desc : Pass in order site_use_id then return address_id of 'use site'
--|        (gets address_id out of RA_SITE_USES)
--| ---------------------------------------------------------------------+
FUNCTION  get_site_address_id(p_site_use_id  NUMBER, p_org_id NUMBER) RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES (get_site_address_id,WNDS,WNPS);

--| ---------------------------------------------------------------------+
--| Function Name :  get_order_revenue_type
--| Desc : Derives the Revenue Type of an order, in the format required by
--|        CN
--| ---------------------------------------------------------------------+
FUNCTION  get_order_revenue_type(p_sales_credit_type_id  NUMBER) RETURN VARCHAR2;

--PRAGMA RESTRICT_REFERENCES (get_order_revenue_type,WNDS,WNPS);

-- |------------------------------------------------------------------------+
-- | Function Name : get_credit_info
-- |
-- | Description   : Procedure to return precision and extended precision for credit
-- |                 types
-- |------------------------------------------------------------------------+
PROCEDURE get_credit_info
  (p_credit_type_name IN  cn_credit_types.name%TYPE, /* credit type name */
   x_precision      OUT NOCOPY NUMBER, /* number of digits to right of decimal*/
   x_ext_precision  OUT NOCOPY NUMBER, /* precision where more precision is needed*/
   p_org_id         IN  NUMBER
   );

--| ---------------------------------------------------------------------+
--| Function Name :  convert_to_repcurr
--| Desc : Convert from credit unit into salesrep currency amount
--| ---------------------------------------------------------------------+
FUNCTION  convert_to_repcurr
  (p_credit_unit         IN NUMBER,
   p_conv_date           IN DATE ,
   p_conv_type           IN VARCHAR2,
   p_from_credit_type_id IN NUMBER,
   p_funcurr_code        IN VARCHAR2,
   p_repcurr_code        IN VARCHAR2,
   p_org_id              IN NUMBER
  ) RETURN NUMBER;


--| ---------------------------------------------------------------------+
--| Procedure Name :  convert_to_repcurr_report
--| Desc : Convert from credit unit into salesrep currency amount
--| called by reports.
--| ---------------------------------------------------------------------+
PROCEDURE  convert_to_repcurr_report
  (p_credit_unit         IN NUMBER,
   p_conv_date           IN DATE ,
   p_conv_type           IN VARCHAR2,
   p_from_credit_type_id IN NUMBER,
   p_funcurr_code        IN VARCHAR2,
   p_repcurr_code        IN VARCHAR2,
   x_repcurr_amount      OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   p_org_id              IN NUMBER
   );


--| ---------------------------------------------------------------------+
--| Function Name :  g_miss_char
--| Desc : function to return FND_API.g_miss_char
--| ---------------------------------------------------------------------+
FUNCTION g_miss_char RETURN VARCHAR2;

--| ---------------------------------------------------------------------+
--| Function Name :  g_miss_date
--| Desc : function to return FND_API.g_miss_date
--| ---------------------------------------------------------------------+
FUNCTION g_miss_date RETURN DATE;

--| ---------------------------------------------------------------------+
--| Function Name :  g_miss_num
--| Desc : function to return FND_API.g_miss_num
--| ---------------------------------------------------------------------+
FUNCTION g_miss_num RETURN NUMBER;

--| ---------------------------------------------------------------------+
--| Function Name :  g_miss_id
--| Desc : function to return CN_API.g_miss_id
--| ---------------------------------------------------------------------+
FUNCTION g_miss_id RETURN NUMBER;

--| ---------------------------------------------------------------------+
--| Function Name :  g_false
--| Desc : function to return FND_API.g_false
--| ---------------------------------------------------------------------+
FUNCTION g_false RETURN VARCHAR2;

--| ---------------------------------------------------------------------+
--| Function Name :  g_true
--| Desc : function to return FND_API.g_true
--| ---------------------------------------------------------------------+
FUNCTION g_true RETURN VARCHAR2;

--| ---------------------------------------------------------------------+
--| Function Name :  g_valid_level_none
--| Desc : function to return FND_API.G_VALID_LEVEL_NONE
--| ---------------------------------------------------------------------+
FUNCTION g_valid_level_none RETURN NUMBER;

--| ---------------------------------------------------------------------+
--| Function Name :  g_valid_level_full
--| Desc : function to return FND_API.G_VALID_LEVEL_FULL
--| ---------------------------------------------------------------------+
FUNCTION g_valid_level_full RETURN NUMBER;

--| ---------------------------------------------------------------------+
--| Function Name :  generate code combinations
--| Desc :
--| ---------------------------------------------------------------------+
PROCEDURE get_ccids
  (p_account_type IN varchar2,
   p_org_id            IN NUMBER,
   x_account_structure OUT NOCOPY varchar2,
   x_code_combinations OUT NOCOPY code_combination_tbl);

--| ---------------------------------------------------------------------+
--| Function Name :  get code combination in display format
--| Desc :
--| ---------------------------------------------------------------------+
PROCEDURE get_ccid_disp
  (p_ccid IN varchar2,
   p_org_id            IN NUMBER,
   x_code_combination OUT NOCOPY varchar2);
--| ---------------------------------------------------------------------+
--| Function Name :  get code combination in display format
--| Desc :
--| ---------------------------------------------------------------------+
function  get_ccid_disp_func
  (p_ccid IN varchar2,  p_org_id IN NUMBER )
   RETURN varchar2;
--| ---------------------------------------------------------------------+
--| Function Name :  attribute_desc
--| Desc : Pass in rule_id, rule_attribute_id
--| ---------------------------------------------------------------------+
FUNCTION  get_attribute_desc( p_rule_id NUMBER,
			    p_attribute_id NUMBER )
  RETURN VARCHAR2 ;

--| ---------------------------------------------------------------------+
--| Function Name :  rule_count
--| Desc : Pass in rule_id
--| ---------------------------------------------------------------------+
FUNCTION  get_rule_count( p_rule_id NUMBER)
  RETURN NUMBER ;

 PRAGMA RESTRICT_REFERENCES (get_attribute_desc,WNDS,WNPS);
--| ---------------------------------------------------------------------+
--   Procedure   : chk_Payrun_status_paid
--   Description : Check for valid payrun_id, Status must be unpaid
--| ---------------------------------------------------------------------+
FUNCTION chk_payrun_status_paid
  ( p_payrun_id             IN  NUMBER,
    p_loading_status         IN  VARCHAR2,
    x_loading_status         OUT NOCOPY VARCHAR2
    ) RETURN VARCHAR2 ;
--| ---------------------------------------------------------------------+
--   Procedure   : Chk_hold_status
--   Description : This procedure is used to check if the salesrep is on
-- 		   hold and valid salesrep ID is passed
--| ---------------------------------------------------------------------+
FUNCTION chk_hold_status
  (
   p_salesrep_id            IN  NUMBER,
   p_org_id                 IN  NUMBER,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) RETURN VARCHAR2;
--| ---------------------------------------------------------------------+
--   Procedure   : Chk_Srp_hold_status
--   Description : This procedure is used to check if the salesrep is on
-- 		   hold and valid salesrep ID is passed
--| ---------------------------------------------------------------------+
FUNCTION chk_srp_hold_status
  (
   p_salesrep_id            IN  NUMBER,
   p_org_id                 IN  NUMBER,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) RETURN VARCHAR2;
--| ---------------------------------------------------------------------+
--   Function   : Get_pay_Element_id(P_quota_id, p_salesrep_id,  p_date)
--| ---------------------------------------------------------------------+
FUNCTION Get_pay_Element_ID
  (
   p_quota_id            IN  NUMBER,
   p_Salesrep_id         IN  cn_rs_salesreps.salesrep_id%TYPE,
   p_org_id              IN  NUMBER,
   p_date                IN  DATE
   ) RETURN NUMBER;

-- ===========================================================================
-- Procedure   : check_duplicate_worksheet
-- Description : Check Duplicate Work sheet for salesrep and role in payrun
-- ===========================================================================
FUNCTION chk_duplicate_worksheet
  ( p_payrun_id		    IN  NUMBER,
    p_salesrep_id           IN  NUMBER,
    p_org_id                IN  NUMBER,
    p_loading_status         IN  VARCHAR2,
    x_loading_status         OUT NOCOPY VARCHAR2
    ) RETURN VARCHAR2 ;

-- ===========================================================================
-- Procedure   : check_worksheet_status
-- Description : Check Worksheet Status
-- ===========================================================================
FUNCTION chk_worksheet_status
  ( p_payrun_id		    IN  NUMBER,
    p_salesrep_id           IN  NUMBER,
    p_org_id                IN  NUMBER,
    p_loading_status         IN  VARCHAR2,
    x_loading_status         OUT NOCOPY VARCHAR2
    ) RETURN VARCHAR2 ;
--| ---------------------------------------------------------------------+
--   Function   : Get_pay_Element_Name(P_element_type_id)
--| ---------------------------------------------------------------------+
FUNCTION Get_pay_Element_Name
  (
   p_element_type_id     IN  NUMBER
   ) RETURN VARCHAR2;

--| -----------------------------------------------------------------------+
--| Function Name :  can_user_view_page()
--| Desc : procedure to test if a HTML page is accessible to a user
--| Return true if yes, else return false
--| ---------------------------------------------------------------------+
procedure can_user_view_page
  (
     p_page_name IN varchar2,
     x_return_status OUT NOCOPY varchar2
  );

--| ---------------------------------------------------------------------+
--|   Function   : Is_Payee(p_salesrep_id)
--| Desc : Check if passed in salesrep is a Payee
--| Return 1 if the passed in salesrep_id is a Payee; otherwise return 0
--| ---------------------------------------------------------------------+

FUNCTION Is_Payee( p_salesrep_id    IN     NUMBER,
		   p_period_id      IN     NUMBER,
		   p_org_id         IN     NUMBER) RETURN NUMBER;


--| ---------------------------------------------------------------------+
--|   Function   : Test_Function(p_function_name)
--| Desc : Check if passed in function is allowed
--| Return 1 if it is allowed; otherwise return 0
--| ---------------------------------------------------------------------+

FUNCTION Test_Function( p_function_name    IN     VARCHAR2) RETURN NUMBER;

FUNCTION  get_role_name_2 (period_id NUMBER,
                           salesrep_id NUMBER)
RETURN cn_roles.name%TYPE;


FUNCTION  get_role_name_3 (p_period_id NUMBER DEFAULT NULL,
                           p_salesrep_id NUMBER DEFAULT NULL,
                           p_payrun_id NUMBER DEFAULT NULL,
                           p_ORG_ID   NUMBER DEFAULT NULL,
                           populate NUMBER DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION get_user(p_user_id NUMBER DEFAULT NULL,p_payrun_id NUMBER DEFAULT NULL)
RETURN jtf_number_table;

PROCEDURE get_user_info(p_user_id NUMBER DEFAULT NULL,p_payrun_id NUMBER DEFAULT NULL);

END CN_API;

/
