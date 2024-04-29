--------------------------------------------------------
--  DDL for Package PSP_LABOR_DIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_LABOR_DIST" AUTHID CURRENT_USER as
--$Header: PSPLDCDS.pls 120.8.12010000.1 2008/07/28 08:07:21 appldev ship $

 g_error_api_path		VARCHAR2(1000) := '';
 g_msg  			VARCHAR2(2000) := '';
 --- added global variables for 5080403
 g_global_element_autopop   varchar2(1);
 g_asg_element_autopop      varchar2(1);
 g_asg_ele_group_autopop    varchar2(1);
 g_asg_autopop              varchar2(1);
 g_org_schedule_autopop     varchar2(1);
 g_default_account_autopop  varchar2(1);
 g_suspense_account_autopop varchar2(1);
 g_excess_account_autopop   varchar2(1);
 type t_num_15_type      is table of number(15)   index by binary_integer;
 type t_varchar_30_type  is table of varchar2(30) index by binary_integer;
 type t_date_type        is table of date         index by binary_integer;
 t_payroll_sub_line_id      t_num_15_type;
 t_effective_date           t_date_type;
 t_person_id                t_num_15_type;
 t_assignment_id            t_num_15_type;
 t_element_type_id          t_num_15_type;
 t_project_id               t_num_15_type;
 t_expenditure_organization_id t_num_15_type;
 t_expenditure_type         t_varchar_30_type;
 t_task_id                  t_num_15_type;
 t_award_id                 t_num_15_type;
 t_gl_code_combination_id   t_num_15_type;
 t_account_id               t_num_15_type;
 t_cost_id                  t_num_15_type;
 t_payroll_action_type      t_varchar_30_type;
 ---------------------------------

 g_distribution_line_id	        NUMBER(10);
 g_num_dist                     NUMBER := 0;
 g_tot_dist_amount		NUMBER := 0;

 g_source_type psp_payroll_controls.source_type%type;
 g_source_code psp_payroll_controls.payroll_source_code%type;
 g_time_period_id psp_payroll_controls.time_period_id%type;
 g_batch_name psp_payroll_controls.batch_name%type;
 g_set_of_books_id psp_payroll_controls.set_of_books_id%type;
 g_business_group_id psp_payroll_controls.business_group_id%type;
 g_payroll_id psp_payroll_controls.payroll_id%type;
 g_payroll_action_id psp_payroll_controls.cdl_payroll_action_id%type;

  -- moved following variables from packaged body to here for optimization ..
  -- in context of 4744285
 g_salary_cap_option     varchar2(50);   --- added for 4304623
 g_gen_excess_org_id     number; --- 4744285
 g_use_eff_date          Varchar2(1); /* Bug 1874696 */
 g_dff_grouping_option	CHAR(1);		-- Introduced for bug fix 2908859
 g_cap_element_set_id    integer;        --- added for 4304623

 -- PL/SQL Record and table definition for PSB - LD Integration

 TYPE g_ldcostmap_rec_type IS RECORD
       (gl_code_combination_id      NUMBER,
        project_id                  NUMBER,
        task_id                     NUMBER,
        award_id                    NUMBER,
        expenditure_organization_id NUMBER,
        expenditure_type            VARCHAR2(30),
        percent                     NUMBER(5,2),
        effective_start_date        DATE,
        effective_end_date          DATE,
--        description                 VARCHAR2(185));	Commented for bug fix 2628089
        description                 VARCHAR2(365));	-- Introduced for bug fix 2628089

 TYPE g_ldcostmap_tbl_type is TABLE OF g_ldcostmap_rec_type
       INDEX BY BINARY_INTEGER;

 g_charging_instructions  g_ldcostmap_tbl_type;

 PROCEDURE create_lines (errbuf           	OUT NOCOPY VARCHAR2,
                         retcode          	OUT NOCOPY VARCHAR2,
                         p_source_type     	IN VARCHAR2,
                         p_source_code     	IN VARCHAR2,
			 p_payroll_id		IN  NUMBER,
                         p_time_period_id  	IN NUMBER,
                         p_batch_name      	IN VARCHAR2,
			 p_business_group_id	IN NUMBER,
			 p_set_of_books_id	IN NUMBER,
                         p_start_asg_id         IN NUMBER,
                         p_end_asg_id           IN NUMBER);

 PROCEDURE Get_Distribution_Lines
           (p_proc_executed       OUT NOCOPY VARCHAR2,
            p_person_id           IN  NUMBER := FND_API.G_MISS_NUM,
            p_sub_line_id         IN  NUMBER := FND_API.G_MISS_NUM,
            p_assignment_id       IN  NUMBER := FND_API.G_MISS_NUM,
            p_element_type_id     IN  NUMBER := FND_API.G_MISS_NUM,
            p_payroll_start_date  IN  DATE   := FND_API.G_MISS_DATE,
            p_daily_rate          IN  NUMBER := FND_API.G_MISS_NUM,
            p_effective_date      IN  DATE   := FND_API.G_MISS_DATE,
            p_mode                IN  VARCHAR2 := 'I',
	    p_business_group_id	  IN  NUMBER,
	    p_set_of_books_id	  IN  NUMBER,
		p_attribute_category	IN	VARCHAR2 default null,		-- Introduced DFF parameters for bug fix 2908859
		p_attribute1		IN	VARCHAR2 default null,
		p_attribute2		IN	VARCHAR2 default null,
		p_attribute3		IN	VARCHAR2 default null,
		p_attribute4		IN	VARCHAR2 default null,
		p_attribute5		IN	VARCHAR2 default null,
		p_attribute6		IN	VARCHAR2 default null,
		p_attribute7		IN	VARCHAR2 default null,
		p_attribute8		IN	VARCHAR2 default null,
		p_attribute9		IN	VARCHAR2 default null,
		p_attribute10		IN	VARCHAR2 default null,
		p_or_gl_ccid		IN	NUMBER DEFAULT NULL,
		p_or_project_id		IN	NUMBER DEFAULT NULL,
		p_or_task_id		IN	NUMBER DEFAULT NULL,
		p_or_award_id		IN	NUMBER DEFAULT NULL,
		p_or_expenditure_org_id	IN	NUMBER DEFAULT NULL,
		p_or_expenditure_type	IN	VARCHAR2 DEFAULT NULL,
            p_return_status       OUT NOCOPY VARCHAR2);

 PROCEDURE global_earnings_element(p_proc_executed       	OUT NOCOPY VARCHAR2,
                                   p_person_id           	IN  NUMBER,
                                   p_sub_line_id         	IN  NUMBER,
                                   p_assignment_id       	IN  NUMBER,
                                   p_element_type_id     	IN  NUMBER,
                                   p_payroll_start_date  	IN  DATE,
                                   p_daily_rate          	IN  NUMBER,
                                   p_org_def_account     	IN  VARCHAR2,
                                   p_effective_date      	IN  DATE,
                                   p_mode                	IN  VARCHAR2 := 'I',
	    			   p_business_group_id	  	IN  NUMBER,
	    			   p_set_of_books_id	  	IN  NUMBER,
				p_attribute_category	IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
				p_attribute1		IN	VARCHAR2,
				p_attribute2		IN	VARCHAR2,
				p_attribute3		IN	VARCHAR2,
				p_attribute4		IN	VARCHAR2,
				p_attribute5		IN	VARCHAR2,
				p_attribute6		IN	VARCHAR2,
				p_attribute7		IN	VARCHAR2,
				p_attribute8		IN	VARCHAR2,
				p_attribute9		IN	VARCHAR2,
				p_attribute10		IN	VARCHAR2,
                                   p_return_status       	OUT NOCOPY VARCHAR2);


 PROCEDURE element_type_hierarchy(p_proc_executed      OUT NOCOPY  VARCHAR2,
                                  p_person_id           IN  NUMBER,
                                  p_sub_line_id         IN  NUMBER,
                                  p_assignment_id       IN  NUMBER,
                                  p_element_type_id     IN  NUMBER,
                                  p_payroll_start_date  IN  DATE,
                                  p_daily_rate          IN  NUMBER,
                                  p_org_def_account     IN  VARCHAR2,
                                  p_effective_date      IN  DATE,
                                  p_mode                IN  VARCHAR2 := 'I',
	    			   p_business_group_id	IN  NUMBER,
	    			   p_set_of_books_id	IN  NUMBER,
				p_attribute_category	IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
				p_attribute1		IN	VARCHAR2,
				p_attribute2		IN	VARCHAR2,
				p_attribute3		IN	VARCHAR2,
				p_attribute4		IN	VARCHAR2,
				p_attribute5		IN	VARCHAR2,
				p_attribute6		IN	VARCHAR2,
				p_attribute7		IN	VARCHAR2,
				p_attribute8		IN	VARCHAR2,
				p_attribute9		IN	VARCHAR2,
				p_attribute10		IN	VARCHAR2,
                                  p_return_status       OUT NOCOPY VARCHAR2);


 PROCEDURE element_class_hierarchy(p_proc_executed      OUT NOCOPY  VARCHAR2,
                                  p_person_id           IN  NUMBER,
                                  p_sub_line_id         IN  NUMBER,
                                  p_assignment_id       IN  NUMBER,
                                  p_element_type_id     IN  NUMBER,
                                  p_payroll_start_date  IN  DATE,
                                  p_daily_rate          IN  NUMBER,
                                  p_org_def_account     IN  VARCHAR2,
                                  p_effective_date      IN  DATE,
                                  p_mode                IN  VARCHAR2 := 'I',
	    			  p_business_group_id	IN  NUMBER,
	    			  p_set_of_books_id	IN  NUMBER,
				p_attribute_category	IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
				p_attribute1		IN	VARCHAR2,
				p_attribute2		IN	VARCHAR2,
				p_attribute3		IN	VARCHAR2,
				p_attribute4		IN	VARCHAR2,
				p_attribute5		IN	VARCHAR2,
				p_attribute6		IN	VARCHAR2,
				p_attribute7		IN	VARCHAR2,
				p_attribute8		IN	VARCHAR2,
				p_attribute9		IN	VARCHAR2,
				p_attribute10		IN	VARCHAR2,
                                  p_return_status       OUT NOCOPY VARCHAR2);


 PROCEDURE assignment_hierarchy(p_proc_executed      OUT NOCOPY  VARCHAR2,
                                p_person_id           IN  NUMBER,
                                p_sub_line_id         IN  NUMBER,
                                p_assignment_id       IN  NUMBER,
                                p_element_type_id     IN  NUMBER,
                                p_payroll_start_date  IN  DATE,
                                p_daily_rate          IN  NUMBER,
                                p_org_def_account     IN  VARCHAR2,
                                p_effective_date      IN  DATE,
                                p_mode                IN  VARCHAR2 := 'I',
	    			p_business_group_id   IN  NUMBER,
	    			p_set_of_books_id     IN  NUMBER,
				p_attribute_category	IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
				p_attribute1		IN	VARCHAR2,
				p_attribute2		IN	VARCHAR2,
				p_attribute3		IN	VARCHAR2,
				p_attribute4		IN	VARCHAR2,
				p_attribute5		IN	VARCHAR2,
				p_attribute6		IN	VARCHAR2,
				p_attribute7		IN	VARCHAR2,
				p_attribute8		IN	VARCHAR2,
				p_attribute9		IN	VARCHAR2,
				p_attribute10		IN	VARCHAR2,
                                p_return_status       OUT NOCOPY VARCHAR2);


 PROCEDURE org_labor_schedule_hierarchy(
                           p_proc_executed      OUT NOCOPY  VARCHAR2,
                           p_person_id           IN  NUMBER,
                           p_sub_line_id         IN  NUMBER,
                           p_assignment_id       IN  NUMBER,
                           p_element_type_id     IN  NUMBER,
                           p_payroll_start_date  IN  DATE,
                           p_daily_rate          IN  NUMBER,
                           p_org_def_account     IN  VARCHAR2,
                           p_effective_date      IN  DATE,
                           p_mode                IN  VARCHAR2 := 'I',
	    		   p_business_group_id	 IN  NUMBER,
	    		   p_set_of_books_id	 IN  NUMBER,
				p_attribute_category	IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
				p_attribute1		IN	VARCHAR2,
				p_attribute2		IN	VARCHAR2,
				p_attribute3		IN	VARCHAR2,
				p_attribute4		IN	VARCHAR2,
				p_attribute5		IN	VARCHAR2,
				p_attribute6		IN	VARCHAR2,
				p_attribute7		IN	VARCHAR2,
				p_attribute8		IN	VARCHAR2,
				p_attribute9		IN	VARCHAR2,
				p_attribute10		IN	VARCHAR2,
                           p_return_status       OUT NOCOPY VARCHAR2);


 PROCEDURE default_account(
                           p_proc_executed      OUT NOCOPY  VARCHAR2,
                           p_person_id           IN  NUMBER,
                           p_sub_line_id         IN  NUMBER,
                           p_assignment_id       IN  NUMBER,
                           p_payroll_start_date  IN  DATE,
                           p_daily_rate          IN  NUMBER,
                           p_default_reason_code IN  VARCHAR2,
                           p_effective_date      IN  DATE,
                           p_mode                IN  VARCHAR2 := 'I',
	    		   p_business_group_id	 IN  NUMBER,
	    		   p_set_of_books_id	 IN  NUMBER,
				p_attribute_category	IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
				p_attribute1		IN	VARCHAR2,
				p_attribute2		IN	VARCHAR2,
				p_attribute3		IN	VARCHAR2,
				p_attribute4		IN	VARCHAR2,
				p_attribute5		IN	VARCHAR2,
				p_attribute6		IN	VARCHAR2,
				p_attribute7		IN	VARCHAR2,
				p_attribute8		IN	VARCHAR2,
				p_attribute9		IN	VARCHAR2,
				p_attribute10		IN	VARCHAR2,
                           p_return_status      OUT NOCOPY  VARCHAR2);


 PROCEDURE suspense_account (
                             p_proc_executed          OUT NOCOPY  VARCHAR2,
                             p_person_id               IN  NUMBER,
                             p_sub_line_id             IN  NUMBER,
                             p_assignment_id           IN  NUMBER,
                             p_payroll_start_date      IN  DATE,
                             p_daily_rate              IN  NUMBER,
                             p_suspense_reason_code    IN  VARCHAR2,
                             p_schedule_line_id        IN  NUMBER,
                             p_default_org_account_id  IN  NUMBER,
                             p_element_account_id      IN  NUMBER,
                             p_org_schedule_id         IN  NUMBER,
                             p_effective_date          IN  DATE,
                             p_mode                    IN  VARCHAR2 := 'I',
	    		     p_business_group_id       IN  NUMBER,
	    		     p_set_of_books_id	       IN  NUMBER,
                             p_dist_line_id            IN  NUMBER,
                             p_return_status          OUT NOCOPY  VARCHAR2);

PROCEDURE Get_Poeta_Description
          (p_project_id       IN NUMBER,
           p_task_id          IN NUMBER,
           p_award_id         IN NUMBER,
           p_organization_id  IN NUMBER,
           p_description     OUT NOCOPY VARCHAR2,
           p_return_status   OUT NOCOPY VARCHAR2) ;

PROCEDURE insert_into_distribution_lines(
	   L_PAYROLL_SUB_LINE_ID         IN	NUMBER,
	   L_DISTRIBUTION_DATE	         IN	DATE,
	   L_EFFECTIVE_DATE		 IN	DATE,
	   L_DISTRIBUTION_AMOUNT	 IN	NUMBER,
 	   L_STATUS_CODE		 IN	VARCHAR2,
	   L_SUSPENSE_REASON_CODE	 IN	VARCHAR2,
           L_DEFAULT_REASON_CODE	 IN	VARCHAR2,
 	   L_SCHEDULE_LINE_ID		 IN	NUMBER,
	   L_DEFAULT_ORG_ACCOUNT_ID	 IN	NUMBER,
           L_SUSPENSE_ORG_ACCOUNT_ID	 IN	NUMBER,
	   L_ELEMENT_ACCOUNT_ID		 IN	NUMBER,
 	   L_ORG_SCHEDULE_ID		 IN	NUMBER,
           L_GL_PROJECT_FLAG		 IN	VARCHAR2,
           L_REVERSAL_ENTRY_FLAG	 IN	VARCHAR2,
           P_GL_CODE_COMBINATION_ID      IN     NUMBER := FND_API.G_MISS_NUM,
           P_PROJECT_ID                  IN     NUMBER := FND_API.G_MISS_NUM,
           P_TASK_ID                     IN     NUMBER := FND_API.G_MISS_NUM,
           P_AWARD_ID                    IN     NUMBER := FND_API.G_MISS_NUM,
           P_EXPENDITURE_ORGANIZATION_ID IN     NUMBER := FND_API.G_MISS_NUM,
           P_EXPENDITURE_TYPE            IN     VARCHAR2 := FND_API.G_MISS_CHAR,
           P_EFFECTIVE_START_DATE        IN     DATE := FND_API.G_MISS_DATE,
           P_EFFECTIVE_END_DATE          IN     DATE := FND_API.G_MISS_DATE,
           P_MODE                        IN     VARCHAR2 := 'I',
	   p_business_group_id		 IN 	NUMBER,
	   p_set_of_books_id		 IN	NUMBER,
		p_attribute_category	IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
		p_attribute1		IN	VARCHAR2,
		p_attribute2		IN	VARCHAR2,
		p_attribute3		IN	VARCHAR2,
		p_attribute4		IN	VARCHAR2,
		p_attribute5		IN	VARCHAR2,
		p_attribute6		IN	VARCHAR2,
		p_attribute7		IN	VARCHAR2,
		p_attribute8		IN	VARCHAR2,
		p_attribute9		IN	VARCHAR2,
		p_attribute10		IN	VARCHAR2,
           p_return_status              OUT NOCOPY     VARCHAR2,
	P_CAP_EXCESS_GLCCID		IN	NUMBER	DEFAULT NULL,
	P_CAP_EXCESS_PROJECT_ID		IN	NUMBER	DEFAULT NULL,
	P_CAP_EXCESS_TASK_ID		IN	NUMBER	DEFAULT NULL,
	P_CAP_EXCESS_AWARD_ID		IN	NUMBER	DEFAULT NULL,
	P_CAP_EXCESS_EXP_ORG_ID		IN	NUMBER	DEFAULT NULL,
	P_CAP_EXCESS_EXP_TYPE		IN	VARCHAR2	DEFAULT NULL);

/*

PROCEDURE autopop(p_acct_type                   IN VARCHAR2,
             	  p_person_id                   IN NUMBER,
		  p_assignment_id               IN NUMBER,
		  p_element_type_id             IN NUMBER,
		  p_project_id                  IN NUMBER,
 		  p_expenditure_organization_id IN NUMBER,
		  p_task_id                     IN NUMBER,
		  p_award_id                    IN NUMBER,
                  p_expenditure_type            IN VARCHAR2,
		  p_gl_code_combination_id      IN NUMBER,
		  p_payroll_start_date          IN DATE,
		  p_effective_date              IN DATE,
 		  p_dist_amount                 IN NUMBER,
		  p_schedule_line_id            IN NUMBER,
                  p_org_schedule_id             IN NUMBER,
		  p_sub_line_id                 IN NUMBER,
                  p_effective_start_date        IN DATE := FND_API.G_MISS_DATE,
                  p_effective_end_date          IN DATE := FND_API.G_MISS_DATE,
                  p_mode                        IN VARCHAR2 := 'I',
		  p_business_group_id		IN NUMBER,
		  p_set_of_books_id		IN NUMBER,
		  p_return_status 		OUT NOCOPY VARCHAR2) ;

 PROCEDURE insert_into_autopop_results(p_distribution_line_id IN NUMBER,
				      p_new_expenditure_type IN VARCHAR2,
				      p_new_gl_code_combination_id IN NUMBER,
				      p_return_status OUT NOCOPY VARCHAR2);



*/

PROCEDURE update_dist_odls_autopop(p_payroll_control_id IN NUMBER,
                                   p_business_group_id IN NUMBER,
                                   p_Set_of_books_id IN NUMBER,
                                   p_start_asg_id in integer,
                                   p_end_asg_id in integer,
                                   p_return_status OUT NOCOPY VARCHAR2);

PROCEDURE update_dist_schedule_autopop(p_payroll_control_id IN NUMBER,
                                   p_business_group_id IN NUMBER,
                                   p_Set_of_books_id IN NUMBER,
                                   p_start_asg_id in integer,
                                   p_end_asg_id in integer,
                                   p_return_status OUT NOCOPY VARCHAR2);

Procedure apply_salary_cap(p_payroll_control_id in integer,
                           p_currency_code      in varchar2,
                                   p_business_group_id IN NUMBER,
                                   p_Set_of_books_id IN NUMBER,
                                   p_start_asg_id in integer,
                                   p_end_asg_id in integer);

procedure cdl_archive(p_payroll_action_id in number,
                           p_chunk_number in number);


procedure Range_code (pactid IN NUMBER, sqlstr out nocopy varchar2);

procedure cdl_init(p_payroll_action_id in number);

procedure excess_account_autopop(p_payroll_control_id in number,
                                 p_business_group_id  in number,
                                 p_set_of_books_id    in number,
                                   p_start_asg_id in integer,
                                   p_end_asg_id in integer,
                                 p_return_status      out nocopy varchar2);

   function get_parameter(name           in varchar2,
                          parameter_list in varchar2) return varchar2;
   pragma restrict_references (get_parameter, wnds, wnps);

TYPE t_integer   IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
t_asg_array t_integer;

procedure asg_action_code (p_pactid IN NUMBER,
                           stasg IN NUMBER,
                           endasg IN NUMBER,
                           p_chunk_num IN NUMBER);

procedure deinit_code(pactid in number);
procedure generic_account_autopop(p_payroll_control_id in number,
                                  p_business_group_id  in number,
                                  p_set_of_books_id    in number,
                                  p_start_asg_id       in integer,
                                  p_end_asg_id         in integer,
                                  p_schedule_type      in varchar2);
function get_retro_parent_element_id(p_cost_id integer) return integer;
END PSP_LABOR_DIST;

/
