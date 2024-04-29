--------------------------------------------------------
--  DDL for Package Body PA_CINT_RATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CINT_RATE_PKG" AS
--$Header: PACINTRB.pls 115.2 2003/06/03 01:34:11 riyengar noship $

procedure print_msg(p_msg  varchar2) IS

Begin
	--r_debug.r_msg('Log:'||p_msg);
	--dbms_output.put_line('Log:'||p_msg);
	Null;

End print_msg;

PROCEDURE insert_row_exp_excl (
        x_rowid                        in out NOCOPY VARCHAR2
        ,p_exp_type                    IN   VARCHAR2
        ,p_org_id                      IN   NUMBER
        ,p_ind_cost_code               IN   VARCHAR2
        ,p_CREATED_BY                  IN   NUMBER
        ,p_CREATION_DATE               IN   DATE
        ,p_LAST_UPDATED_BY             IN   NUMBER
        ,p_LAST_UPDATE_DATE            IN   DATE
        ,p_LAST_UPDATE_LOGIN           IN   NUMBER
        ,x_return_status               OUT NOCOPY  VARCHAR2
        ,x_error_msg_code              OUT NOCOPY  VARCHAR2
                      ) IS

BEGIN
	x_return_status := 'S';
	x_error_msg_code := Null;

	print_msg('inserting row into pa_cint_exp_type_excl_all ');
	INSERT INTO pa_cint_exp_type_excl_all
        ( IND_COST_CODE
 	 ,EXPENDITURE_TYPE
 	 ,ORG_ID
 	 ,CREATION_DATE
 	 ,CREATED_BY
 	 ,LAST_UPDATE_DATE
 	 ,LAST_UPDATED_BY
 	 ,LAST_UPDATE_LOGIN
        ) VALUES
	(p_ind_cost_code
	,p_exp_type
	,p_org_id
	,p_CREATION_DATE
	,p_CREATED_BY
	,p_LAST_UPDATE_DATE
	,p_LAST_UPDATED_BY
	,p_LAST_UPDATE_LOGIN
        );

	/* Retrive the rowid and pass it to Forms */
	Select rowid
	INTO x_rowid
	FROM pa_cint_exp_type_excl_all
	WHERE IND_COST_CODE = p_ind_cost_code
	AND EXPENDITURE_TYPE = p_exp_type
	AND ORG_ID = p_org_id;

	print_msg('Num of rows inserted['||sql%rowcount);
EXCEPTION
	WHEN OTHERS THEN
	        x_return_status := 'E';
        	x_error_msg_code := SQLCODE||SQLERRM;
		RAISE;
END insert_row_exp_excl;

 PROCEDURE update_row_exp_excl
        (p_rowid                       IN   VARCHAR2
        ,p_exp_type                    IN   VARCHAR2
        ,p_org_id                      IN   NUMBER
        ,p_ind_cost_code               IN   VARCHAR2
        ,p_LAST_UPDATED_BY             IN   NUMBER
        ,p_LAST_UPDATE_DATE            IN   DATE
        ,p_LAST_UPDATE_LOGIN           IN   NUMBER
        ,x_return_status               OUT NOCOPY  VARCHAR2
        ,x_error_msg_code              OUT NOCOPY  VARCHAR2
                      )IS


BEGIN

        x_return_status := 'S';
        x_error_msg_code := Null;

	UPDATE pa_cint_exp_type_excl_all
	SET expenditure_type = p_exp_type
           ,LAST_UPDATED_BY =p_LAST_UPDATED_BY
           ,LAST_UPDATE_DATE = p_LAST_UPDATE_DATE
	   ,LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
	WHERE rowid = p_rowid;

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'E';
                x_error_msg_code := SQLCODE||SQLERRM;
                RAISE;

END update_row_exp_excl;


 PROCEDURE  delete_row_exp_excl (p_ind_cost_code in VARCHAR2
                                ,p_exp_type     IN varchar2
                                ,p_org_id       IN NUMBER ) IS

 BEGIN
    	DELETE from pa_cint_exp_type_excl_all
	WHERE  ind_cost_code = p_ind_cost_code
	AND    expenditure_type = p_exp_type
	AND    org_id = p_org_id ;

 EXCEPTION

	when others then
		Raise;
 END delete_row_exp_excl;

 PROCEDURE delete_row_exp_excl (x_rowid      in VARCHAR2) IS

 BEGIN
	NULL;
 END delete_row_exp_excl;

PROCEDURE insert_row_rate_info (
        x_rowid                        in out NOCOPY VARCHAR2
        ,p_org_id                      IN   NUMBER
        ,p_ind_cost_code               IN   VARCHAR2
        ,p_EXP_ORG_SOURCE              IN  VARCHAR2
        ,p_PROJ_AMT_THRESHOLD         IN  NUMBER
        ,p_TASK_AMT_THRESHOLD         IN  NUMBER
        ,p_PROJ_DURATION_THRESHOLD    IN  NUMBER
        ,p_TASK_DURATION_THRESHOLD    IN  NUMBER
        ,p_CURR_PERIOD_CONVENTION      IN  VARCHAR2
        ,p_INTEREST_CALCULATION_METHOD   IN  VARCHAR2
        ,p_THRESHOLD_AMT_TYPE          IN VARCHAR2
        ,p_BUDGET_TYPE_CODE            IN VARCHAR2
        ,p_PERIOD_RATE_CODE            IN VARCHAR2
        ,p_CREATED_BY                  IN   NUMBER
        ,p_CREATION_DATE               IN   DATE
        ,p_LAST_UPDATED_BY             IN   NUMBER
        ,p_LAST_UPDATE_DATE            IN   DATE
        ,p_LAST_UPDATE_LOGIN           IN   NUMBER
        ,x_return_status               OUT NOCOPY  VARCHAR2
        ,x_error_msg_code              OUT NOCOPY  VARCHAR2
                      ) IS

 BEGIN
        x_return_status := 'S';
        x_error_msg_code := Null;

        print_msg('inserting row into pa_cint_rate_info_all ');
        INSERT INTO pa_cint_rate_info_all
        ( IND_COST_CODE
         ,ORG_ID
	 ,EXP_ORG_SOURCE
         ,PROJ_AMT_THRESHOLD
         ,TASK_AMT_THRESHOLD
         ,PROJ_DURATION_THRESHOLD
         ,TASK_DURATION_THRESHOLD
         ,CURR_PERIOD_CONVENTION
         ,INTEREST_CALCULATION_METHOD
         ,THRESHOLD_AMT_TYPE
         ,BUDGET_TYPE_CODE
         ,PERIOD_RATE_CODE
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_LOGIN
        ) VALUES
        (p_ind_cost_code
        ,p_org_id
        ,p_EXP_ORG_SOURCE
        ,p_PROJ_AMT_THRESHOLD
        ,p_TASK_AMT_THRESHOLD
        ,p_PROJ_DURATION_THRESHOLD
        ,p_TASK_DURATION_THRESHOLD
        ,p_CURR_PERIOD_CONVENTION
        ,p_INTEREST_CALCULATION_METHOD
        ,p_THRESHOLD_AMT_TYPE
        ,p_BUDGET_TYPE_CODE
        ,p_PERIOD_RATE_CODE
        ,p_CREATION_DATE
        ,p_CREATED_BY
        ,p_LAST_UPDATE_DATE
        ,p_LAST_UPDATED_BY
        ,p_LAST_UPDATE_LOGIN
        );

        /* Retrive the rowid and pass it to Forms */
        Select rowid
        INTO x_rowid
        FROM pa_cint_rate_info_all
        WHERE IND_COST_CODE = p_ind_cost_code
        AND EXP_ORG_SOURCE = p_EXP_ORG_SOURCE
        AND ORG_ID = p_org_id;

 EXCEPTION
	WHEN OTHERS THEN
                x_return_status := 'E';
                x_error_msg_code := SQLCODE||SQLERRM;
		RAISE;

 END insert_row_rate_info;

 PROCEDURE update_row_rate_info
        (p_rowid                       IN   VARCHAR2
        ,p_org_id                      IN   NUMBER
        ,p_ind_cost_code               IN   VARCHAR2
        ,p_EXP_ORG_SOURCE              IN  VARCHAR2
        ,p_PROJ_AMT_THRESHOLD         IN  NUMBER
        ,p_TASK_AMT_THRESHOLD         IN  NUMBER
        ,p_PROJ_DURATION_THRESHOLD    IN  NUMBER
        ,p_TASK_DURATION_THRESHOLD    IN  NUMBER
        ,p_CURR_PERIOD_CONVENTION      IN  VARCHAR2
        ,p_INTEREST_CALCULATION_METHOD   IN  VARCHAR2
        ,p_THRESHOLD_AMT_TYPE          IN VARCHAR2
        ,p_BUDGET_TYPE_CODE            IN VARCHAR2
        ,p_PERIOD_RATE_CODE            IN VARCHAR2
        ,p_LAST_UPDATED_BY             IN   NUMBER
        ,p_LAST_UPDATE_DATE            IN   DATE
        ,p_LAST_UPDATE_LOGIN           IN   NUMBER
        ,x_return_status               OUT NOCOPY  VARCHAR2
        ,x_error_msg_code              OUT NOCOPY  VARCHAR2
                      )IS

 BEGIN
        x_return_status := 'S';
        x_error_msg_code := Null;

        UPDATE pa_cint_rate_info_all
        SET EXP_ORG_SOURCE = p_EXP_ORG_SOURCE
	   ,PROJ_AMT_THRESHOLD = p_PROJ_AMT_THRESHOLD
	   ,TASK_AMT_THRESHOLD = p_TASK_AMT_THRESHOLD
	   ,PROJ_DURATION_THRESHOLD = p_PROJ_DURATION_THRESHOLD
	   ,TASK_DURATION_THRESHOLD = p_TASK_DURATION_THRESHOLD
	   ,CURR_PERIOD_CONVENTION = p_CURR_PERIOD_CONVENTION
           ,INTEREST_CALCULATION_METHOD = p_INTEREST_CALCULATION_METHOD
           ,THRESHOLD_AMT_TYPE = p_THRESHOLD_AMT_TYPE
           ,BUDGET_TYPE_CODE = p_BUDGET_TYPE_CODE
           ,PERIOD_RATE_CODE  = p_PERIOD_RATE_CODE
           ,LAST_UPDATED_BY =p_LAST_UPDATED_BY
           ,LAST_UPDATE_DATE = p_LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
        WHERE ind_cost_code = p_ind_cost_code
        AND   org_id = p_org_id;

 EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'E';
                x_error_msg_code := SQLCODE||SQLERRM;
                RAISE;

 END update_row_rate_info;

 PROCEDURE  delete_row_rate_info (p_ind_cost_code in VARCHAR2
                                 ,p_org_id       IN NUMBER
                                 )IS

        x_return_status VARCHAR2(1000):= 'S';
        x_error_msg_code VARCHAR2(1000) := Null;

 BEGIN
        DELETE from pa_cint_rate_info_all
        WHERE  ind_cost_code = p_ind_cost_code
        AND    org_id = p_org_id ;

 EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'E';
                x_error_msg_code := SQLCODE||SQLERRM;
                RAISE;

 END delete_row_rate_info;


END PA_CINT_RATE_PKG;

/
