--------------------------------------------------------
--  DDL for Package Body JAI_OM_WSH_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_OM_WSH_PROCESSING_PKG" AS
/* $Header: jai_om_wsh_prc.plb 120.2.12010000.2 2008/08/11 10:12:21 lgopalsa ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_om_wsh_prc -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

13-Jun-2005    File Version: 116.3
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done
--------------------------------------------------------------------------------------*/

FUNCTION excise_balance_check
(
  p_pref_rg23a                     NUMBER    ,
  p_pref_rg23c                     NUMBER    ,
  p_pref_pla                   in  NUMBER    ,
  p_ssi_unit_flag                  VARCHAR2  ,
  p_tot_excise_amt                 NUMBER    ,
  p_rg23a_balance                  NUMBER    ,
  p_rg23c_balance                  NUMBER    ,
  p_pla_balance                    NUMBER    ,
  p_basic_pla_balance              NUMBER    ,
  p_additional_pla_balance         NUMBER    ,
  p_other_pla_balance              NUMBER    ,
  p_basic_excise_duty_amount       NUMBER    ,
  p_add_excise_duty_amount         NUMBER    ,
  p_oth_excise_duty_amount         NUMBER    ,
  p_export_oriented_unit           VARCHAR2  ,
  p_register_code                  VARCHAR2  ,
  p_delivery_id                    NUMBER    ,
  p_organization_id                NUMBER    ,
  p_location_id                    NUMBER    ,
  p_cess_amount                    NUMBER    ,
  p_sh_cess_amount                 NUMBER    ,  /* added by ssawant for bug 5989740 */
  p_process_flag        OUT NOCOPY VARCHAR2  ,
  p_process_msg         OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2
IS

    --Variable Declaration starts here................
    v_pref_rg23a                JAI_CMN_INVENTORY_ORGS.pref_rg23a%type;
    v_pref_rg23c                JAI_CMN_INVENTORY_ORGS.pref_rg23c%type;
    v_pref_pla                  JAI_CMN_INVENTORY_ORGS.pref_pla%type;
    v_ssi_unit_flag             JAI_CMN_INVENTORY_ORGS.ssi_unit_flag%type;
    v_reg_type                  VARCHAR2(10);
    v_tot_excise_amt            NUMBER;
    v_rg23a_balance             NUMBER;
    v_rg23c_balance             NUMBER;
    v_pla_balance               NUMBER;
    v_output                    NUMBER;
    v_basic_pla_balance         NUMBER;
    v_additional_pla_balance    number;
    v_other_pla_balance         number;
    v_basic_excise_duty_amount  number;
    v_add_excise_duty_amount    number;
    v_oth_excise_duty_amount    number;
    v_export_oriented_unit      JAI_CMN_INVENTORY_ORGS.export_oriented_unit%type;
    v_register_code             JAI_OM_OE_BOND_REG_HDRS.register_code%type;
    v_debug_flag                varchar2(1); --'N'; --Ramananda for File.Sql.35
    v_utl_location              VARCHAR2(512); --For Log file.
    v_myfilehandle              UTL_FILE.FILE_TYPE; -- This is for File handling
    v_trip_id                   wsh_delivery_trips_v.trip_id%type;
    lv_process_flag             VARCHAR2(2);
    lv_process_message          VARCHAR2(1996);
    lv_register_type            VARCHAR2(5);
    lv_rg23a_cess_avlbl         VARCHAR2(10);
    lv_rg23c_cess_avlbl         VARCHAR2(10);
    lv_pla_cess_avlbl           VARCHAR2(10);
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_wsh_prc_pkg.excise_balance_check';
    lv_rg23a_sh_cess_avlbl         VARCHAR2(10); /* added by ssawant for bug 5989740 */
    lv_rg23c_sh_cess_avlbl         VARCHAR2(10); /* added by ssawant for bug 5989740 */
    lv_pla_sh_cess_avlbl           VARCHAR2(10); /* added by ssawant for bug 5989740 */


    --Variable Declaration Ends here......................

BEGIN

/*------------------------------------------------------------------------------------------
   FILENAME: excise_balance_check_F.sql
   CHANGE HISTORY:

    1.  2002/07/03   Nagaraj.s - For Enh#2415656.
                     Function created for checking the register preferences in case of an Non-
                     Export Oriented Unit and in case of an Export Oriented Unit, the component
                     balances are checked and if balances does not exist, the function will raise an
                     application error and if balances do exist, then the function will return the register
                     type. This Function is called from ja_in_wsh_dlry_dtls_au_trg.sql and jai_om_wsh_pkg.process_delivery.sql.
                     This Function is a prerequisite patch with the above mentioned trigger and procedure.
                     Also Alter table scripts with this patch should be available before sending this patch.
                     Otherwise the patch would certainly fail.

   2.  2005/02/11    ssumaith - bug# 4171272 - File version 115.1

                     Shipment needs to be stopped if education cess is not available. This has been
                     coded in this function. Five new parameters have been added to the function , hence it introduces
                     dependency.

                     The basic business logic validation is that both cess and excise should be available as
                     part of the same register type and the precedence setup at the organization additional information
                     needs to be considered for picking up the correct register order.

                     These functions returns the register only if excise balance and cess balance is enough to
                     cover the current transaction.
                     Signature of the function has been changed because we needed to pass the additional
                     parameters fo comparision.

                     Dependency Due to this bug:
                          Please include all objects of the patch 4171272 along with this object whenever changed,
                          because of change in object signature.


3. 13-April-2007   ssawant for bug 5989740 ,File version 120.2
                   Forward porting Budget07-08 changes of handling secondary and
	           Higher Secondary Education Cess from 11.5( bug no 5907436) to R12 (bug no 5989740).

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version                     Current Bug    Dependent           Files                               Version          Author   Date         Remarks
Of File                                            On Bug/Patchset     Dependent On
excise_balance_check_f.sql
----------------------------------------------------------------------------------------------------------------------------------------------------


  --------------------------------------------------------------------------------------------*/
    v_pref_rg23a                 := p_pref_rg23a;
    v_pref_rg23c                 := p_pref_rg23c;
    v_pref_pla                   := p_pref_pla;
    v_ssi_unit_flag              := p_ssi_unit_flag;
    v_tot_excise_amt             := p_tot_excise_amt;
    v_rg23a_balance              := p_rg23a_balance;
    v_rg23c_balance              := p_rg23c_balance;
    v_pla_balance                := p_pla_balance;
    v_basic_pla_balance          := p_basic_pla_balance;
    v_additional_pla_balance     := p_additional_pla_balance;
    v_other_pla_balance          := p_other_pla_balance;
    v_basic_excise_duty_amount   := p_basic_excise_duty_amount;
    v_add_excise_duty_amount     := p_add_excise_duty_amount;
    v_oth_excise_duty_amount     := p_oth_excise_duty_amount;
    v_export_oriented_unit       := p_export_oriented_unit;
    v_register_code              := p_register_code;

    v_debug_flag                := jai_constants.no; --Ramananda for File.Sql.35

If v_debug_flag = 'Y' THEN
  --For Fetching UTIL File.......
   BEGIN
    SELECT DECODE(SUBSTR (value,1,INSTR(value,',') -1),NULL,
           Value,SUBSTR (value,1,INSTR(value,',') -1))
    INTO v_utl_location
    FROM v$parameter
    WHERE name = 'utl_file_dir';

   EXCEPTION
     WHEN OTHERS THEN
      v_debug_flag := 'N';
  END;
 END IF;

 IF v_debug_flag = 'Y' THEN
   v_myfilehandle := UTL_FILE.FOPEN(v_utl_location,'excise_balance_check_f.log','A');
   UTL_FILE.PUT_LINE(v_myfilehandle,'************************Start************************************');
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Time Stamp this Entry is Created is ' ||TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'));
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_pref_rg23a is ' || v_pref_rg23a);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_pref_rg23c is ' || v_pref_rg23c);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_pref_pla is ' || v_pref_pla);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_rg23a_balance is ' ||v_rg23a_balance);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_rg23c_balance is ' ||v_rg23c_balance);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_pla_balance is ' ||v_pla_balance);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_ssi_unit_flag is ' ||v_ssi_unit_flag);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_tot_excise_amt is ' ||v_tot_excise_amt);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_basic_pla_balance is ' ||v_basic_pla_balance);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_additional_pla_balance is ' ||v_additional_pla_balance);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_other_pla_balance is ' ||v_other_pla_balance);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_basic_excise_duty_amount is ' ||v_basic_excise_duty_amount);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_add_excise_duty_amount is ' ||v_add_excise_duty_amount);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_oth_excise_duty_amount is ' ||v_oth_excise_duty_amount);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_export_oriented_unit is '   || v_export_oriented_unit);
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_register_code is '   || v_register_code);
END IF;

   fnd_file.put_line(FND_FILE.LOG,'************************Start************************************');
   fnd_file.put_line(FND_FILE.LOG,'The Time Stamp this Entry is Created is ' ||TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'));
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_pref_rg23a is ' || v_pref_rg23a);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_pref_rg23c is ' || v_pref_rg23c);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_pref_pla is ' || v_pref_pla);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_rg23a_balance is ' ||v_rg23a_balance);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_rg23c_balance is ' ||v_rg23c_balance);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_pla_balance is ' ||v_pla_balance);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_ssi_unit_flag is ' ||v_ssi_unit_flag);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_tot_excise_amt is ' ||v_tot_excise_amt);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_basic_pla_balance is ' ||v_basic_pla_balance);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_additional_pla_balance is ' ||v_additional_pla_balance);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_other_pla_balance is ' ||v_other_pla_balance);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_basic_excise_duty_amount is ' ||v_basic_excise_duty_amount);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_add_excise_duty_amount is ' ||v_add_excise_duty_amount);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_oth_excise_duty_amount is ' ||v_oth_excise_duty_amount);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_export_oriented_unit is '   || v_export_oriented_unit);
   fnd_file.put_line(FND_FILE.LOG,'The Value of v_register_code is '   || v_register_code);
   fnd_file.put_line(FND_FILE.LOG,'The Value of delivery id '|| p_delivery_id);
   fnd_file.put_line(FND_FILE.LOG,'The Value of organization id '|| p_organization_id);
   fnd_file.put_line(FND_FILE.LOG,'The Value of location id '||  p_location_id);
   fnd_file.put_line(FND_FILE.LOG,'The Value of cess amount'||  p_cess_amount);
   fnd_file.put_line(FND_FILE.LOG,'The Value of sh cess amount'||  p_sh_cess_amount);
-----------------------------------------------------------------------------------------------------------------
 BEGIN

 fnd_file.put_line(FND_FILE.LOG, ' Call RG others check balances');

    lv_register_type := 'RG23A';
    jai_cmn_rg_others_pkg.check_balances(
                                     p_organization_id   =>  p_organization_id ,
                                     p_location_id       =>  p_location_id     ,
                                     p_register_type     =>  lv_register_type  ,
                                     p_trx_amount        =>  p_cess_amount     ,
                                     p_process_flag      =>  lv_process_flag   ,
                                     p_process_message   =>  lv_process_message
                                    );

   if  lv_process_flag <> jai_constants.successful then
       lv_rg23a_cess_avlbl := 'FALSE';
       fnd_file.put_line(FND_FILE.LOG, ' Problem in cess balance');
   else
       lv_rg23a_cess_avlbl := 'TRUE';
   end if;

   fnd_file.put_line(FND_FILE.LOG, ' call RG others sh check balances');
		 /* added by ssawant for bug 5989740 */
   jai_cmn_rg_others_pkg .check_sh_balances(
                                     p_organization_id   =>  p_organization_id ,
                                     p_location_id       =>  p_location_id     ,
                                     p_register_type     =>  lv_register_type  ,
                                     p_trx_amount        =>  p_sh_cess_amount     ,
                                     p_process_flag      =>  lv_process_flag   ,
                                     p_process_message   =>  lv_process_message
                                    );

   if  lv_process_flag <> jai_constants.successful then
       lv_rg23a_sh_cess_avlbl := 'FALSE';
       fnd_file.put_line(FND_FILE.LOG, ' Problem in SH cess balance');
   else
       lv_rg23a_sh_cess_avlbl := 'TRUE';
 end if;

 fnd_file.put_line(FND_FILE.LOG, ' call rg23 c  check balances');

   lv_register_type := 'RG23C';
   jai_cmn_rg_others_pkg.check_balances(
                                    p_organization_id   =>  p_organization_id ,
                                    p_location_id       =>  p_location_id     ,
                                    p_register_type     =>  lv_register_type  ,
                                    p_trx_amount        =>  p_cess_amount     ,
                                    p_process_flag      =>  lv_process_flag   ,
                                    p_process_message   =>  lv_process_message
                                   );

   if  lv_process_flag <> jai_constants.successful then
       lv_rg23c_cess_avlbl := 'FALSE';
       fnd_file.put_line(FND_FILE.LOG, ' Problem in cess balance');
   else
       lv_rg23c_cess_avlbl := 'TRUE';
   end if;
 fnd_file.put_line(FND_FILE.LOG, ' call rg 23 c sh check balances');

	/* added by ssawant for bug 5989740 */
   lv_register_type := 'RG23C';
   jai_cmn_rg_others_pkg .check_sh_balances(
                                    p_organization_id   =>  p_organization_id ,
                                    p_location_id       =>  p_location_id     ,
                                    p_register_type     =>  lv_register_type  ,
                                    p_trx_amount        =>  p_sh_cess_amount     ,
                                    p_process_flag      =>  lv_process_flag   ,
                                    p_process_message   =>  lv_process_message
                                   );

   if  lv_process_flag <> jai_constants.successful then
       lv_rg23c_sh_cess_avlbl := 'FALSE';
   else
       lv_rg23c_sh_cess_avlbl := 'TRUE';
   end if;

 fnd_file.put_line(FND_FILE.LOG, ' call pla check balances');

  lv_register_type := 'PLA';
  jai_cmn_rg_others_pkg.check_balances(
                                   p_organization_id   =>  p_organization_id ,
                                   p_location_id       =>  p_location_id     ,
                                   p_register_type     =>  lv_register_type  ,
                                   p_trx_amount        =>  p_cess_amount     ,
                                   p_process_flag      =>  lv_process_flag   ,
                                   p_process_message   =>  lv_process_message
                                  );

 if  lv_process_flag <> jai_constants.successful then
     lv_pla_cess_avlbl := 'FALSE';
 else
     lv_pla_cess_avlbl := 'TRUE';
 end if;
 fnd_file.put_line(FND_FILE.LOG, ' call pla sh check balances');

		/* added by ssawant for bug 5989740 */
  jai_cmn_rg_others_pkg .check_sh_balances(
                                   p_organization_id   =>  p_organization_id ,
                                   p_location_id       =>  p_location_id     ,
                                   p_register_type     =>  lv_register_type  ,
                                   p_trx_amount        =>  p_sh_cess_amount     ,
                                   p_process_flag      =>  lv_process_flag   ,
                                   p_process_message   =>  lv_process_message
                                  );

 if  lv_process_flag <> jai_constants.successful then
     lv_pla_sh_cess_avlbl := 'FALSE';
       fnd_file.put_line(FND_FILE.LOG, ' Problem in SH cess balance');
 else
     lv_pla_sh_cess_avlbl := 'TRUE';
 end if;


--Balance Validations if Eou is No.....
   IF v_export_oriented_unit = 'N' Then
     IF v_pref_rg23a = 1   THEN    -------------------------------------------------------7
       IF v_rg23a_balance >= NVL(v_tot_excise_amt,0) and lv_rg23a_cess_avlbl = 'TRUE' and lv_rg23a_sh_cess_avlbl = 'TRUE' THEN ---------------------------8/* added by ssawant for bug 5989740 */
             v_reg_type := 'RG23A';
       ELSIF v_pref_rg23c = 2 THEN
          IF v_rg23c_balance >= NVL(v_tot_excise_amt,0) and lv_rg23c_cess_avlbl = 'TRUE' and lv_rg23c_sh_cess_avlbl = 'TRUE' THEN ------------------9/* added by ssawant for bug 5989740 */
             v_reg_type := 'RG23C';
          ELSIF v_pref_pla =3 THEN
            IF v_pla_balance >= NVL(v_tot_excise_amt,0) AND lv_pla_cess_avlbl = 'TRUE' AND lv_pla_sh_cess_avlbl = 'TRUE' THEN --------------10/* added by ssawant for bug 5989740 */
               v_reg_type := 'PLA';
            ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN
               v_reg_type  := 'PLA';
            ELSE
               v_reg_type := 'ERROR';
            END IF;--------------------------------------------------------10
         ELSE
            v_reg_type := 'ERROR';
         END IF;---------------------------------------------------------------9
       ELSIF v_pref_pla = 2 THEN
         IF v_pla_balance >= NVL(v_tot_excise_amt,0) AND lv_pla_cess_avlbl = 'TRUE' AND lv_pla_sh_cess_avlbl = 'TRUE' THEN -------------------11/* added by ssawant for bug 5989740 */
               v_reg_type := 'PLA';
         ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN
            v_reg_type  := 'PLA';
         ELSIF v_pref_rg23c = 3 THEN
            IF v_rg23c_balance >= NVL(v_tot_excise_amt,0) AND lv_rg23c_cess_avlbl = 'TRUE' AND lv_rg23c_sh_cess_avlbl = 'TRUE' THEN  ----------12/* added by ssawant for bug 5989740 */
                  v_reg_type := 'RG23C';
            ELSE
               v_reg_type := 'ERROR';
            END IF;--------------------------------------------------------12
         ELSE
            v_reg_type    := 'ERROR';
         END IF;------------------------------------------------------------ 11
       ELSE
         v_reg_type           :='ERROR';
       END IF;------------------------------------------------------------------8
-------------------------------------------------------------------------------------------------------------------
  ELSIF v_pref_rg23c = 1   THEN    -------------------------------------------------------7
      IF v_rg23c_balance >= NVL(v_tot_excise_amt,0) AND lv_rg23c_cess_avlbl = 'TRUE' AND lv_rg23c_sh_cess_avlbl = 'TRUE' THEN ---------------------------8/* added by ssawant for bug 5989740 */
            v_reg_type := 'RG23C';
      ELSIF v_pref_rg23a = 2 THEN
        IF v_rg23a_balance >= NVL(v_tot_excise_amt,0) AND lv_rg23a_cess_avlbl = 'TRUE' AND lv_rg23a_sh_cess_avlbl = 'TRUE' THEN ------------------9/* added by ssawant for bug 5989740 */
              v_reg_type := 'RG23A';
        ELSIF v_pref_pla =3 THEN
           IF v_pla_balance >= NVL(v_tot_excise_amt,0) AND lv_pla_cess_avlbl = 'TRUE' AND lv_pla_sh_cess_avlbl = 'TRUE'  THEN --------------10/* added by ssawant for bug 5989740 */
                 v_reg_type := 'PLA';
           ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN
              v_reg_type  := 'PLA';
           ELSE
              v_reg_type := 'ERROR';
           END IF;--------------------------------------------------------10
        ELSE
           v_reg_type := 'ERROR';
        END IF;---------------------------------------------------------------9
      ELSIF v_pref_pla = 2 THEN
        IF v_pla_balance >= NVL(v_tot_excise_amt,0) AND lv_pla_cess_avlbl = 'TRUE' AND lv_pla_sh_cess_avlbl = 'TRUE' THEN -------------------11/* added by ssawant for bug 5989740 */
             v_reg_type := 'PLA';
        ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN
           v_reg_type  := 'PLA';
        ELSIF v_pref_rg23a = 3 THEN
          IF v_rg23a_balance >= NVL(v_tot_excise_amt,0) AND lv_rg23a_cess_avlbl = 'TRUE' AND lv_rg23a_sh_cess_avlbl = 'TRUE' THEN  ----------12/* added by ssawant for bug 5989740 */
             v_reg_type := 'RG23A';
          ELSE
             v_reg_type := 'ERROR';
          END IF;--------------------------------------------------------12
        ELSE
           v_reg_type    := 'ERROR';
        END IF;------------------------------------------------------------ 11
      ELSE
        v_reg_type           :='ERROR';
      END IF;------------------------------------------------------------------8
-------------------------------------------------------------------------------------------------------------------
  ELSIF v_pref_pla = 1 THEN
     IF v_pla_balance >= NVL(v_tot_excise_amt,0) AND lv_pla_cess_avlbl = 'TRUE' AND lv_pla_sh_cess_avlbl = 'TRUE' THEN ---------------------------13/* added by ssawant for bug 5989740 */
        v_reg_type := 'PLA';
     ELSIF NVL(v_ssi_unit_flag,'N') = 'Y' THEN
      v_reg_type  := 'PLA';
     ELSIF v_pref_rg23a = 2 THEN
      IF v_rg23a_balance >= NVL(v_tot_excise_amt,0) AND lv_rg23a_cess_avlbl = 'TRUE'  AND lv_rg23a_sh_cess_avlbl = 'TRUE' THEN ------------------14/* added by ssawant for bug 5989740 */
          v_reg_type := 'RG23A';
     ELSIF v_pref_rg23c =3 THEN
       IF v_rg23c_balance >= NVL(v_tot_excise_amt,0) AND lv_rg23c_cess_avlbl = 'TRUE' AND lv_rg23c_sh_cess_avlbl = 'TRUE' THEN --------------15/* added by ssawant for bug 5989740 */
          v_reg_type := 'RG23C';
       ELSE
          v_reg_type := 'ERROR';
       END IF;--------------------------------------------------------15
     ELSE
     v_reg_type := 'ERROR';
    END IF;---------------------------------------------------------------14
    ELSIF v_pref_rg23c = 2 THEN
     IF v_rg23c_balance >= NVL(v_tot_excise_amt,0) AND lv_rg23c_cess_avlbl = 'TRUE' AND lv_rg23c_sh_cess_avlbl = 'TRUE' THEN -------------------16/* added by ssawant for bug 5989740 */
           v_reg_type := 'RG23C';
     ELSIF v_pref_rg23a = 3 THEN
      IF v_rg23a_balance >= NVL(v_tot_excise_amt,0) AND lv_rg23a_cess_avlbl = 'TRUE' AND lv_rg23a_sh_cess_avlbl = 'TRUE' THEN  ----------17/* added by ssawant for bug 5989740 */
            v_reg_type := 'RG23A';
      ELSE
       v_reg_type := 'ERROR';
      END IF;--------------------------------------------------------17
     ELSE
       v_reg_type    := 'ERROR';
     END IF;------------------------------------------------------------ 16
    ELSE
     v_reg_type           :='ERROR';
    END IF;------------------------------------------------------------------13
  ELSE
     v_reg_type         :='ERROR';
  END IF;---------------------------------------------------------------------------7

--Balance Validations if EOU is Yes.....
   ELSIF v_export_oriented_unit ='Y' and v_register_code='EXPORT_EXCISE' then

    fnd_file.put_line(FND_FILE.LOG, ' validation for export excise ');

    --Validation for Basic Excise Duty Amount.
     IF  nvl(v_basic_excise_duty_amount,0) >0 THEN
       IF  v_basic_pla_balance >= v_basic_excise_duty_amount AND lv_pla_cess_avlbl = 'TRUE' AND lv_pla_sh_cess_avlbl = 'TRUE' then /* added by ssawant for bug 5989740 */
           v_reg_type := 'PLA';
       ELSE
          v_reg_type := 'ERROR';
       END IF;
     END IF;

     fnd_file.put_line(FND_FILE.LOG, ' Basic - reg type '|| v_reg_type);

      --Validation for Additional Excise Duty Amount.
      IF v_reg_type<>'ERROR' THEN
        IF  nvl(v_add_excise_duty_amount,0) >0 THEN

          IF  v_additional_pla_balance >= v_add_excise_duty_amount AND lv_pla_cess_avlbl = 'TRUE' AND lv_pla_sh_cess_avlbl = 'TRUE' THEN /* added by ssawant for bug 5989740 */
               v_reg_type := 'PLA';
          ELSE
               v_reg_type := 'ERROR';
          END IF;
        END IF;
      END IF;

     fnd_file.put_line(FND_FILE.LOG, ' Additional - reg type '|| v_reg_type);

      --Validation for Other Excise Duty Amount.
      IF v_reg_type<>'ERROR' THEN

        IF  nvl(v_oth_excise_duty_amount,0) >0 THEN
          IF  v_other_pla_balance >= v_oth_excise_duty_amount AND lv_pla_cess_avlbl = 'TRUE' AND lv_pla_sh_cess_avlbl = 'TRUE' then /* added by ssawant for bug 5989740 */
              v_reg_type := 'PLA';
          ELSE
              v_reg_type := 'ERROR';
          END IF;
        END IF;
      END IF;

    END IF; --End of Export Oriented Check......
    fnd_file.put_line(FND_FILE.LOG, ' Other reg type '|| v_reg_type);
  -----------------------------------------------------------------------------------------------------------------
EXCEPTION
      when others then
      fnd_file.put_line(FND_FILE.LOG, ' Error raised ni excise_balance_check function');
      raise_application_error(-20001,'Error Raised in excise_balance_check function');
 END;

 --To Raise an Application Error in the Function only rather than in the Trigger or Procedure........
 IF v_reg_type='ERROR' THEN
  BEGIN
   SELECT TRIP_ID
   into v_trip_id
   FROM WSH_DELIVERY_TRIPS_V
   WHERE DELIVERY_ID=p_delivery_id;
  EXCEPTION
   WHEN OTHERS THEN
  NULL;
  END;

  IF v_debug_flag = 'Y' THEN
     UTL_FILE.PUT_LINE(v_myfilehandle,'Transaction failed as balances are not sufficient');
     UTL_FILE.PUT_LINE(v_myfilehandle,'The Value of v_trip_id for which transaction failed is ' || v_trip_id);
     UTL_FILE.PUT_LINE(v_myfilehandle,'************************END************************************');
     UTL_FILE.FCLOSE(v_myfileHandle);
  END IF;
  IF v_export_oriented_unit ='N' THEN
      fnd_file.put_line(FND_FILE.LOG, 'None of the Register Have Balances Greater OR Equal TO the Excisable Amount ->'
      || TO_CHAR(v_tot_excise_amt )||' OR Education Cess Amount => ' || to_char(p_cess_amount) );
   RAISE_APPLICATION_ERROR(-20120, 'None of the Register Have Balances Greater OR Equal TO the Excisable Amount ->'
      || TO_CHAR(v_tot_excise_amt )||' OR Education Cess Amount => ' || to_char(p_cess_amount) );
  ELSIF v_export_oriented_unit ='Y' and v_register_code='EXPORT_EXCISE' THEN
      fnd_file.put_line(FND_FILE.LOG, 'The Excise Component Balances are not sufficient' );
   RAISE_APPLICATION_ERROR(-20120, 'The Excise Component Balances are not sufficient');
   fnd_file.put_line(FND_FILE.LOG, ' The Excise Component Balances are not sufficient ');
  END IF;
 END IF;

 RETURN(v_reg_type);

EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END excise_balance_check;

END jai_om_wsh_processing_pkg;

/
