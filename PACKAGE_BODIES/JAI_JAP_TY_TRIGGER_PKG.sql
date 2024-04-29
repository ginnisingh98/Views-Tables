--------------------------------------------------------
--  DDL for Package Body JAI_JAP_TY_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_JAP_TY_TRIGGER_PKG" AS
/* $Header: jai_jap_ty_t.plb 120.3 2006/07/14 09:03:46 lgopalsa noship $ */

/*  REM +======================================================================+
  REM NAME          ARI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_JAP_TY_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_JAP_TY_ARI_T1
  REM
  REM +======================================================================+
*/


  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    v_org_tan_num   jai_ap_tds_org_tan_v.org_tan_num%TYPE; ---  4323338
  v_leg_org_tan_num jai_ap_tds_org_tan_v.org_tan_num%TYPE;--- 4323338
  v_opt_unit_id NUMBER;

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------------------------
Trigger Functionality:
 When a new TDS year is defined, then this trigger gets fired and inserts data into JAI_AP_TDS_CERT_NUMS for
any organization (legal entity/operating unit) in which tan number is defined. If tan number is not defined for
any operating unit, then we cannot find a record in this table for the same OU, in this case while generating TDS
certificates the tan number defined at legal entity should be used where in organization_id of the record will be NULL
------------------------------------------------------------------------------------------------------------
Change History - FILENAME: ja_in_hr_org_insert_trg.sql

 S.No      Date          Author AND Details
--------------------------------------------------------------------------------------------------------------
1        30/03/2002   RPK:BUG#2293270
                         Code modified to store the financial years/tan#/certificate ids of the opr units.

2        17/08/2002   Aparajita for bug # 2508085.
                         if the org tan number is maintained at legal entity level instead of operating unit level then
                         the earlier code was giving problem as the records are there in JAI_AP_TDS_ORG_TANS for the
                         legal_entity and not the operating unit.

                         revamped the code for this, old code is attached at the end.

3        20/02/2004   Vijay Shankar for Bug# 2762636, FileVersion: 618.1
                       - Added the code to insert data into JAI_AP_TDS_CERT_NUMS table for LE

4.       2/05/2005        rchandan for bug#4323338. Version 116.1
                        India Org Info DFF is eliminated as a part of JA migration. A table by name ja_in_ap_tds_org_tan is dropped
                        and a view jai_ap_tds_org_tan_v is created to capture the PAN No,TAN NO and WARD NO. The code changes are done
                        to refer to the new view instead of the dropped table.

5.      08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                      DB Entity as required for CASE COMPLAINCE.  Version 116.1

6. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

7     07/12/2005   Hjujjuru for the bug 4866533 File version 120.1
                    added the who columns in the insert to the table JAI_AP_TDS_CERT_NUMS
                    Dependencies Due to this bug:-
                    None

8.  12-Dec-2005  Hjujjuru for Bug 4873356 , File Version 120.3
                 Changed the value of TAN no from v_leg_org_tan_num to pr_new.tan_no in the insert to the table JAI_AP_TDS_CERT_NUMS.

                 Modified the SQL%NOTFOUND to SQL%ROWCOUNT before the insert into the table JAI_AP_TDS_CERT_NUMS.


--------------------------------------------------------------------------------------------------------------*/


-- Start, Vijay Shankar for Bug# 2762636
BEGIN
    pv_return_code := jai_constants.successful ;
/*
  SELECT org_tan_num
  INTO v_leg_org_tan_num
  FROM jai_ap_tds_org_tan_v   --4323338
  WHERE organization_id = pr_new.Legal_Entity_id ;

*/
 /*
  need to clarify with Vijay shankar whats the first update and insert below doing ?
 */



  IF pr_new.tan_no IS NOT NULL THEN

    UPDATE JAI_AP_TDS_CERT_NUMS
    SET org_tan_num = pr_new.tan_no
    WHERE legal_entity = pr_new.Legal_Entity_Id
    AND (organization_id IS NULL OR organization_id = to_number(pr_new.Legal_Entity_Id) )
    AND fin_yr = pr_new.Fin_Year
    AND legal_entity = to_number(pr_new.Legal_Entity_Id);

    IF SQL%ROWCOUNT = 0 THEN   -- Harshita for Bug 4873356
      INSERT INTO JAI_AP_TDS_CERT_NUMS (FIN_YR_CERT_ID,
        organization_id, legal_entity, fin_yr,
        CERTIFICATE_NUM, LINE_NUM, Org_tan_num,
        -- added, Harshita for Bug 4866533
        created_by, creation_date, last_updated_by, last_update_date
      ) VALUES  ( JAI_AP_TDS_CERT_NUMS_S.nextval,
        to_number(pr_new.Legal_Entity_Id), to_number(pr_new.Legal_Entity_Id), pr_new.Fin_Year,
        NULL, NULL, pr_new.tan_no , --v_leg_org_tan_num, -- Harshita for Bug 4873356
        -- added, Harshita for Bug 4866533
        fnd_global.user_id, sysdate, fnd_global.user_id, sysdate
      );
    END IF;
  END IF;

EXCEPTION
  -- there is no tan number defined at legal entity level and thats why execution comes here
  WHEN NO_DATA_FOUND THEN
    v_leg_org_tan_num := null;
END;
-- End, Vijay Shankar for Bug# 2762636

-- this loops through all the operating units under the legal entity. updates fin year cert info if a separate Tan number is
-- defined at the Operating Unit level
FOR c_org_id IN
(
  SELECT organization_id
  FROM   JAI_RGM_ORG_REGNS_V
  WHERE  regime_code = 'TDS'
  AND    registration_type = 'OTHERS'
  AND    attribute_type_code = 'PRIMARY'
  AND    attribute_code = 'TAN NO'
  AND    attribute_Value = pr_new.tan_no
)
LOOP

  v_org_tan_num := pr_new.tan_no;
  v_opt_unit_id := c_org_id.organization_id;

  -- check if tan number exists for the operating unit.
  /* BEGIN

    SELECT org_tan_num
    INTO   v_org_tan_num
    FROM   jai_ap_tds_org_tan_v     ---  4323338
    WHERE  organization_id = c_org_id.organization_id;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
    v_org_tan_num := null;
  END;

  IF v_leg_org_tan_num IS NULL AND v_org_tan_num IS NULL THEN
    RAISE NO_DATA_FOUND;
  END IF; */

  UPDATE  JAI_AP_TDS_CERT_NUMS
  SET     org_tan_num = pr_new.tan_no --nvl(v_org_tan_num, v_leg_org_tan_num)
  WHERE   organization_id = c_org_id.organization_id
  -- AND     legal_entity = pr_new.Legal_Entity_Id
  AND     fin_yr = pr_new.Fin_Year;


  IF SQL%ROWCOUNT = 0 THEN   -- Harshita for Bug 4873356
    INSERT INTO JAI_AP_TDS_CERT_NUMS (FIN_YR_CERT_ID,
      organization_id, legal_entity, fin_yr,
      CERTIFICATE_NUM, LINE_NUM, Org_tan_num,
      -- added, Harshita for Bug 4866533
      created_by, creation_date, last_updated_by, last_update_date
    ) VALUES  ( JAI_AP_TDS_CERT_NUMS_S.nextval,
      c_org_id.Organization_id,
      /* Bug 5388544. Added by Lakshmi Gopalsami
       * Checked the value of legal_entity_id, If it is 0, insert the
       * same else insert the value of c_org_id.organization_id.
       */
      decode(pr_new.Legal_Entity_Id, 0,0,c_org_id.organization_id),
      pr_new.Fin_Year,
      NULL, NULL, v_org_tan_num,
      -- added, Harshita for Bug 4866533
      fnd_global.user_id, sysdate, fnd_global.user_id, sysdate

    );
  END IF;

  END LOOP;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    --RAISE_APPLICATION_ERROR(-20009, 'Tan Number has not been defined for this legal entity / operating unit->'||v_opt_unit_id);
      /* Added an exception block by Ramananda for bug#4570303 */
     Pv_return_code     :=  jai_constants.expected_error;
     Pv_return_message  := 'Tan Number has not been defined for this legal entity / operating unit->'||v_opt_unit_id ;

  WHEN OTHERS THEN
    --RAISE_APPLICATION_ERROR(-20008, 'Exception from ja_in_fin_year_cert_trg :' || LTRIM(RTRIM(SQLERRM)));
    /* Added an exception block by Ramananda for bug#4570303 */
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_JAP_TY_TRIGGER_PKG.ARI_T1 '  || substr(sqlerrm,1,1900);


  END ARI_T1 ;

END JAI_JAP_TY_TRIGGER_PKG ;

/
