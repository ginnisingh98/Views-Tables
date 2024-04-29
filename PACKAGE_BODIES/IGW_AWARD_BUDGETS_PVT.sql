--------------------------------------------------------
--  DDL for Package Body IGW_AWARD_BUDGETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_AWARD_BUDGETS_PVT" AS
--$Header: igwvabtb.pls 120.9 2006/04/29 20:19:03 vmedikon ship $

PROCEDURE VALIDATE_EXPENDITURE_TYPE
(p_expenditure_type_category	 IN  VARCHAR2
 ,x_expenditure_type_category    OUT NOCOPY VARCHAR2
 ,x_expenditure_category_flag    OUT NOCOPY VARCHAR2
 --,x_budget_category_code       OUT NOCOPY VARCHAR2
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_error_msg_code               OUT NOCOPY VARCHAR2) IS



BEGIN

  null;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.add_exc_msg(p_pkg_name       => 'IGW_PROPOSALS_ALL_PVT',
                            p_procedure_name => 'VALIDATE_EXPENDITURE_TYPE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    RAISE;
END; --VALIDATE_EXPENDITURE_TYPE

--------------------------------------------------------------------------------------------


  -- Above procedure has been modified by Debashis to apply the following constraint
  -- For a project and task you cannot have lines with Expenditure Category and
  -- with an expenditure type belonging to that category. If Task is blank then
  -- for a project you cannot have lines with Expenditure Category and with an
  -- expenditure type belonging to that category

  PROCEDURE validate_expenditure_level(
    p_proposal_id                  IN    VARCHAR2
   ,p_award_budget_id              IN    VARCHAR2
   ,p_project_id		   IN    NUMBER
   ,p_task_id			   IN    NUMBER
   ,p_expenditure_type_cat         IN    VARCHAR2
   ,p_expenditure_category_flag    IN    VARCHAR2
   ,x_return_status                OUT NOCOPY   VARCHAR2
   ,x_error_msg_code               OUT NOCOPY   VARCHAR2) IS

   x_exists     VARCHAR2(1);
   l_personnel_attached_flag    VARCHAR2(1);
   l_parent_category            VARCHAR2(50);

  BEGIN
   null;

  EXCEPTION
    when others then
       x_return_status := 'U';
       x_error_msg_code := SQLCODE||SQLERRM;
  END validate_expenditure_level;
-----------------------------------------------------------------------------------------
 PROCEDURE validate_resource_expenditure(p_project_id                 IN    NUMBER
				  	,p_expenditure_type 	      IN    VARCHAR2
					,p_expenditure_category_flag  IN    VARCHAR2
					,x_time_phased_type_code      OUT NOCOPY   VARCHAR2
	  			  	,x_return_status              OUT NOCOPY   VARCHAR2
				  	,x_msg_data                   OUT NOCOPY   VARCHAR2)
 IS


  l_resource_list_id               NUMBER(15);
  l_budget_entry_method_code       VARCHAR2(30);
  l_group_resource_type_id   	   NUMBER(15);
  l_categorization_code            VARCHAR2(30); --bug 3523294

  l_entry_level_code               VARCHAR2(1);
  l_time_phased_type_code          VARCHAR2(1);
  l_resource_class_code            VARCHAR2(30);
  l_resource_type_code             VARCHAR2(30);
  l_resource_list_member_id        NUMBER;
  l_resource_list_name             VARCHAR2(60);

  BEGIN
    null;
   EXCEPTION
     WHEN others THEN
     x_return_status := 'U';
     x_msg_data := (SQLCODE||' '||SQLERRM);
     fnd_msg_pub.add_exc_msg(G_package_name, 'VALIDATE_RESOURCE_EXPENDITURE');
   END; --validate_resource_expenditure
----------------------------------------------------------------------------------------
   procedure get_boundary_dates(p_project_id          in number
                                ,p_award_id           in number
				,x_budget_start_date  out NOCOPY date
				,x_budget_end_date    out NOCOPY date) is
     l_awd_start_date    date;
     l_awd_end_date      date;
     l_proj_start_date   date;
     l_proj_end_date     date;
   begin
     null;
  end;
-----------------------------------------------------------------------------------------
  procedure get_min_max_period(p_time_phased_type_code   in varchar2
                               ,p_start_date             in date
			       ,p_end_date               in date
                               ,x_min_period             out NOCOPY varchar2
			       ,x_max_period             out NOCOPY varchar2) is
  begin
    null;
  end;

-----------------------------------------------------------------------------------------
  PROCEDURE create_award_budget
        (p_init_msg_list              IN     VARCHAR2   :=  FND_API.G_TRUE
        ,p_commit                     IN     VARCHAR2   :=  FND_API.G_FALSE
        ,p_validate_only              IN     VARCHAR2   :=  FND_API.G_TRUE
	,p_proposal_id		      IN     NUMBER
	,p_proposal_installment_id    IN     NUMBER     := NULL
        ,p_budget_period_id           IN     NUMBER
        ,p_expenditure_type_cat       IN     VARCHAR2
        ,p_expenditure_category_flag  IN     VARCHAR2
        ,p_budget_amount              IN     NUMBER     := 0
        ,p_indirect_flag              IN     VARCHAR2
        ,p_project_id                 IN     NUMBER     :=NULL
	,p_project_number             IN     VARCHAR2
        ,p_task_id                    IN     NUMBER     :=NULL
	,p_task_number                IN     VARCHAR2
        ,p_award_id                   IN     NUMBER     :=NULL
	,p_award_number               IN     VARCHAR2
	,p_period_name                IN     VARCHAR2
        ,p_start_date                 IN     DATE
        ,p_end_date                   IN     DATE
        ,p_transferred_flag	      IN     VARCHAR2
	,x_award_budget_id            OUT NOCOPY    NUMBER
        ,x_rowid                      OUT NOCOPY    ROWID
        ,x_return_status              OUT NOCOPY    VARCHAR2
        ,x_msg_count                  OUT NOCOPY    NUMBER
        ,x_msg_data                   OUT NOCOPY    VARCHAR2) IS


  l_api_name                   VARCHAR2(30)    :='CREATE_AWARD_BUDGET';
  l_expenditure_type           VARCHAR2(80)     :=p_expenditure_type_cat;
  l_expenditure_category_flag  VARCHAR2(1)      :=p_expenditure_category_flag;
  l_proposal_id                NUMBER           :=p_proposal_id;
  l_budget_period_id           NUMBER           :=p_budget_period_id;
  l_project_id                 NUMBER           :=p_project_id;
  l_project_number             VARCHAR2(25);
  l_task_id                    NUMBER           :=p_task_id;
  l_award_id                   NUMBER           :=p_award_id;
  l_start_date                 DATE             :=p_start_date;
  l_end_date                   DATE             :=p_end_date;
  l_budget_start_date          DATE;
  l_budget_end_date            DATE;
  l_period_name                VARCHAR2(30);
  l_time_phased_type_code      VARCHAR2(1);
  l_version_id                 NUMBER;
  l_entry_level_code           VARCHAR2(1);
  l_budget_entry_method        VARCHAR2(80);
  l_apply_setup_inflation      VARCHAR2(1);
  l_award_budget_id            NUMBER;
  l_return_status              VARCHAR2(1);
  l_msg_count                  NUMBER;
  l_data                       VARCHAR2(250);
  l_msg_index_out              NUMBER;
  l_awd_start_date		DATE;
  l_awd_end_date		DATE;
  l_proj_start_date		DATE;
  l_proj_end_date		DATE;
  l_min_period                 VARCHAR2(20);
  l_max_period                 VARCHAR2(20);

BEGIN
  null;

END; --CREATE AWARD BUDGET


------------------------------------------------------------------------------------------
  PROCEDURE update_award_budget
        (p_init_msg_list              IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                     IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only              IN    VARCHAR2   := FND_API.G_TRUE
        ,p_award_budget_id            IN    NUMBER
	,p_proposal_id		      IN    NUMBER     := NULL
	,p_proposal_installment_id    IN    NUMBER     := NULL
        ,p_budget_period_id           IN    NUMBER     := NULL
        ,p_expenditure_type_cat       IN    VARCHAR2
        ,p_expenditure_category_flag  IN    VARCHAR2
        ,p_budget_amount              IN    NUMBER     := 0
        ,p_indirect_flag              IN    VARCHAR2
        ,p_project_id                 IN    NUMBER
	,p_project_number             IN    VARCHAR2
        ,p_task_id                    IN    NUMBER
	,p_task_number                IN    VARCHAR2
        ,p_award_id                   IN    NUMBER
	,p_award_number               IN    VARCHAR2
	,p_period_name                IN    VARCHAR2
        ,p_start_date                 IN    DATE
        ,p_end_date                   IN    DATE
        ,p_transferred_flag	      IN    VARCHAR2
        ,p_record_version_number      IN    NUMBER
        ,p_rowid                      IN    ROWID
        ,x_return_status              OUT NOCOPY   VARCHAR2
        ,x_msg_count                  OUT NOCOPY   NUMBER
        ,x_msg_data                   OUT NOCOPY   VARCHAR2) IS

  l_api_name                   VARCHAR2(30)     :='UPDATE_AWARD_BUDGET';
  l_expenditure_type           VARCHAR2(80)     :=p_expenditure_type_cat;   -- bug 4518298
  l_expenditure_category_flag  VARCHAR2(1)      :=p_expenditure_category_flag;
  l_proposal_id                NUMBER           :=p_proposal_id;
  l_budget_period_id           NUMBER           :=p_budget_period_id;
  l_project_id                 NUMBER           :=p_project_id;
  l_project_number             VARCHAR2(25);
  l_task_id                    NUMBER           :=p_task_id;
  l_award_id                   NUMBER           :=p_award_id;
  l_start_date                 DATE             :=p_start_date;
  l_end_date                   DATE             :=p_end_date;
  l_budget_start_date          DATE;
  l_budget_end_date            DATE;
  l_version_id                 NUMBER;
  l_period_name                VARCHAR2(30);
  l_time_phased_type_code      VARCHAR2(1);
  l_entry_level_code           VARCHAR2(1);
  l_budget_entry_method        VARCHAR2(80);
  l_return_status              VARCHAR2(1);
  l_msg_count                  NUMBER;
  l_data                       VARCHAR2(250);
  l_msg_index_out              NUMBER;
  l_dummy                      VARCHAR2(1);
  l_awd_start_date		DATE;
  l_awd_end_date		DATE;
  l_proj_start_date		DATE;
  l_proj_end_date		DATE;
  l_min_period                 VARCHAR2(20);
  l_max_period                 VARCHAR2(20);

BEGIN
 null;

END; --UPDATE BUDGET LINE

-------------------------------------------------------------------------------------------

PROCEDURE delete_award_budget
        (p_init_msg_list                IN  VARCHAR2   :=  FND_API.G_TRUE
        ,p_commit                       IN  VARCHAR2   :=  FND_API.G_FALSE
        ,p_validate_only                IN  VARCHAR2   :=  FND_API.G_TRUE
        ,p_award_budget_id              IN  NUMBER
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2) IS

  l_api_name                   VARCHAR2(30)    :='DELETE_AWARD_BUDGET';
  l_proposal_installment_id    NUMBER(15);
  l_return_status              VARCHAR2(1);
  l_msg_count                  NUMBER;
  l_data                       VARCHAR2(250);
  l_msg_index_out              NUMBER;
  l_dummy                      VARCHAR2(1);
  l_count                      NUMBER(10);



BEGIN
    null;

END; --DELETE AWARD BUDGET
----------------------------------------------------------------------------------

procedure apply_project_award
        (p_award_budget_id              IN  NUMBER
        ,p_proposal_installment_id      IN  NUMBER
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2) is

  cursor c_award_budget is
  select project_id
  ,      task_id
  ,      period_name
  from   igw_award_budgets
  where  award_budget_id = p_award_budget_id;

  cursor c_budget_lines is
  select *
  from   igw_award_budgets
  where  proposal_installment_id = p_proposal_installment_id
  and    award_budget_id <> p_award_budget_id;


  l_project_id         NUMBER(15);
  l_task_id            NUMBER(15);
  l_award_id           NUMBER(15);
  l_msg_count          NUMBER(15);
  l_msg_index_out      NUMBER(15);
  l_period_name        VARCHAR2(20);
  l_period_name_mod    VARCHAR2(20);
  l_time_phased_type_code  VARCHAR2(30);
  l_entry_level_code   VARCHAR2(30);
  l_boundary_start_date DATE;
  l_boundary_end_date   DATE;
  l_period_start_date DATE;
  l_period_end_date   DATE;

begin

null;

end;

-----------------------------
procedure get_time_phased_type_code
		(p_proposal_installment_id      IN  NUMBER
         	,x_time_phased_type_code	OUT NOCOPY VARCHAR2
         	,x_return_status                OUT NOCOPY VARCHAR2
         	,x_msg_count                    OUT NOCOPY NUMBER
         	,x_msg_data                     OUT NOCOPY VARCHAR2) is

  l_project_id  		NUMBER;
  l_time_phased_type_code 	VARCHAR2(30);
  l_msg_count          		NUMBER(15);
  l_msg_index_out      		NUMBER(15);

  BEGIN
   null;
  END;

  ---------------------------------------------------------------------------------------------------
   FUNCTION get_current_budget(p_award_id	IN	NUMBER
   			      ,p_project_id  	IN	NUMBER
  			      ,p_task_id  	IN	NUMBER) return NUMBER IS

  current_budget 	number;
  begin

    null;
  end;
----------------------------------------------------------------------------------------------------------
 FUNCTION get_additional_budget(p_proposal_installment_id	IN	NUMBER
   			       ,p_project_id  			IN	NUMBER
  			       ,p_task_id  			IN	NUMBER) return NUMBER IS

  additional_budget 	number;
  begin
    null;
  end;

  -----------------------------------------------------------------------------------------------
  FUNCTION get_award_created_flag(p_proposal_award_id	IN      NUMBER) return VARCHAR2 IS

  award_created_flag    VARCHAR2(1) := 'N';
  l_transfer_as         VARCHAR2(30);
  l_transferred_flag    VARCHAR2(30);


  begin
    null;
   end;
   --------------------------------------------------------------------------------------------------
  FUNCTION get_installment_created_flag(p_proposal_award_id	IN      NUMBER) return VARCHAR2 IS

  installment_created_flag    VARCHAR2(1) := 'N';
  l_transfer_as         VARCHAR2(30);
  l_transferred_flag    VARCHAR2(30);


  begin
   null;
   end;
--------------------------------------------------------------------------------------------
   FUNCTION get_award_budget_created_flag(p_proposal_installment_id	IN      NUMBER) return VARCHAR2 IS

   lines    number;
   lines_not_transferred  number;
   award_budget_created_flag   varchar2(1) := 'N';

   begin
     null;
   end;
-------------------------------------------------------------------------------------------------------
  FUNCTION get_award_budget_creation_date(p_proposal_installment_id	IN      NUMBER) return DATE IS

  award_budget_creation_date   date := null;

  begin
   null;
  end;
----------------------------------------------------------------------------------------------------------
   FUNCTION get_award_number(p_proposal_award_id	IN      NUMBER) return VARCHAR2 IS

  v_award_number   VARCHAR2(15);
  award_num_code   VARCHAR2(25);

  begin
    null;
  end;

END; --end package

/
