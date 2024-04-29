--------------------------------------------------------
--  DDL for Package Body PA_SALESREPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SALESREPS" AS
/* $Header: PAXITSCB.pls 120.7 2008/04/09 11:32:36 rdegala ship $ */
-----------------------------
--  PROCEDURE IMPLEMENTATIONS
--


PROCEDURE process_project(pj_id  number,
                          req_id number) IS
----------------------------
--  LOCAL CURSOR DECLARATION
--


  CURSOR GetCredits IS
	SELECT 	c.credit_type_code,
		c.salesrep_id,
		c.credit_percentage,
		p.segment1 proj_num,
        pt.cc_prvdr_flag ic_flag,
	(select 'Y' from dual where exists (select 1 from pa_project_customers pc
					    where pc.project_id = p.project_id
					    and pc.bill_another_project_flag='Y'))  ip_flag /* Added for bug 6603869*/
	FROM	pa_credit_receivers c,
		pa_projects p,
                so_sales_credit_types sc,
        pa_project_types pt
	WHERE	c.project_id = p.project_id
	AND	c.project_id = pj_id
	AND	c.transfer_to_ar_flag = 'Y'
        AND     c.credit_type_code    = sc.name
        AND     sc.enabled_flag       = 'Y'
    AND p.project_type = pt.project_type
	ORDER BY c.credit_type_code, c.credit_percentage;

  credit_rec 	GetCredits%ROWTYPE;

/* Added for Bug 2627331 starts here */

CURSOR GetDefaultCredits IS
        SELECT  a.salesrep_id,
                c.segment1 proj_num,
                I.sales_credit_type_code credit_type,
                pt.cc_prvdr_flag ic_flag
        FROM    ra_salesreps a,
                pa_project_players b,
                pa_projects c,
                pa_implementations I,
                pa_project_types pt
        WHERE   c.project_id = b.project_id
        AND     b.project_id = pj_id
        AND     b.project_role_type = 'PROJECT MANAGER'
        AND     b.person_id = a.person_id
        AND     trunc(SYSDATE) BETWEEN b.Start_Date_Active (+)
                            AND NVL(b.End_Date_Active (+), trunc(SYSDATE))
        AND     c.project_type = pt.project_type;

  credit_def_rec    GetDefaultCredits%ROWTYPE;
/* Added for Bug 2627331 ends here */

  CURSOR GetILine_Normal(project_number VARCHAR2) IS
	SELECT	interface_line_context,
		interface_line_attribute1,
		interface_line_attribute2,
		interface_line_attribute3,
		interface_line_attribute4,
		interface_line_attribute5,
		interface_line_attribute6,
		interface_line_attribute7,
                r.allow_sales_credit_flag
	FROM
		ra_interface_lines i,
                pa_draft_invoices inv,
		pa_implementations p,
		ra_batch_sources r
	WHERE
                inv.project_id = pj_id
--        AND     inv.draft_invoice_num = to_number(interface_line_attribute2) commented for bug 5330841
	AND     to_char(inv.draft_invoice_num) = trim(interface_line_attribute2) /* Added for bug 5330841 */
        AND     inv.request_id = req_id
        AND     i.interface_line_attribute1 = project_number
	AND	i.batch_source_name = r.name
	AND	r.batch_source_id = p.invoice_batch_source_id
	AND	i.interface_status IS NULL
;

   CURSOR GetILine_IC(project_number VARCHAR2) IS
	SELECT	interface_line_context,
		interface_line_attribute1,
		interface_line_attribute2,
		interface_line_attribute3,
		interface_line_attribute4,
		interface_line_attribute5,
		interface_line_attribute6,
		interface_line_attribute7,
                r.allow_sales_credit_flag
	FROM
		ra_interface_lines i,
                pa_draft_invoices inv,
		pa_implementations p,
		ra_batch_sources r
	WHERE
                inv.project_id = pj_id
--        AND     inv.draft_invoice_num = to_number(interface_line_attribute2)commented for bug 5330841
	AND     to_char(inv.draft_invoice_num) = trim(interface_line_attribute2) /* Added for bug 5330841 */
        AND     inv.request_id = req_id
        AND     i.interface_line_attribute1 = project_number
	AND	i.batch_source_name = r.name
	AND	r.batch_source_id = nvl(p.cc_ic_ar_batch_source_id,0)
	AND	i.interface_status IS NULL
;

  int_rec		GetILine_Normal%ROWTYPE;
  transfer              CHAR(1);
  v_cnt                 NUMBER :=0 ;
BEGIN
    FOR credit_rec IN GetCredits LOOP
      v_cnt := 1;
      IF (credit_rec.ic_flag = 'N' and NVL(credit_rec.ip_flag,'N') = 'N' ) THEN /* Modified for bug 6603869*/
        FOR int_rec IN GetILine_Normal(credit_rec.proj_num) LOOP
          IF (int_rec.allow_sales_credit_flag = 'Y') THEN
            INSERT INTO ra_interface_salescredits
            (interface_line_context,
  	        interface_line_attribute1,
            interface_line_attribute2,
            interface_line_attribute3,
            interface_line_attribute4,
            interface_line_attribute5,
            interface_line_attribute6,
            interface_line_attribute7,
            salesrep_id,
            sales_credit_type_name,
            sales_credit_percent_split,
            org_id)
            VALUES (int_rec.interface_line_context,
            int_rec.interface_line_attribute1,
   	        int_rec.interface_line_attribute2,
            int_rec.interface_line_attribute3,
            int_rec.interface_line_attribute4,
            int_rec.interface_line_attribute5,
            int_rec.interface_line_attribute6,
            int_rec.interface_line_attribute7,
            credit_rec.salesrep_id,
            credit_rec.credit_type_code,
            credit_rec.credit_percentage,
            PA_MOAC_UTILS.GET_CURRENT_ORG_ID);
            commit;
          END IF;
        END LOOP;
      ELSE
        FOR int_rec IN GetILine_IC(credit_rec.proj_num) LOOP
          IF (int_rec.allow_sales_credit_flag = 'Y') THEN
            INSERT INTO ra_interface_salescredits
            (interface_line_context,
  	        interface_line_attribute1,
            interface_line_attribute2,
            interface_line_attribute3,
            interface_line_attribute4,
            interface_line_attribute5,
            interface_line_attribute6,
            interface_line_attribute7,
            salesrep_id,
            sales_credit_type_name,
            sales_credit_percent_split,
            org_id)
            VALUES (int_rec.interface_line_context,
            int_rec.interface_line_attribute1,
   	        int_rec.interface_line_attribute2,
            int_rec.interface_line_attribute3,
            int_rec.interface_line_attribute4,
            int_rec.interface_line_attribute5,
            int_rec.interface_line_attribute6,
            int_rec.interface_line_attribute7,
            credit_rec.salesrep_id,
            credit_rec.credit_type_code,
            credit_rec.credit_percentage,
            PA_MOAC_UTILS.GET_CURRENT_ORG_ID);
            commit;
          END IF;
        END LOOP;
        /* Added for bug 6958686 */
        IF (NVL(credit_rec.ip_flag,'N') = 'Y' ) THEN
        FOR int_rec IN GetILine_Normal(credit_rec.proj_num) LOOP
          IF (int_rec.allow_sales_credit_flag = 'Y') THEN
            INSERT INTO ra_interface_salescredits
            (interface_line_context,
  	        interface_line_attribute1,
            interface_line_attribute2,
            interface_line_attribute3,
            interface_line_attribute4,
            interface_line_attribute5,
            interface_line_attribute6,
            interface_line_attribute7,
            salesrep_id,
            sales_credit_type_name,
            sales_credit_percent_split,
            org_id)
            VALUES (int_rec.interface_line_context,
            int_rec.interface_line_attribute1,
   	        int_rec.interface_line_attribute2,
            int_rec.interface_line_attribute3,
            int_rec.interface_line_attribute4,
            int_rec.interface_line_attribute5,
            int_rec.interface_line_attribute6,
            int_rec.interface_line_attribute7,
            credit_rec.salesrep_id,
            credit_rec.credit_type_code,
            credit_rec.credit_percentage,
            PA_MOAC_UTILS.GET_CURRENT_ORG_ID);
            commit;
          END IF;
        END LOOP;
       END IF;
       /* End of fix for bug 6958686 */
      END IF;
    END LOOP;

/* Added for Bug 2627331 starts here */
If v_cnt = 0 THEN
  FOR credit_def_rec IN GetDefaultCredits LOOP
    IF (credit_def_rec.ic_flag = 'N' and NVL(credit_rec.ip_flag,'N') = 'N') THEN /* Modified for bug 6603869*/
      FOR int_rec IN GetILine_Normal(credit_def_rec.proj_num) LOOP
        IF (int_rec.allow_sales_credit_flag = 'Y') THEN
          INSERT INTO ra_interface_salescredits
          (interface_line_context,
          interface_line_attribute1,
          interface_line_attribute2,
          interface_line_attribute3,
          interface_line_attribute4,
          interface_line_attribute5,
          interface_line_attribute6,
          interface_line_attribute7,
          salesrep_id,
          sales_credit_type_name,
          sales_credit_percent_split,
		  org_id)
          VALUES (int_rec.interface_line_context,
          int_rec.interface_line_attribute1,
          int_rec.interface_line_attribute2,
          int_rec.interface_line_attribute3,
          int_rec.interface_line_attribute4,
          int_rec.interface_line_attribute5,
          int_rec.interface_line_attribute6,
          int_rec.interface_line_attribute7,
          credit_def_rec.salesrep_id,
          credit_def_rec.credit_type,
          100,
		  PA_MOAC_UTILS.GET_CURRENT_ORG_ID);
          commit;
        END IF;
      END LOOP;
    ELSE
      FOR int_rec IN GetILine_IC(credit_def_rec.proj_num) LOOP
        IF (int_rec.allow_sales_credit_flag = 'Y') THEN
          INSERT INTO ra_interface_salescredits
          (interface_line_context,
          interface_line_attribute1,
          interface_line_attribute2,
          interface_line_attribute3,
          interface_line_attribute4,
          interface_line_attribute5,
          interface_line_attribute6,
          interface_line_attribute7,
          salesrep_id,
          sales_credit_type_name,
          sales_credit_percent_split,
          org_id)
          VALUES (int_rec.interface_line_context,
          int_rec.interface_line_attribute1,
          int_rec.interface_line_attribute2,
          int_rec.interface_line_attribute3,
          int_rec.interface_line_attribute4,
          int_rec.interface_line_attribute5,
          int_rec.interface_line_attribute6,
          int_rec.interface_line_attribute7,
          credit_def_rec.salesrep_id,
          credit_def_rec.credit_type,
          100,
          PA_MOAC_UTILS.GET_CURRENT_ORG_ID);
          commit;
        END IF;
      END LOOP;
              /* Added for bug 6958686 */
        IF (NVL(credit_rec.ip_flag,'N') = 'Y' ) THEN
        FOR int_rec IN GetILine_Normal(credit_rec.proj_num) LOOP
          IF (int_rec.allow_sales_credit_flag = 'Y') THEN
            INSERT INTO ra_interface_salescredits
            (interface_line_context,
  	        interface_line_attribute1,
            interface_line_attribute2,
            interface_line_attribute3,
            interface_line_attribute4,
            interface_line_attribute5,
            interface_line_attribute6,
            interface_line_attribute7,
            salesrep_id,
            sales_credit_type_name,
            sales_credit_percent_split,
            org_id)
            VALUES (int_rec.interface_line_context,
            int_rec.interface_line_attribute1,
   	        int_rec.interface_line_attribute2,
            int_rec.interface_line_attribute3,
            int_rec.interface_line_attribute4,
            int_rec.interface_line_attribute5,
            int_rec.interface_line_attribute6,
            int_rec.interface_line_attribute7,
            credit_rec.salesrep_id,
            credit_rec.credit_type_code,
            credit_rec.credit_percentage,
            PA_MOAC_UTILS.GET_CURRENT_ORG_ID);
            commit;
          END IF;
        END LOOP;
       END IF;
       /* End of fix for bug 6958686 */
    END IF;
  END LOOP;
END IF;
/* Added for Bug 2627331 ends here */
END process_project;

-- Procedure to validate Sales credit type code

PROCEDURE validate_sales_credit_type ( pj_id       IN number,
                                       rej_code   OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
 Cursor get_transfer_status
 is
   SELECT r.allow_sales_credit_flag
   FROM   ra_batch_sources r,
          pa_implementations i
   WHERE  i.invoice_batch_source_id = r.batch_source_id;

  l_transfer    varchar2(1);
  l_dummy       varchar2(1);
  l_step        number;
  l_ord_mgmt_installed_flag VARCHAR2(1);/*Added for credit reciever change*/

BEGIN

--Check whether Sales credit info is to be passed to AR or Not

 open get_transfer_status;

 fetch get_transfer_status into l_transfer;

 close get_transfer_status;

  /*Added for credit reciever change */
l_ord_mgmt_installed_flag :=PA_INSTALL.is_ord_mgmt_installed();

-- If sales credit info is to be passed to AR
IF l_ord_mgmt_installed_flag = 'Y' THEN

 If  l_transfer = 'Y'
 Then

  /*Added for credit reciever change */
  l_step :=0;

   select 'x'
   into   l_dummy
   from dual
   where exists ( select 1
                            from   pa_implementations i,
                                   so_sales_credit_types sc
                           where  i.sales_credit_type_code = sc.name
                             and    sc.enabled_flag    = 'Y'
                  UNION ALL
                          select 1
                            from pa_credit_receivers
                           WHERE  project_id = pj_id
                            AND  transfer_to_ar_flag = 'Y'
			     AND    ROWNUM = 1 );


   l_step  := 10;

   SELECT 'x'
   INTO   l_dummy
   FROM   pa_credit_receivers
   WHERE  project_id = pj_id
   AND    transfer_to_ar_flag = 'Y'
   AND    ROWNUM = 1 ;

   l_step  := 20;

   SELECT 'x'
   INTO   l_dummy
   FROM   sys.dual
   WHERE  exists ( select 'x'
                   from   pa_credit_receivers c,
                          so_sales_credit_types sc
                   where  c.project_id       = pj_id
                   and    c.credit_type_code = sc.name
                   and    c.transfer_to_ar_flag = 'Y'
                   and    sc.enabled_flag    = 'Y' );

/*  Commented for Bug 5376080
l_step := 30 ;
   select 'x'
   into l_dummy
   from dual
   where exists ( select 1
                          from pa_Credit_receivers
			  where project_id = pj_id
			  AND transfer_to_Ar_flag = 'Y'
			  AND sysdate between start_date_Active and end_date_Active
	         ); */

     rej_code := NULL ;


 End If;/*End of l_transfer='Y'*/

ELSE /*Order management is not installed */

 If  l_transfer = 'Y'
 Then

   l_step :=0;

   select 'x'
   into   l_dummy
   from dual
   where exists ( select 1
                            from   pa_implementations i,
                                   pa_lookups pa
                           where  pa.lookup_type='CREDIT TYPE'
                             and  i.sales_credit_type_code = pa.lookup_code
                             and  pa.enabled_flag    = 'Y'
                  UNION ALL
                          select 1
                            from pa_credit_receivers
                           WHERE  project_id = pj_id
                             AND  transfer_to_ar_flag = 'Y'
                             AND  ROWNUM = 1 );

   l_step  := 10;

   SELECT 'x'
   INTO   l_dummy
   FROM   pa_credit_receivers
   WHERE  project_id = pj_id
   AND    transfer_to_ar_flag = 'Y'
   AND    ROWNUM = 1 ;

   l_step  := 20;

   SELECT 'x'
   INTO   l_dummy
   FROM   sys.dual
   WHERE  exists ( select 'x'
                   from   pa_credit_receivers c,
                          pa_lookups pa
                   where  c.project_id       = pj_id
                   and    pa.lookup_type='CREDIT TYPE'
                   and    c.credit_type_code = pa.lookup_code
                   and    c.transfer_to_ar_flag = 'Y'
                   and    pa.enabled_flag    = 'Y' );

/*  Commented for Bug 5376080
l_step := 30 ;

   select 'x'
   into l_dummy
   from dual
   where exists ( select 1
                          from pa_Credit_receivers
			  where project_id = pj_id
			  AND transfer_to_Ar_flag = 'Y'
			  AND sysdate between start_date_active and end_date_Active
	         ); */

     rej_code := NULL ;


 End If;

END IF;/*Order management installed*/


EXCEPTION

 When NO_DATA_FOUND
 Then
    if l_step =0
    Then
      rej_code :='PA_INV_SALES_CREDIT';
    elsif l_step = 20
    Then
      rej_code := 'PA_DISAB_CRD_TYP';

/*  Commented for Bug 5376080
    Elsif l_step =30
    then
      rej_code := 'PA_CREDIT_RECEIVER_END_DATED'; */
    Else
      rej_code := NULL;
    End if;

END validate_sales_credit_type;


END pa_salesreps;

/
