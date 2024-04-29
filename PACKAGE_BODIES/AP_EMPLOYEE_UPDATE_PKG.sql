--------------------------------------------------------
--  DDL for Package Body AP_EMPLOYEE_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_EMPLOYEE_UPDATE_PKG" AS
/* $Header: aphrupdb.pls 120.7.12010000.4 2010/05/19 21:30:50 bgoyal ship $ */

-- Performance fix for 115.9 , ARU 2628027
--  Add global variable to capture business_group_id

   g_business_group_id    FINANCIALS_SYSTEM_PARAMETERS.BUSINESS_GROUP_ID%TYPE;


/* This is a print procedure to split a message string into 132 character
strings. */

PROCEDURE Print
        (
        P_debug                 IN      VARCHAR2,
        P_string                IN      VARCHAR2
        ) IS

  stemp    VARCHAR2(80);
  nlength  NUMBER := 1;

BEGIN

  IF (P_Debug in ('y','Y')) THEN
     WHILE(length(P_string) >= nlength)
     LOOP

        stemp := substrb(P_string, nlength, 80);
        fnd_file.put_line(FND_FILE.LOG, stemp);
        nlength := (nlength + 80);

     END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Print;



FUNCTION Update_Employee(
                p_update_date           IN      DATE,
                p_from_supplier         IN      VARCHAR2,
                p_to_supplier           IN      VARCHAR2,
                p_debug_mode            IN      VARCHAR2,
                p_calling_sequence      IN      VARCHAR2)
                RETURN BOOLEAN  IS
--  ARU 2628027 , change for 115.9 Performance
--  Removed reference to FINANCIALS_SYSTEM_PARAMETERS in all the CURSORS below
--  to avoid CARTESIAN JOIN. Since join to FINANCIALS_SYSTEM_PARAMETERS was only to
--  get the business_group_id , the value is obtained beforehand
--  and referenced in each query below as a bind variable


 -- BUG 4065699 -  The vendor site code will be compared with the lookup value from
 -- hr_lookups and not the hardcoded value as earlier

  /* Cursor For Name Change where p_from_supplier and p_to_supplier is null*/
  CURSOR name_cur IS
  SELECT /*DECODE(ppf.middle_names,
         null, ppf.last_name||', '||ppf.first_name,
               ppf.last_name||', '||ppf.first_name||' '||ppf.middle_names) Bug9615008 */
        ppf.full_name per_vendor_name /*Bug9615008 */
  ,      pv.vendor_id ven_vendor_id
  ,      pv.vendor_name ven_vendor_name
  FROM   per_all_people_f        ppf
  ,      ap_suppliers            pv
  WHERE  pv.employee_id  = ppf.person_id
  AND    ppf.business_group_id    = g_business_group_id
  AND    trunc(sysdate)
               BETWEEN ppf.effective_start_date
                    AND ppf.effective_end_date
  AND    ppf.last_update_date > p_update_date
  AND    /* DECODE(ppf.middle_names,
        null, ppf.last_name||', '||ppf.first_name,
              ppf.last_name||', '||ppf.first_name||' '||ppf.middle_names) Bug9615088 */
       ppf.full_name <> pv.vendor_name
  AND   not exists (SELECT 'duplicate name exists'
                    FROM ap_suppliers pv1
                    WHERE /*DECODE(ppf.middle_names,
                                null, ppf.last_name||', '||ppf.first_name,
                                ppf.last_name||', '||ppf.first_name||' '||ppf.middle_names) Bug9615088*/
                         ppf.full_name = pv1.vendor_name)
--Bug 2987396 eliminate employees with same name
  AND  not exists (SELECT 'Different Emp with Same Name'
                    FROM per_all_people_f ppf1
                    WHERE ppf1.person_id <> ppf.person_id
                    AND trunc(sysdate) BETWEEN ppf1.effective_start_date
                                                  AND ppf1.effective_end_date
                   AND ppf.business_group_id    = ppf1.business_group_id /*Bug 9615088 */
                    AND DECODE(ppf1.middle_names, null, ppf1.last_name||
                              ', '||ppf1.first_name,ppf1.last_name||', '||
                              ppf1.first_name||' '||ppf1.middle_names)
                                           = DECODE(ppf.middle_names,
                                     null, ppf.last_name||', '||ppf.first_name,
                              ppf.last_name||', '||ppf.first_name||' '||
                              ppf.middle_names));


  /* Cursor For Name Change where p_from_supplier and p_to_supplier is not null */
  CURSOR name_cur1 IS
  SELECT /*DECODE(ppf.middle_names,
         null, ppf.last_name||', '||ppf.first_name,
              ppf.last_name||', '||ppf.first_name||' '||ppf.middle_names) Bug9615088 */
         ppf.full_name per_vendor_name
  ,      pv.vendor_id ven_vendor_id
  ,      pv.vendor_name ven_vendor_name
  FROM   per_all_people_f        ppf
  ,      ap_suppliers            pv
  WHERE  pv.employee_id  = ppf.person_id
  AND    ppf.business_group_id    = g_business_group_id
  AND    trunc(sysdate)
               BETWEEN ppf.effective_start_date
                    AND ppf.effective_end_date
  AND    /*DECODE(ppf.middle_names,
        null, ppf.last_name||', '||ppf.first_name,
              ppf.last_name||', '||ppf.first_name||' '||ppf.middle_names)  Bug9615088 */
        ppf.full_name <> pv.vendor_name
  AND   not exists (SELECT 'duplicate name exists'
                    FROM ap_suppliers pv1
                    WHERE /*DECODE(ppf.middle_names,
                                null, ppf.last_name||', '||ppf.first_name,
                                ppf.last_name||', '||ppf.first_name||' '||ppf.middle_names) Bug9615088 */
                         ppf.full_name = pv1.vendor_name)
  AND    pv.vendor_name between p_from_supplier and p_to_supplier
--Bug 2987396 eliminate employees with same name.
  AND  not exists (SELECT 'Different Emp with Same Name'
                    FROM per_all_people_f ppf1
                    WHERE ppf1.person_id <> ppf.person_id
                    AND trunc(sysdate) BETWEEN ppf1.effective_start_date
                                                  AND ppf1.effective_end_date
                   AND ppf.business_group_id    = ppf1.business_group_id /*Bug 9615088 */
                    AND DECODE(ppf1.middle_names, null, ppf1.last_name||
                              ', '||ppf1.first_name,ppf1.last_name||', '||
                              ppf1.first_name||' '||ppf1.middle_names)
                                           = DECODE(ppf.middle_names,
                                     null, ppf.last_name||', '||ppf.first_name,
                              ppf.last_name||', '||ppf.first_name||' '||
                              ppf.middle_names));

   /* Cursor for Inactive Date Change where p_from_supplier and p_to_supplier is null */
  CURSOR inactive_cur IS
  /* SELECT DECODE(greatest(nvl(ppos.actual_termination_date,to_date('4712/12/31',
              'YYYY/MM/DD')),trunc(sysdate)),
              trunc(sysdate),ppos.actual_termination_date) per_idate */ -- Commented and added for bug 9348385
  SELECT DECODE(greatest(nvl(ppos.final_process_date,to_date('4712/12/31','YYYY/MM/DD')),
		trunc(sysdate)), trunc(sysdate),
		ppos.final_process_date) per_idate
  ,      pv.vendor_id ven_vendor_id
  ,      pv.vendor_name ven_vendor_name
  ,      pv.end_date_active ven_idate
  FROM   per_all_assignments_f   paf
  ,      per_periods_of_service  ppos
  ,      per_all_people_f        ppf
  ,      ap_suppliers            pv
  WHERE  pv.employee_id     = ppf.person_id
  AND    ppf.person_id         = paf.person_id
  AND    ppf.person_id         = ppos.person_id
  AND    ppf.business_group_id    = g_business_group_id
  AND    DECODE(ppos.actual_termination_date,
                                       null, trunc(sysdate),
                                             ppos.actual_termination_date)
                BETWEEN paf.effective_start_date
                    AND paf.effective_end_date
  AND    ppos.date_start = (SELECT max(ppos2.date_start)
                           FROM   per_periods_of_service ppos2
                           WHERE  ppos2.person_id       = ppos.person_id
                           AND    ppos2.date_start      <= trunc(sysdate))
  AND    trunc(sysdate)
               BETWEEN ppf.effective_start_date
                    AND ppf.effective_end_date
  AND    paf.assignment_type = 'E'
  /* AND    ppos.last_update_date > p_update_date Commented for bug#9715840 */
  /* Added for bug#9715840 Start */
  AND DECODE(greatest(nvl(ppos.final_process_date,to_date('4712/12/31','YYYY/MM/DD')),
  	  	      trunc(sysdate)
  		     )
              , trunc(sysdate),ppos.final_process_date
            ) > p_update_date
  /* Added for bug#9715840 End */
  AND    nvl(ppos.actual_termination_date,trunc(sysdate)) <>
                nvl(pv.end_date_active,trunc(sysdate));

  /* Cursor for Inactive Date Change where p_from_supplier and p_to_supplier is not null */
  CURSOR inactive_cur1 IS
  /* SELECT DECODE(greatest(nvl(ppos.actual_termination_date,to_date('4712/12/31',
              'YYYY/MM/DD')),trunc(sysdate)),
              trunc(sysdate),ppos.actual_termination_date) per_idate */ -- Commented and added for bug 9348385
  SELECT DECODE(greatest(nvl(ppos.final_process_date,to_date('4712/12/31','YYYY/MM/DD')),
		trunc(sysdate)), trunc(sysdate),
		ppos.final_process_date) per_idate
  ,      pv.vendor_id ven_vendor_id
  ,      pv.vendor_name ven_vendor_name
  ,      pv.end_date_active ven_idate
  FROM   per_all_assignments_f   paf
  ,      per_periods_of_service  ppos
  ,      per_all_people_f        ppf
  ,      ap_suppliers            pv
  WHERE  pv.employee_id     = ppf.person_id
  AND    ppf.person_id       = paf.person_id
  AND    ppf.person_id        = ppos.person_id
  AND    ppf.business_group_id    = g_business_group_id
  AND    DECODE(ppos.actual_termination_date,
                                       null, trunc(sysdate),
                                             ppos.actual_termination_date)
                BETWEEN paf.effective_start_date
                    AND paf.effective_end_date
  AND    ppos.date_start = (SELECT max(ppos2.date_start)
                           FROM   per_periods_of_service ppos2
                           WHERE  ppos2.person_id       = ppos.person_id
                           AND    ppos2.date_start      <= trunc(sysdate))
  AND    trunc(sysdate)
               BETWEEN ppf.effective_start_date
                    AND ppf.effective_end_date
  AND    paf.assignment_type = 'E'
  AND    nvl(ppos.actual_termination_date,trunc(sysdate)) <>
                nvl(pv.end_date_active,trunc(sysdate))
  AND    pv.vendor_name between p_from_supplier and p_to_supplier;


 --inactive_date             date := '01-JAN-1900';
 --Bug fix 2161455  change format to standards.  DD/MM/YYYY
 --Bug fix 2219492, fix the assignment.
 inactive_date             date := to_date('01/01/1900', 'DD/MM/YYYY');
 current_calling_sequence  VARCHAR2(2000);
 l_debug_mode              VARCHAR2(1);


BEGIN

  l_debug_mode := p_debug_mode;

  current_calling_sequence := 'AP_EMPLOYEE_UPDATE_PKG.Update_Employee-> '
                              ||p_calling_sequence;

    Print(l_debug_mode, current_calling_sequence);


-- Performance fix for 115.9 , ARU 2628027
-- Get value for g_business_group_id

   SELECT business_group_id
   INTO   g_business_group_id
   FROM   financials_system_parameters ;


if (p_from_supplier is null and p_to_supplier is  null) then


  FOR name_rec IN name_cur LOOP

    IF nvl(name_rec.ven_vendor_name,'EMPTY') <> nvl(name_rec.per_vendor_name,'EMPTY') THEN
       UPDATE ap_suppliers
        SET    vendor_name = name_rec.per_vendor_name
               ,last_update_date  = sysdate             -- Bug 3191168
               ,last_updated_by   = fnd_global.user_id  -- Bug 3191168
               ,last_update_login = fnd_global.login_id -- Bug 3191168
        WHERE  vendor_id   = name_rec.ven_vendor_id;

    END IF;

  END LOOP;

  COMMIT;


  FOR inactive_rec IN inactive_cur LOOP

    IF nvl(inactive_rec.ven_idate, inactive_date)  <> nvl(inactive_rec.per_idate, inactive_date)  THEN

                UPDATE ap_supplier_sites_all          --bug 3162861
                SET     inactive_date           = inactive_rec.per_idate
		       ,last_update_date        = sysdate              -- Bug 3191168
                       ,last_updated_by         = fnd_global.user_id   -- Bug 3191168
                       ,last_update_login       = fnd_global.login_id  -- Bug 3191168
                WHERE   vendor_id               = inactive_rec.ven_vendor_id;

    /* Bug 1561680 */
                UPDATE ap_suppliers
                SET    end_date_active          = inactive_rec.per_idate
		       ,last_update_date        = sysdate              -- Bug 3191168
                       ,last_updated_by         = fnd_global.user_id   -- Bug 3191168
                       ,last_update_login       = fnd_global.login_id  -- Bug 3191168
                WHERE   vendor_id               = inactive_rec.ven_vendor_id;
    END IF;

  END LOOP;

  COMMIT;

else

  FOR name_rec1 IN name_cur1 LOOP

    IF nvl(name_rec1.ven_vendor_name,'EMPTY') <> nvl(name_rec1.per_vendor_name,'EMPTY') THEN
      UPDATE ap_suppliers
        SET    vendor_name = name_rec1.per_vendor_name
        ,last_update_date        = sysdate              -- Bug 3191168
        ,last_updated_by         = fnd_global.user_id   -- Bug 3191168
        ,last_update_login       = fnd_global.login_id  -- Bug 3191168
        WHERE  vendor_id   = name_rec1.ven_vendor_id;
    END IF;

  END LOOP;

  COMMIT;

  FOR inactive_rec1 IN inactive_cur1 LOOP

    IF nvl(inactive_rec1.ven_idate, inactive_date)  <> nvl(inactive_rec1.per_idate, inactive_date)  THEN

                UPDATE ap_supplier_sites_all    --bug 3162861
                SET     inactive_date           = inactive_rec1.per_idate
               ,last_update_date        = sysdate              -- Bug 3191168
               ,last_updated_by         = fnd_global.user_id   -- Bug 3191168
               ,last_update_login       = fnd_global.login_id  -- Bug 3191168
                WHERE   vendor_id               = inactive_rec1.ven_vendor_id;

    /* Bug 1561680 */
                UPDATE ap_suppliers
                SET    end_date_active          = inactive_rec1.per_idate
                ,last_update_date        = sysdate              -- Bug 3191168
                ,last_updated_by         = fnd_global.user_id   -- Bug 3191168
                ,last_update_login       = fnd_global.login_id  -- Bug 3191168
                WHERE   vendor_id               = inactive_rec1.ven_vendor_id;
    END IF;

  END LOOP;

  COMMIT;

end if;



  RETURN (TRUE);

RETURN NULL; EXCEPTION

 WHEN OTHERS then

    IF (SQLCODE < 0) then
      Print(l_debug_mode,SQLERRM);
    END IF;

    RETURN (FALSE);

END Update_Employee;

END AP_EMPLOYEE_UPDATE_PKG;

/
