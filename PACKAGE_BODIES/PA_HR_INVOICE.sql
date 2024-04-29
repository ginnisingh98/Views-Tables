--------------------------------------------------------
--  DDL for Package Body PA_HR_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_HR_INVOICE" AS
/* $Header: PAHRINVB.pls 120.2 2005/08/16 15:39:45 hsiu noship $ */
--
  --
  PROCEDURE check_person_reference (p_person_id       IN number,
                                    Error_Message    OUT NOCOPY varchar2,
                                    Reference_Exist  OUT NOCOPY varchar2)
  IS
     reference_exists  exception;
     dummy1            varchar2(1);

     cursor credit_receiv( p_person_id number ) is
               select  null
                from    pa_credit_receivers             pa
                where   pa.person_id                    = P_PERSON_ID;

     cursor draft_inv( p_person_id number ) is
                select  null
                from    pa_draft_invoices_all               pa
                where   pa.approved_by_person_id        = P_PERSON_ID
                or      pa.released_by_person_id        = P_PERSON_ID;

  BEGIN

      Error_Message := 'PA_HR_PER_CREDIT_RECEIV';
      OPEN credit_receiv(p_person_id);
      FETCH credit_receiv INTO dummy1;
      IF credit_receiv%found THEN
         CLOSE credit_receiv;
         raise reference_exists;
      END IF;
      CLOSE credit_receiv;

      Error_Message := 'PA_HR_PER_DRAFT_INV';
      OPEN draft_inv(p_person_id);
      FETCH draft_inv INTO dummy1;
      IF draft_inv%found THEN
         CLOSE draft_inv;
         raise reference_exists;
      END IF;
      CLOSE draft_inv;

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
  BEGIN
      Reference_Exist := 'N';
      Error_Message   := NULL;
  END check_job_reference;
END pa_hr_invoice      ;

/
