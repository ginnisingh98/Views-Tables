--------------------------------------------------------
--  DDL for Package Body PA_HR_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_HR_TRANSACTIONS" AS
/* $Header: PAHRTRXB.pls 120.1.12010000.2 2009/05/05 09:58:56 jjgeorge ship $ */
--
  --
  PROCEDURE check_person_reference (p_person_id       IN number,
                                    Error_Message    OUT NOCOPY varchar2,
                                    Reference_Exist  OUT NOCOPY varchar2)
  IS
     reference_exists  exception;
     dummy1            varchar2(1);

     cursor trans_interface( p_person_id number ) is
                select  null
                from    PA_TRANSACTION_INTERFACE_ALL         pa,
                        --FP M CWK changes
                        --PER_PEOPLE_F                        ppf
                        PER_ALL_PEOPLE_F                        ppf
                --where   pa.employee_number         = ppf.employee_number
                where   pa.employee_number         in (ppf.employee_number, ppf.npw_number)
                and     ppf.person_id              = P_PERSON_ID
                AND     pa.transaction_status_code <> 'A';

     cursor routing( p_person_id number ) is
                select  null
                from    PA_ROUTINGS         pa
                where   pa.routed_from_person_id         = P_PERSON_ID
                        OR  pa.routed_to_person_id       = P_PERSON_ID;

/* *********
     cursor pte_multi_org( p_person_id number ) is
                select  null
                from    PA_PTE_MULTI_ORG_EMP_MAP         pa
                where   pa.person_id                    = P_PERSON_ID;
**** */

     cursor online_exp( p_person_id number ) is
                select  null
                from    PA_ONLINE_EXP_SETTINGS         pa
                where   pa.person_id                    = P_PERSON_ID;

     cursor exp_comment( p_person_id number ) is
                select  null
                from    PA_EXPEND_COMMENT_ALIASES         pa
                where   pa.person_id                    = P_PERSON_ID;

/*   Commented for Bug#3211124
     cursor ei_denorm( p_person_id number ) is
                select  null
                from    PA_EI_DENORM         pa
                where   pa.person_id       = P_PERSON_ID;
* Commented code for Bug#3211124 ends here */

     cursor expenditure( p_person_id number ) is
                select  null
                from    pa_expenditures_all                 pa
                where   pa.incurred_by_person_id        = P_PERSON_ID;

     cursor trans_control( p_person_id number ) is
                select  null
                from    pa_transaction_controls         pa
                where   pa.project_id > -1
                  and   pa.person_id                    = P_PERSON_ID;
  BEGIN
      Error_Message := 'PA_HR_PER_TRANS_INTERFACE';
      OPEN trans_interface(p_person_id);
      FETCH trans_interface INTO dummy1;
      IF trans_interface%found THEN
         CLOSE trans_interface;
         raise reference_exists;
      END IF;
      CLOSE trans_interface;

      /* Bug#3211124 - Take care of the case - id support introduced in FP K */
      BEGIN
      SELECT null
      INTO   dummy1
      FROM   pa_transaction_interface_all
      WHERE  person_id = p_person_id
      AND    transaction_status_code <> 'A'
      AND    rownum = 1;

      RAISE reference_exists;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
       NULL;
      END;


      Error_Message := 'PA_HR_PER_ROUTING_FROM';
      OPEN routing(p_person_id);
      FETCH routing INTO dummy1;
      IF routing%found THEN
         CLOSE routing;
         raise reference_exists;
      END IF;
      CLOSE routing;

/* ****
      Error_Message := 'PA_HR_PER_PTE_MULTI_ORG';
      OPEN pte_multi_org(p_person_id);
      FETCH pte_multi_org INTO dummy1;
      IF pte_multi_org%found THEN
         CLOSE pte_multi_org;
         raise reference_exists;
      END IF;
      CLOSE pte_multi_org;
**** */

      Error_Message := 'PA_HR_PER_ONLINE_SETTING';
      OPEN online_exp(p_person_id);
      FETCH online_exp INTO dummy1;
      IF online_exp%found THEN
         CLOSE online_exp;
         raise reference_exists;
      END IF;
      CLOSE online_exp;

      Error_Message := 'PA_HR_PER_EXPEND_COMMENT';
      OPEN exp_comment(p_person_id);
      FETCH exp_comment INTO dummy1;
      IF exp_comment%found THEN
         CLOSE exp_comment;
         raise reference_exists;
      END IF;
      CLOSE exp_comment;

 /* Commented for Bug#3211124
      Error_Message := 'PA_HR_PER_EI_DENORM';
      OPEN ei_denorm(p_person_id);
      FETCH ei_denorm INTO dummy1;
      IF ei_denorm%found THEN
         CLOSE ei_denorm;
         raise reference_exists;
      END IF;
      CLOSE ei_denorm;
* Commented code for Bug#3211124 ends here */

      Error_Message := 'PA_HR_PER_EXPENDITURE';
      OPEN expenditure(p_person_id);
      FETCH expenditure INTO dummy1;
      IF expenditure%found THEN
         CLOSE expenditure;
         raise reference_exists;
      END IF;
      CLOSE expenditure;

      Error_Message := 'PA_HR_PER_TRANS_CONTROL';
      OPEN trans_control(p_person_id);
      FETCH trans_control INTO dummy1;
      IF trans_control%found THEN
         CLOSE trans_control;
         raise reference_exists;
      END IF;
      CLOSE trans_control;

      Reference_Exist := 'N';
      Error_Message   := NULL;
      EXCEPTION
        WHEN reference_exists  THEN
          Reference_Exist := 'Y';
        WHEN others  THEN
          raise;
  END check_person_reference;

  PROCEDURE check_job_reference    (p_job_id          IN number,
                                    Error_Message    OUT NOCOPY varchar2,
                                    Reference_Exist  OUT NOCOPY varchar2)
  IS
     reference_exists  exception;
     dummy1            varchar2(1);

/*
     cursor expenditure( p_job_id    varchar ) is
            SELECT 'Y'
              FROM DUAL
             WHERE EXISTS (
                select  null
                from    pa_expenditure_items_all      pa
                where   (pa.job_id    is not null
                        AND pa.job_id      = P_JOB_ID)
                        OR
                        (pa.bill_job_id is not null
                        AND pa.bill_job_id = P_JOB_ID));
			*/


 --Bug 8242639  / 8370836
cursor expenditure( p_job_id    varchar ) is
 SELECT 'Y'
   FROM
    DUAL WHERE EXISTS
        (( SELECT NULL FROM PA_EXPENDITURE_ITEMS_ALL PA WHERE
           PA.JOB_ID IS NOT NULL AND PA.JOB_ID = P_JOB_ID )
           UNION
           (SELECT NULL FROM PA_EXPENDITURE_ITEMS_ALL PA WHERE
            PA.BILL_JOB_ID IS NOT  NULL AND PA.BILL_JOB_ID = P_JOB_ID )
         );

/* Commented for Bug#3211124
     cursor ei_denorm( p_job_id    varchar ) is
                select  null
                from    pa_ei_denorm      pa
                where (pa.job_id_1 is not null
                         AND pa.job_id_1         = P_JOB_ID )
                       OR (pa.job_id_2 is not null
                         AND pa.job_id_2         = P_JOB_ID )
                       OR (pa.job_id_3 is not null
                         AND pa.job_id_3         = P_JOB_ID )
                       OR (pa.job_id_4 is not null
                         AND pa.job_id_4         = P_JOB_ID )
                       OR (pa.job_id_5 is not null
                         AND pa.job_id_5         = P_JOB_ID )
                       OR (pa.job_id_6 is not null
                         AND pa.job_id_6         = P_JOB_ID )
                       OR (pa.job_id_7 is not null
                         AND pa.job_id_7         = P_JOB_ID );
* Commented code for Bug#3211124 ends here */

    /* Added for Bug#3211124 */
    cursor oit_expenditures is
    select * from pa_expenditures_all
    where  expenditure_class_code  = 'PT'
    and    expenditure_status_code = 'APPROVED'
    and    transfer_status_code    = 'P';

    cursor ei_denorm(p_exp_id number) is
    select expenditure_item_date_1, quantity_1,
           expenditure_item_date_2, quantity_2,
           expenditure_item_date_3, quantity_3,
           expenditure_item_date_4, quantity_4,
           expenditure_item_date_5, quantity_5,
           expenditure_item_date_6, quantity_6,
           expenditure_item_date_7, quantity_7,
	   person_id
    from   pa_ei_denorm
    where  expenditure_id = p_exp_id;

  BEGIN
      Error_Message := 'PA_HR_JOB_ONLINE_EXPEND';
/* Commented for Bug#3211124
      OPEN ei_denorm(p_job_id);
      FETCH ei_denorm INTO dummy1;
      IF ei_denorm%found THEN
         raise reference_exists;
      END IF;
* Commented code for Bug#3211124 ends here */

    for oit_exp_rec in oit_expenditures loop
      for ei_denorm_rec in ei_denorm(oit_exp_rec.expenditure_id) loop
        if (ei_denorm_rec.quantity_1 is not null) then
          if pa_utils.GetEmpJobId(ei_denorm_rec.person_id, ei_denorm_rec.expenditure_item_date_1) = P_JOB_ID then
             raise reference_exists;
          end if;
	end if;
        if (ei_denorm_rec.quantity_2 is not null) then
          if  pa_utils.GetEmpJobId(ei_denorm_rec.person_id, ei_denorm_rec.expenditure_item_date_2) = P_JOB_ID then
             raise reference_exists;
          end if;
	end if;
        if (ei_denorm_rec.quantity_3 is not null) then
          if  pa_utils.GetEmpJobId(ei_denorm_rec.person_id, ei_denorm_rec.expenditure_item_date_3) = P_JOB_ID then
             raise reference_exists;
          end if;
	end if;
        if (ei_denorm_rec.quantity_4 is not null) then
          if  pa_utils.GetEmpJobId(ei_denorm_rec.person_id, ei_denorm_rec.expenditure_item_date_4) = P_JOB_ID then
             raise reference_exists;
          end if;
	end if;
        if (ei_denorm_rec.quantity_5 is not null) then
          if  pa_utils.GetEmpJobId(ei_denorm_rec.person_id, ei_denorm_rec.expenditure_item_date_5) = P_JOB_ID then
             raise reference_exists;
          end if;
	end if;
        if (ei_denorm_rec.quantity_6 is not null) then
          if  pa_utils.GetEmpJobId(ei_denorm_rec.person_id, ei_denorm_rec.expenditure_item_date_6) = P_JOB_ID then
             raise reference_exists;
          end if;
	end if;
        if (ei_denorm_rec.quantity_7 is not null) then
          if  pa_utils.GetEmpJobId(ei_denorm_rec.person_id, ei_denorm_rec.expenditure_item_date_7) = P_JOB_ID then
             raise reference_exists;
          end if;
        end if;
      end loop;
    end loop;

      Error_Message := 'PA_HR_JOB_EXPEND_ITEM';
      OPEN expenditure(p_job_id);
      FETCH expenditure INTO dummy1;
      IF expenditure%found THEN
         raise reference_exists;
      END IF;

      Reference_Exist := 'N';
      Error_Message   := NULL;
      EXCEPTION
        WHEN reference_exists  THEN
          Reference_Exist := 'Y';
        WHEN others  THEN
          raise;
  END check_job_reference;
--
END pa_hr_transactions ;

/
